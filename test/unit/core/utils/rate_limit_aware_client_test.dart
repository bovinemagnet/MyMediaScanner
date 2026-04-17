import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';

void main() {
  group('RateLimitAwareClient', () {
    test('first call passes straight through the inner function', () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 10),
      );
      var calls = 0;
      final result = await client.run(() async {
        calls += 1;
        return 'ok';
      });
      expect(result, 'ok');
      expect(calls, 1);
    });

    test('503 response flips rate-limited flag and surfaces typed error',
        () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 1),
      );
      expect(client.isRateLimited, isFalse);

      Future<String> failing() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );
      }

      await expectLater(
        client.run<String>(failing),
        throwsA(isA<RateLimitExceededException>()),
      );
      expect(client.isRateLimited, isTrue);
    });

    test('clears rate-limited flag after back-off window', () async {
      final client = RateLimitAwareClient(
        minInterval: const Duration(milliseconds: 1),
        rateLimitCooldown: const Duration(milliseconds: 5),
      );

      Future<String> failing() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );
      }

      await expectLater(
        client.run<String>(failing),
        throwsA(isA<RateLimitExceededException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(client.isRateLimited, isFalse);
    });
  });
}
