import 'package:dio/dio.dart';
import 'package:mymediascanner/core/utils/rate_limiter.dart';

/// Thrown when the upstream API explicitly signals throttling (HTTP 503).
///
/// Callers should treat this as "back off now, try later" rather than
/// a hard failure — it usually means the provider wants fewer requests
/// per unit time, not that the resource is missing.
class RateLimitExceededException implements Exception {
  const RateLimitExceededException(this.endpoint, {this.retryAfter});

  final String endpoint;
  final Duration? retryAfter;

  @override
  String toString() =>
      'RateLimitExceededException(endpoint: $endpoint, retryAfter: $retryAfter)';
}

/// Wraps a [RateLimiter] with awareness of provider-side 503 responses.
///
/// - Pre-throttles calls to honour the provider's documented rate.
/// - Detects HTTP 503 responses and flips [isRateLimited] for
///   [rateLimitCooldown]; callers can skip non-critical follow-up calls
///   while the flag is set.
class RateLimitAwareClient {
  RateLimitAwareClient({
    required Duration minInterval,
    Duration rateLimitCooldown = const Duration(seconds: 10),
  })  : _limiter = RateLimiter(minInterval: minInterval),
        _cooldown = rateLimitCooldown;

  final RateLimiter _limiter;
  final Duration _cooldown;
  DateTime? _rateLimitedUntil;

  bool get isRateLimited {
    final until = _rateLimitedUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _rateLimitedUntil = null;
      return false;
    }
    return true;
  }

  Future<T> run<T>(Future<T> Function() inner) async {
    await _limiter.throttle();
    try {
      return await inner();
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        _rateLimitedUntil = DateTime.now().add(_cooldown);
        final retryAfter = _parseRetryAfter(
          e.response?.headers.value('retry-after'),
        );
        throw RateLimitExceededException(
          e.requestOptions.path,
          retryAfter: retryAfter,
        );
      }
      rethrow;
    }
  }

  Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }
}
