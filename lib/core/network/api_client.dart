import 'package:baytna_customer/core/network/auth_interceptor.dart';
import 'package:baytna_customer/core/network/envelope_interceptor.dart';
import 'package:baytna_customer/core/network/error_mapper.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/core/network/paged.dart';
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
  }) async => decode(
    (await _send('GET', path, query: query, headers: headers, authenticated: authenticated)).data,
  );

  /// GET for paginated endpoints: the items in `data` plus the `meta` that
  /// the envelope carries alongside it.
  Future<Paged<T>> getPage<T>(
    String path, {
    required ItemDecoder<T> decodeItem,
    Map<String, Object?>? query,
    bool authenticated = true,
  }) async {
    final response = await _send('GET', path, query: query, authenticated: authenticated);
    final items = asJsonList(response.data).map(decodeItem).toList(growable: false);
    return Paged(
      items: items,
      meta: PageMeta.fromJson(response.extra[EnvelopeInterceptor.metaKey], itemCount: items.length),
    );
  }

  Future<T> post<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) async => decode((await _send('POST', path, body: body, authenticated: authenticated)).data);

  Future<T> patch<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) async => decode((await _send('PATCH', path, body: body, authenticated: authenticated)).data);

  Future<T> delete<T>(
    String path, {
    required Decoder<T> decode,
    Object? body,
    bool authenticated = true,
  }) async => decode((await _send('DELETE', path, body: body, authenticated: authenticated)).data);

  /// For endpoints whose payload is irrelevant (e.g. 204 No Content).
  static void ignore(Object? _) {}

  Future<Response<dynamic>> _send(
    String method,
    String path, {
    required bool authenticated,
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.request<dynamic>(
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
  }
}
