import 'dart:async';

/// Enforces a minimum interval between successive calls.
///
/// Used to comply with API rate limits (e.g. MusicBrainz requires
/// a maximum of 1 request per second).
///
/// Concurrency-safe: N parallel callers serialise into a chain so each
/// proceeds [minInterval] after the previous, instead of all observing
/// the same `_lastCall` snapshot and proceeding simultaneously.
class RateLimiter {
  RateLimiter({required this.minInterval});

  final Duration minInterval;

  /// Future that resolves when the *next* caller is allowed to proceed.
  /// Each [throttle] gates on the previous value of this field, then
  /// installs its own gate that opens [minInterval] later.
  Future<void> _gate = Future<void>.value();

  /// Waits until [minInterval] has elapsed since the previous caller
  /// proceeded. The first call after construction always completes
  /// immediately (modulo a microtask hop).
  Future<void> throttle() {
    final previous = _gate;
    final readyForNext = Completer<void>();
    _gate = readyForNext.future;

    return previous.then((_) {
      // We are now allowed to proceed. Open the gate for the next caller
      // [minInterval] from now — not from when the previous caller
      // returned, so a burst of N parallel calls fans out at the
      // intended cadence rather than collapsing to a single window.
      Timer(minInterval, () {
        if (!readyForNext.isCompleted) readyForNext.complete();
      });
    });
  }
}
