import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('first call completes immediately', () async {
      final limiter = RateLimiter(minInterval: const Duration(seconds: 1));
      final sw = Stopwatch()..start();
      await limiter.throttle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('second call within interval is delayed', () async {
      final limiter = RateLimiter(minInterval: const Duration(milliseconds: 200));
      await limiter.throttle();
      final sw = Stopwatch()..start();
      await limiter.throttle();
      sw.stop();
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(150));
    });

    test('second call after interval completes immediately', () async {
      final limiter = RateLimiter(minInterval: const Duration(milliseconds: 50));
      await limiter.throttle();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final sw = Stopwatch()..start();
      await limiter.throttle();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });
}
