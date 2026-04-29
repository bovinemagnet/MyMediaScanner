/// View-model rendered by [TmdbPendingChangesDialog]. Composed in
/// memory from a bridge row; pure Dart so it can be unit-tested in
/// isolation.
class TmdbPendingChange {
  const TmdbPendingChange({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.actions,
    required this.lastPushedAt,
    required this.lastError,
  });

  final int tmdbId;
  final String mediaType;

  /// Best-effort local title (from `titleSnapshot` on the bridge row,
  /// or null when no title was ever stored).
  final String? title;

  /// Chips to render — empty list when the row is dirty for an unknown
  /// reason (the dialog renders a generic "Pending change" pill).
  final List<TmdbPendingAction> actions;

  /// Epoch ms of the last push attempt, or null if never attempted.
  final int? lastPushedAt;

  /// Persisted error from the last push attempt; null when none or
  /// when the error has been cleared.
  final String? lastError;

  bool get hasFailed => lastError != null;
}

/// Sealed action chip type. Each value carries any data the chip
/// needs to render itself.
sealed class TmdbPendingAction {
  const TmdbPendingAction();

  const factory TmdbPendingAction.rating(double value) =
      TmdbPendingActionRating;
  const factory TmdbPendingAction.watchlist() = TmdbPendingActionWatchlist;
  const factory TmdbPendingAction.favourite() = TmdbPendingActionFavourite;
}

class TmdbPendingActionRating extends TmdbPendingAction {
  const TmdbPendingActionRating(this.value);
  final double value;

  @override
  bool operator ==(Object other) =>
      other is TmdbPendingActionRating && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class TmdbPendingActionWatchlist extends TmdbPendingAction {
  const TmdbPendingActionWatchlist();

  @override
  bool operator ==(Object other) => other is TmdbPendingActionWatchlist;

  @override
  int get hashCode => 1;
}

class TmdbPendingActionFavourite extends TmdbPendingAction {
  const TmdbPendingActionFavourite();

  @override
  bool operator ==(Object other) => other is TmdbPendingActionFavourite;

  @override
  int get hashCode => 2;
}

/// Pure helper: derive the action chip list from the current bridge
/// row state. Order is stable so tests can match exact lists.
List<TmdbPendingAction> derivePendingActions({
  required bool watchlist,
  required bool favorite,
  required double? localRatingSnapshot,
}) {
  return [
    if (localRatingSnapshot != null)
      TmdbPendingAction.rating(localRatingSnapshot),
    if (watchlist) const TmdbPendingAction.watchlist(),
    if (favorite) const TmdbPendingAction.favourite(),
  ];
}
