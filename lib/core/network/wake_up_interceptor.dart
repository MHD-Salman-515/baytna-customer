import 'dart:async';

import 'package:baytna_customer/core/network/server_status.dart';
import 'package:dio/dio.dart';

/// Handles Render free-tier cold starts:
///  * flags requests that are slower than [threshold] on [ServerStatus], so
///    the UI shows "waking up" instead of a spinner that looks stuck;
///  * retries 502/503/504 (what the proxy returns while the instance boots)
///    a few times with a delay, keeping the waking-up state on meanwhile.
///
/// Must be the FIRST interceptor so its timer covers the whole request,
/// including time spent queued behind a token refresh.
class WakeUpInterceptor extends Interceptor {
  WakeUpInterceptor({
    required this._dio,
    required this._status,
    required this.threshold,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
  });

  final Dio _dio;
  final ServerStatus _status;
  final Duration threshold;
  final int maxRetries;
  final Duration retryDelay;

  static const _trackerKey = 'wakeUp.tracker';
  static const _attemptKey = 'wakeUp.attempt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_trackerKey] = _Tracker(_status, threshold);
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _tracker(response.requestOptions)?.finish();
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final tracker = _tracker(options);
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    final status = err.response?.statusCode;
    final isColdStart = status == 502 || status == 503 || status == 504;

    if (!isColdStart || attempt >= maxRetries) {
      tracker?.finish();
      return handler.next(err);
    }

    tracker?.markSlow();
    await Future<void>.delayed(retryDelay);
    options.extra[_attemptKey] = attempt + 1;
    try {
      // The retry runs the full interceptor chain itself, so its outcome is
      // final: resolve/reject without re-running later interceptors.
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.reject(e);
    } finally {
      tracker?.finish();
    }
  }

  _Tracker? _tracker(RequestOptions options) =>
      options.extra[_trackerKey] as _Tracker?;
}

class _Tracker {
  _Tracker(this._status, Duration threshold) {
    _timer = Timer(threshold, markSlow);
  }

  final ServerStatus _status;
  late final Timer _timer;
  bool _slow = false;
  bool _done = false;

  void markSlow() {
    if (_slow || _done) return;
    _slow = true;
    _status.slowRequestStarted();
  }

  void finish() {
    if (_done) return;
    _done = true;
    _timer.cancel();
    if (_slow) _status.slowRequestEnded();
  }
}
