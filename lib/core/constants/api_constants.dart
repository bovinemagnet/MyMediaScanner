abstract final class ApiConstants {
  // TMDB
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Discogs
  static const discogsBaseUrl = 'https://api.discogs.com';

  // Google Books
  static const googleBooksBaseUrl = 'https://www.googleapis.com/books/v1';

  // Open Library
  static const openLibraryBaseUrl = 'https://openlibrary.org';
  static const openLibraryCoverUrl = 'https://covers.openlibrary.org';

  // TVDB
  static const tvdbBaseUrl = 'https://api4.thetvdb.com/v4';

  // TheAudioDB
  static const theAudioDbBaseUrl = 'https://www.theaudiodb.com/api/v1/json';

  // fanart.tv
  static const fanartBaseUrl = 'https://webservice.fanart.tv/v3';

  // MusicBrainz + Cover Art Archive
  static const musicBrainzBaseUrl = 'https://musicbrainz.org/ws/2';
  static const coverArtArchiveBaseUrl = 'https://coverartarchive.org';

  /// App version used in outbound User-Agent strings. Updated by release
  /// tooling; should match `pubspec.yaml`.
  static const appVersion = '1.0.0';

  /// MusicBrainz requires identifying the client in a User-Agent string
  /// so the maintainer can be contacted about excessive traffic.
  static String musicBrainzUserAgent() =>
      'MyMediaScanner/$appVersion '
      '(https://github.com/bovinemagnet/MyMediaScanner)';

  // UPCitemdb
  static const upcItemDbBaseUrl = 'https://api.upcitemdb.com/prod/trial';

  // IGDB (Twitch-authenticated games database)
  static const igdbBaseUrl = 'https://api.igdb.com/v4';
  static const twitchOAuthBaseUrl = 'https://id.twitch.tv';

  // GnuDB — CDDB-compatible disc metadata lookup. The service is HTTP only.
  static const gnudbBaseUrl = 'http://gnudb.gnudb.org';
  static const gnudbCgiPath = '/~cddb/cddb.cgi';
  static const gnudbDefaultUser = 'mymediascanner';
  static const gnudbClientName = 'MyMediaScanner';
  static const gnudbClientVersion = '1.0';
  static const gnudbUserAgent =
      'MyMediaScanner/1.0 (https://github.com/bovinemagnet/MyMediaScanner)';

  // Cache
  static const cacheDurationDays = 7;
}
