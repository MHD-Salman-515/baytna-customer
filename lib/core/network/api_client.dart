import 'package:baytna_customer/core/network/auth_interceptor.dart';
import 'package:baytna_customer/core/network/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

typedef Decoder<T> = T Function(Object? data);

/// The only HTTP entry point for feature code.
///
/// * `decode` receives the already-unwrapped `data` payload (never the envelope).
/// * Every error is thrown as a typed `Failure`; a DioException never escapes.
/// * `authenticated: false` for public endpoints (countries, OTP).
@lazySingleton
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    required Decoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    bool authenticated = true,
  }) => _send('GET', path, decode, query: query, headers: headers, authenticated: authenticated);

  Future<T> post<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) => _send('POST', path, decode, body: body, authenticated: authenticated);

  Future<T> patch<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) => _send('PATCH', path, decode, body: body, authenticated: authenticated);

  Future<T> delete<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) => _send('DELETE', path, decode, body: body, authenticated: authenticated);

  /// For endpoints whose payload is irrelevant (e.g. 204 No Content).
  static void ignore(Object? _) {}

  Future<T> _send<T>(
    String method,
    String path,
    Decoder<T> decode, {
    required bool authenticated,
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: headers,
          extra: {if (!authenticated) AuthInterceptor.skipAuth: true},
        ),
      );
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
    return decode(response.data);
  }
}
