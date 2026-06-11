/// TMDB API media-type string constants and checks.
///
/// TMDB endpoints and the account-sync bridge identify titles by an
/// integer ID plus a media-type string ('movie' or 'tv'). The mappers
/// persist that string under `extraMetadata['media_type']`, so call sites
/// reading it back should use these helpers instead of raw literals.
abstract final class TmdbMediaType {
  /// TMDB media-type string for films.
  static const String movie = 'movie';

  /// TMDB media-type string for TV series.
  static const String tv = 'tv';

  /// True when [raw] is the TMDB movie media-type string.
  static bool isTmdbMovie(Object? raw) => raw == movie;

  /// True when [raw] is the TMDB TV media-type string.
  static bool isTmdbTv(Object? raw) => raw == tv;

  /// True when [raw] is a media-type string TMDB account features support.
  static bool isTmdbMovieOrTv(Object? raw) => raw == movie || raw == tv;
}
