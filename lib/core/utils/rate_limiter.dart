/// Enforces a minimum interval between successive calls.
///
/// Used to comply with API rate limits (e.g. MusicBrainz requires
/// a maximum of 1 request per second).
class RateLimiter {
  RateLimiter({required this.minInterval});

  final Duration minInterval;
  DateTime? _lastCall;

  /// Waits until [minInterval] has elapsed since the last call.
  /// The first call always completes immediately.
  Future<void> throttle() async {
    final now = DateTime.now();
    if (_lastCall != null) {
      final elapsed = now.difference(_lastCall!);
      if (elapsed < minInterval) {
        await Future<void>.delayed(minInterval - elapsed);
      }
    }
    _lastCall = DateTime.now();
  }
}
