import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_rate_limit_interceptor.dart';

class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.responses);

  final List<int> responses; // status codes in order
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final status = responses[calls.clamp(0, responses.length - 1)];
    calls++;
    return ResponseBody.fromString(
      '{}',
      status,
      headers: status == 429 ? {'retry-after': ['0']} : {},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('429 with Retry-After is retried up to maxRetries', () async {
    final adapter = _CountingAdapter([429, 429, 200]);
    final interceptor = TmdbAccountRateLimitInterceptor(maxRetries: 3);
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter
      ..interceptors.add(interceptor);
    interceptor.attachDio(dio);

    final res = await dio.get<dynamic>('/');

    expect(res.statusCode, 200);
    expect(adapter.calls, 3, reason: '429, 429, 200');
  });

  test('after maxRetries the last 429 is surfaced', () async {
    final adapter = _CountingAdapter([429, 429, 429, 429]);
    final interceptor = TmdbAccountRateLimitInterceptor(maxRetries: 2);
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter
      ..interceptors.add(interceptor);
    interceptor.attachDio(dio);

    DioException? error;
    try {
      await dio.get<dynamic>('/');
    } on DioException catch (e) {
      error = e;
    }
    expect(error?.response?.statusCode, 429);
    expect(adapter.calls, 3, reason: 'initial + 2 retries');
  });
}
