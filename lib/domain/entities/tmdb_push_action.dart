/// Discrete TMDB push operations. The repository's push pipeline derives
/// the list of pending actions from the bridge row's delta against its
/// last-pushed snapshot.
sealed class TmdbPushAction {
  const TmdbPushAction();
}

class PushRating extends TmdbPushAction {
  const PushRating(this.value);
  final double value; // 0.5–10
}

class RemoveRating extends TmdbPushAction {
  const RemoveRating();
}

class PushWatchlist extends TmdbPushAction {
  const PushWatchlist(this.value);
  final bool value;
}

class PushFavorite extends TmdbPushAction {
  const PushFavorite(this.value);
  final bool value;
}

class PushOwnership extends TmdbPushAction {
  const PushOwnership(this.add);
  /// `true` to add the item to the MyMediaScanner list, `false` to remove.
  final bool add;
}
