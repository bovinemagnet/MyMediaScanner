/// Identifies which TMDB account-state bucket a bridge row belongs to.
enum TmdbBridgeBucket { watchlist, rated, favourite }

/// Composite key used by the bridge table to identify a TMDB title.
class TmdbBridgeKey {
  const TmdbBridgeKey({required this.tmdbId, required this.mediaType});

  final int tmdbId;
  final String mediaType; // 'movie' or 'tv'

  @override
  bool operator ==(Object other) =>
      other is TmdbBridgeKey &&
      other.tmdbId == tmdbId &&
      other.mediaType == mediaType;

  @override
  int get hashCode => Object.hash(tmdbId, mediaType);
}
