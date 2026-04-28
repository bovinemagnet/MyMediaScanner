import 'dart:async';

import 'package:dio/dio.dart';

/// Intercepts TMDB account API responses.
///
/// On a 429 response, waits for the duration specified in the
/// `Retry-After` header (or an exponential fallback of 1s/2s/4s) and
/// retries up to [maxRetries] times. Falls through any other status.
///
/// Also caps in-flight requests to [maxConcurrent] using a semaphore
/// — TMDB suggests staying well under 40 req/s.
///
/// Pass the owning [Dio] instance so that retries reuse its
/// `httpClientAdapter` (important for testing with mock adapters).
class TmdbAccountRateLimitInterceptor extends Interceptor {
  TmdbAccountRateLimitInterceptor({
    this.maxRetries = 3,
    this.maxConcurrent = 5,
    Dio? dio,
  })  : _semaphore = _Semaphore(maxConcurrent),
        _dio = dio;

  final int maxRetries;
  final int maxConcurrent;

  final _Semaphore _semaphore;

  /// The [Dio] instance that owns this interceptor. When set, retries
  /// are performed through it so that the same [HttpClientAdapter] is
  /// reused (e.g. mock adapters in tests).
  Dio? _dio;

  /// Called by [TmdbAccountApiClient] after adding this interceptor so
  /// that retry calls reuse the same [HttpClientAdapter].
  // ignore: use_setters_to_change_properties
  void attachDio(Dio dio) => _dio = dio;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    await _semaphore.acquire();
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _semaphore.release();
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    _semaphore.release();

    final response = err.response;
    if (response?.statusCode != 429) {
      handler.next(err);
      return;
    }
    final attempts =
        (err.requestOptions.extra['retry_attempts'] as int?) ?? 0;
    if (attempts >= maxRetries) {
      handler.next(err);
      return;
    }

    final retryAfter =
        _parseRetryAfter(response!.headers.value('retry-after'));
    final backoff = retryAfter ?? Duration(seconds: 1 << attempts);
    await Future<void>.delayed(backoff);

    final retryOptions = err.requestOptions.copyWith(
      extra: {
        ...err.requestOptions.extra,
        'retry_attempts': attempts + 1,
      },
    );
    try {
      final dio = _dio ?? _buildDio(retryOptions);
      final retried = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header.trim());
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }

  Dio _buildDio(RequestOptions retryOptions) {
    final dio = Dio(BaseOptions(
      baseUrl: retryOptions.baseUrl,
      headers: retryOptions.headers,
    ));
    // Reuse the same interceptor so further 429s also retry.
    dio.interceptors.add(this);
    return dio;
  }
}

/// A simple counting semaphore. Not fair, but fine for one-process
/// HTTP client usage.
class _Semaphore {
  _Semaphore(this._capacity);

  int _capacity;
  final _waiters = <Completer<void>>[];

  Future<void> acquire() {
    if (_capacity > 0) {
      _capacity--;
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      _capacity++;
    }
  }
}
