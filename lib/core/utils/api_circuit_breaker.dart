/// A simple circuit breaker that disables an API after a rate-limit (429)
/// response, preventing repeated doomed requests.
///
/// Once tripped, the breaker stays open for [cooldownDuration] before
/// allowing a single probe request. If the probe succeeds the breaker
/// resets; if it fails the cooldown restarts.
class ApiCircuitBreaker {
  ApiCircuitBreaker({
    this.cooldownDuration = const Duration(minutes: 15),
  });

  final Duration cooldownDuration;

  DateTime? _trippedAt;

  /// Whether requests should be allowed through.
  bool get isOpen {
    if (_trippedAt == null) return true;
    final elapsed = DateTime.now().difference(_trippedAt!);
    return elapsed >= cooldownDuration;
  }

  /// Record a rate-limit failure — opens the breaker.
  void trip() {
    _trippedAt = DateTime.now();
  }

  /// Record a successful response — resets the breaker.
  void reset() {
    _trippedAt = null;
  }
}
