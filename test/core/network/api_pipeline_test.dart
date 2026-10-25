import 'dart:convert';

import 'package:baytna_customer/core/config/app_config.dart';
import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/dio_factory.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/core/network/server_status.dart';
import 'package:baytna_customer/core/network/session_events.dart';
import 'package:baytna_customer/core/network/token_refresher.dart';
import 'package:baytna_customer/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';
import '../../helpers/in_memory_token_storage.dart';

const _config = AppConfig(
  environment: AppEnvironment.staging,
  apiBaseUrl: 'https://api.test/api/v1',
  slowRequestThreshold: Duration(milliseconds: 50),
);

String _jwt(DateTime exp) {
  String part(Map<String, Object> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.'
      '${part({'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

class _Harness {
  _Harness(Map<String, Handler> routes, {AuthTokens? tokens})
    : backend = FakeBackend(routes),
      storage = InMemoryTokenStorage(tokens) {
    final refreshDio = DioFactory.createRefreshDio(_config, status)
      ..httpClientAdapter = backend;
    refresher = TokenRefresher(storage, refreshDio, events);
    final dio = DioFactory.createApiDio(
      config: _config,
      status: status,
      storage: storage,
      refresher: refresher,
    )..httpClientAdapter = backend;
    api = ApiClient(dio);
    events.onExpired.listen((_) => expiredCount++);
  }

  final FakeBackend backend;
  final InMemoryTokenStorage storage;
  final ServerStatus status = ServerStatus();
  final SessionEvents events = SessionEvents();
  late final TokenRefresher refresher;
  late final ApiClient api;
  int expiredCount = 0;

  Future<Json> me() => api.get('/auth/me', decode: asJson);
}

/// A backend with rotating refresh tokens and REUSE DETECTION, like prod:
/// presenting a spent refresh token revokes the whole family.
Map<String, Handler> _rotatingBackend({
  Duration refreshLatency = const Duration(milliseconds: 80),
}) {
  var generation = 1;
  var revoked = false;
  String access() => 'access-$generation';
  return {
    'GET /api/v1/auth/me': (o, _) async {
      final ok = !revoked && o.headers['Authorization'] == 'Bearer ${access()}';
      return ok ? FakeBackend.ok({'id': 'u1'}) : FakeBackend.error(401, 'Unauthorized');
    },
    'POST /api/v1/auth/refresh': (o, body) async {
      await Future<void>.delayed(refreshLatency);
      final presented = (body! as Map)['refreshToken'];
      if (revoked || presented != 'refresh-$generation') {
        revoked = true; // reuse detected → every session dies
        return FakeBackend.error(401, 'Refresh token reuse detected');
      }
      generation++;
      return FakeBackend.ok({
        'accessToken': access(),
        'refreshToken': 'refresh-$generation',
      });
    },
  };
}

void main() {
  group('envelope + error mapping', () {
    test('unwraps data so callers never see the envelope', () async {
      final h = _Harness({
        'GET /api/v1/countries': (_, _) async => FakeBackend.ok([
          {'id': 'c1'},
        ]),
      });
      final data = await h.api.get(
        '/countries',
        decode: asJsonList,
        authenticated: false,
      );
      expect(data, [
        {'id': 'c1'},
      ]);
    });

    test('message as array → ValidationFailure with every message', () async {
      final h = _Harness({
        'POST /api/v1/auth/otp/request': (_, _) async =>
            FakeBackend.error(400, ['countryId must be a mongodb id', 'phone too short']),
      });
      expect(
        () => h.api.post('/auth/otp/request', decode: ApiClient.ignore, authenticated: false),
        throwsA(
          const ValidationFailure(['countryId must be a mongodb id', 'phone too short']),
        ),
      );
    });

    test('message as string; 429 → RateLimitedFailure', () async {
      final h = _Harness({
        'POST /api/v1/auth/otp/request': (_, _) async =>
            FakeBackend.error(429, 'Please wait before requesting another code'),
      });
      await expectLater(
        h.api.post('/auth/otp/request', decode: ApiClient.ignore, authenticated: false),
        throwsA(isA<RateLimitedFailure>()),
      );
    });

    test('5xx is retried as a cold start, flagged as waking up, then succeeds', () async {
      var calls = 0;
      final h = _Harness({
        'GET /api/v1/countries': (_, _) async =>
            ++calls == 1 ? (503, null) : FakeBackend.ok(<Object>[]),
      });
      final seen = <bool>[];
      h.status.wakingUp.addListener(() => seen.add(h.status.wakingUp.value));
      await h.api.get('/countries', decode: asJsonList, authenticated: false);
      expect(calls, 2);
      expect(seen, [true, false]);
    }, timeout: const Timeout(Duration(seconds: 20)));
  });

  group('single-flight refresh', () {
    test('10 concurrent 401s trigger exactly ONE refresh; all replay OK', () async {
      final h = _Harness(
        _rotatingBackend(),
        tokens: const AuthTokens(accessToken: 'stale', refreshToken: 'refresh-1'),
      );
      final results = await Future.wait(List.generate(10, (_) => h.me()));

      expect(results, everyElement({'id': 'u1'}));
      expect(h.backend.count('POST /api/v1/auth/refresh'), 1);
      expect(
        h.storage.tokens,
        const AuthTokens(accessToken: 'access-2', refreshToken: 'refresh-2'),
      );
      expect(h.expiredCount, 0);
    });

    test('a request started DURING a refresh is queued, not sent with the old token', () async {
      final h = _Harness(
        _rotatingBackend(refreshLatency: const Duration(milliseconds: 200)),
        tokens: const AuthTokens(accessToken: 'stale', refreshToken: 'refresh-1'),
      );
      final first = h.me();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(h.refresher.isRefreshing, isTrue);
      final second = h.me();
      await Future.wait([first, second]);

      final meAuth = [
        for (final (i, r) in h.backend.requests.indexed)
          if (r.uri.path.endsWith('/auth/me')) h.backend.sentAuth[i],
      ];
      // first: stale(401) + replay; second: sent once, already with the new token.
      expect(meAuth, [
        'Bearer stale',
        'Bearer access-2',
        'Bearer access-2',
      ]);
      expect(h.backend.count('POST /api/v1/auth/refresh'), 1);
    });

    test('an expired JWT is refreshed BEFORE sending (no wasted 401)', () async {
      final expired = _jwt(DateTime.now().subtract(const Duration(minutes: 1)));
      final h = _Harness(
        _rotatingBackend(),
        tokens: AuthTokens(accessToken: expired, refreshToken: 'refresh-1'),
      );
      await h.me();
      expect(h.backend.requests.map((r) => '${r.method} ${r.uri.path}'), [
        'POST /api/v1/auth/refresh',
        'GET /api/v1/auth/me',
      ]);
    });

    test('rejected refresh: tokens cleared, ONE expiry event, all fail as SessionExpired', () async {
      final h = _Harness(
        _rotatingBackend(),
        tokens: const AuthTokens(accessToken: 'stale', refreshToken: 'already-spent'),
      );
      final outcomes = await Future.wait(
        List.generate(5, (_) => h.me().then<Object>((v) => v, onError: (Object e) => e)),
      );

      expect(outcomes, everyElement(isA<SessionExpiredFailure>()));
      expect(h.backend.count('POST /api/v1/auth/refresh'), 1);
      expect(h.storage.tokens, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(h.expiredCount, 1);
    });

    test('network failure during refresh keeps the session (no logout)', () async {
      final h = _Harness(
        {
          ..._rotatingBackend(),
          'POST /api/v1/auth/refresh': (o, _) async => throw DioException.connectionError(
            requestOptions: o,
            reason: 'offline',
          ),
        },
        tokens: const AuthTokens(accessToken: 'stale', refreshToken: 'refresh-1'),
      );
      await expectLater(h.me(), throwsA(isA<NetworkFailure>()));
      expect(h.storage.tokens, isNotNull);
      expect(h.expiredCount, 0);
    });
  });
}
