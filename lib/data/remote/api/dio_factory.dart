import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Creates configured Dio instances for API clients.
class DioFactory {
  static Dio create({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: defaultHeaders,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(_SafeDebugLogInterceptor());
    }

    return dio;
  }

  /// Creates a Dio instance with an API key query parameter.
  static Dio createWithApiKey({
    required String baseUrl,
    required String apiKeyParam,
    required String apiKey,
    Map<String, String>? defaultHeaders,
  }) {
    final dio = create(baseUrl: baseUrl, defaultHeaders: defaultHeaders);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters[apiKeyParam] = apiKey;
        handler.next(options);
      },
    ));
    return dio;
  }

  /// Creates a Dio instance with a custom User-Agent header.
  ///
  /// Used for APIs like MusicBrainz that require application identification
  /// via User-Agent rather than an API key.
  static Dio createWithUserAgent({
    required String baseUrl,
    required String userAgent,
  }) {
    return create(
      baseUrl: baseUrl,
      defaultHeaders: {'User-Agent': userAgent},
    );
  }

  /// Creates a Dio instance configured for plain-text responses.
  ///
  /// Used for CDDB-style APIs like GnuDB whose wire format is plain text
  /// rather than JSON.
  static Dio createForPlainText({
    required String baseUrl,
    required String userAgent,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.plain,
        headers: {'User-Agent': userAgent},
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(_SafeDebugLogInterceptor());
    }
    return dio;
  }

  /// Creates a Dio instance with a Bearer token header.
  static Dio createWithBearerToken({
    required String baseUrl,
    required String token,
    Map<String, String>? defaultHeaders,
  }) {
    final headers = {
      'Authorization': 'Bearer $token',
      ...?defaultHeaders,
    };
    return create(baseUrl: baseUrl, defaultHeaders: headers);
  }

  /// Creates a Dio instance with a dynamic Bearer token resolved per-request.
  ///
  /// Used for APIs like TVDB where the token has a limited lifetime and
  /// must be refreshed periodically.
  static Dio createWithDynamicBearerToken({
    required String baseUrl,
    required Future<String> Function() tokenProvider,
  }) {
    final dio = create(baseUrl: baseUrl);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenProvider();
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
    return dio;
  }
}

/// Debug-only interceptor that logs method + path + status only.
///
/// Avoids the default Dio [LogInterceptor] which prints the full URI
/// (including `?api_key=…` query parameters) and request/response headers
/// (including `Authorization: Bearer …`).
class _SafeDebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[Dio] → ${options.method} ${options.baseUrl}${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    debugPrint('[Dio] ← ${response.statusCode} ${req.method} ${req.baseUrl}${req.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final status = err.response?.statusCode;
    debugPrint('[Dio] ✗ ${status ?? err.type} ${req.method} ${req.baseUrl}${req.path}');
    handler.next(err);
  }
}
