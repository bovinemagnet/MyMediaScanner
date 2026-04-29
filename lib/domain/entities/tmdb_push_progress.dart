/// Live progress of a `RetryPushUseCase` invocation. Held by a
/// `Notifier<TmdbPushProgress>` so the dialog header (and any other
/// listener) can render a determinate progress bar.
class TmdbPushProgress {
  const TmdbPushProgress({
    required this.inFlight,
    required this.current,
    required this.total,
  });

  factory TmdbPushProgress.idle() =>
      const TmdbPushProgress(inFlight: false, current: 0, total: 0);

  final bool inFlight;
  final int current;
  final int total;

  TmdbPushProgress copyWith({bool? inFlight, int? current, int? total}) =>
      TmdbPushProgress(
        inFlight: inFlight ?? this.inFlight,
        current: current ?? this.current,
        total: total ?? this.total,
      );

  @override
  bool operator ==(Object other) =>
      other is TmdbPushProgress &&
      other.inFlight == inFlight &&
      other.current == current &&
      other.total == total;

  @override
  int get hashCode => Object.hash(inFlight, current, total);
}
