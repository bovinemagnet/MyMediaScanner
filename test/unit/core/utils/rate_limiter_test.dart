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

    test(
      'concurrent callers serialise — three parallel throttles fan out at minInterval',
      () async {
        // Regression test for the race where every concurrent caller
        // observed the same _lastCall snapshot and all proceeded
        // simultaneously, violating the upstream rate limit.
        final limiter =
            RateLimiter(minInterval: const Duration(milliseconds: 100));

        // Prime the limiter so the first call's "always immediate"
        // behaviour doesn't mask the test.
        await limiter.throttle();

        final sw = Stopwatch()..start();
        final completionTimes = <int>[];

        await Future.wait([
          limiter.throttle().then((_) => completionTimes.add(sw.elapsedMilliseconds)),
          limiter.throttle().then((_) => completionTimes.add(sw.elapsedMilliseconds)),
          limiter.throttle().then((_) => completionTimes.add(sw.elapsedMilliseconds)),
        ]);

        completionTimes.sort();
        // First fan-out call lands ~100 ms in (one minInterval after the
        // priming call). Second ~200 ms. Third ~300 ms. Generous bounds
        // to absorb scheduler jitter on CI runners.
        expect(completionTimes[0], greaterThanOrEqualTo(80));
        expect(completionTimes[1], greaterThanOrEqualTo(180));
        expect(completionTimes[2], greaterThanOrEqualTo(280));
      },
    );
  });
}
