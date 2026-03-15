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
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
      ));
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
}
