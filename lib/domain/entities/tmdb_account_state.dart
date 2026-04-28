/// Account-state payload for a single TMDB title — read from
/// `/movie/{id}/account_states` or `/tv/{id}/account_states`.
class TmdbAccountState {
  const TmdbAccountState({
    required this.tmdbId,
    required this.mediaType,
    this.watchlist = false,
    this.favorite = false,
    this.rating,
    this.listIds = const [],
  });

  final int tmdbId;
  final String mediaType; // 'movie' or 'tv'
  final bool watchlist;
  final bool favorite;
  final double? rating; // raw 0.5–10
  final List<int> listIds;
}
