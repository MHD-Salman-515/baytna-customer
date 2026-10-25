import 'package:baytna_customer/core/config/app_config.dart';
import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/dio_factory.dart';
import 'package:baytna_customer/core/network/server_status.dart';
import 'package:baytna_customer/core/network/session_events.dart';
import 'package:baytna_customer/core/network/token_refresher.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:baytna_customer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:baytna_customer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baytna_customer/features/auth/domain/auth_failures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_backend.dart';
import '../../helpers/in_memory_token_storage.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage;

/// Error bodies below are verbatim from the live staging API.
void main() {
  late InMemoryTokenStorage tokens;

  AuthRepositoryImpl repo(Map<String, Handler> routes) {
    const config = AppConfig(environment: AppEnvironment.staging, apiBaseUrl: 'https://api.test/api/v1');
    final backend = FakeBackend(routes);
    final status = ServerStatus();
    final refresher = TokenRefresher(
      tokens,
      DioFactory.createRefreshDio(config, status)..httpClientAdapter = backend,
      SessionEvents(),
    );
    final dio = DioFactory.createApiDio(config: config, status: status, storage: tokens, refresher: refresher)
      ..httpClientAdapter = backend;
    final secure = _MockSecureStorage();
    when(
      () => secure.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((_) async {});
    return AuthRepositoryImpl(AuthRemoteDataSource(ApiClient(dio)), AuthLocalDataSource(secure), tokens);
  }

  setUp(() => tokens = InMemoryTokenStorage());

  Future<Failure?> verifyFailure(Object message) async {
    final r = await repo({
      'POST /api/v1/auth/otp/verify': (_, _) async => FakeBackend.error(400, message),
    }).verifyOtp(countryId: 'c', phone: '+963911111111', code: '000000');
    return switch (r) {
      Err(:final failure) => failure,
      Ok() => null,
    };
  }

  test('"Invalid or expired code" → InvalidOtpCode', () async {
    expect(await verifyFailure('Invalid or expired code'), isA<InvalidOtpCode>());
  });

  test('"Too many attempts — request a new code" → TooManyOtpAttempts', () async {
    expect(await verifyFailure('Too many attempts — request a new code'), isA<TooManyOtpAttempts>());
  });

  test('other 400s on verify stay a ValidationFailure', () async {
    expect(await verifyFailure(['code must be longer than or equal to 6 characters']), isA<ValidationFailure>());
  });

  test('429 on request → RateLimitedFailure; 400 on request → InvalidPhoneNumber', () async {
    final limited = await repo({
      'POST /api/v1/auth/otp/request': (_, _) async =>
          FakeBackend.error(429, 'Please wait before requesting another code'),
    }).requestOtp(countryId: 'c', phone: '+963911111111');
    expect((limited as Err).failure, isA<RateLimitedFailure>());

    final invalid = await repo({
      'POST /api/v1/auth/otp/request': (_, _) async =>
          FakeBackend.error(400, ['phone must be longer than or equal to 4 characters']),
    }).requestOtp(countryId: 'c', phone: '12');
    expect((invalid as Err).failure, isA<InvalidPhoneNumber>());
  });

  test('successful verify persists tokens and returns the session', () async {
    final r = await repo({
      'POST /api/v1/auth/otp/verify': (_, _) async => FakeBackend.ok({
        'accessToken': 'a',
        'refreshToken': 'r',
        'isNewUser': true,
        'user': {'id': 'u1', 'phone': '+963911111111'},
      }),
    }).verifyOtp(countryId: 'c', phone: '+963911111111', code: '123456');
    expect(r, isA<Ok<Object?>>());
    expect(tokens.tokens?.refreshToken, 'r');
  });
}
