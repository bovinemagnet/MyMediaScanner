/// Domain mirror of a `tmdb_account_sync_items` row.
class TmdbBridgeItem {
  const TmdbBridgeItem({
    required this.id,
    this.mediaItemId,
    required this.tmdbId,
    required this.mediaType,
    this.title,
    this.posterPath,
    this.tmdbRating,
    this.watchlist = false,
    this.favorite = false,
    this.listIds = const [],
    this.lastPulledAt,
    this.lastError,
  });

  final String id;
  final String? mediaItemId;
  final int tmdbId;
  final String mediaType;
  final String? title;
  final String? posterPath;
  final double? tmdbRating; // raw 0.5–10
  final bool watchlist;
  final bool favorite;
  final List<int> listIds;
  final DateTime? lastPulledAt;
  final String? lastError;

  /// Convenience accessor for UI: rating on the local 0–5 scale.
  double? get localRating =>
      tmdbRating == null ? null : tmdbRating! / 2;
}
