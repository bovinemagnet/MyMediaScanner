import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Routes a media type to its fanart.tv endpoint and the `extraMetadata`
/// key that carries the external ID the endpoint needs:
///
/// - film  → `tmdb_id` (int)    → `/movies/{tmdb_id}`  → best poster
/// - tv    → `tvdb_id` (int)    → `/tv/{tvdb_id}`      → best poster
/// - music → `musicbrainz_release_group_id` (string)
///                               → `/music/albums/{mbid}` → best cover
///
/// Returns `null` when the media type has no fanart.tv endpoint or the
/// required external ID is missing. Network errors propagate to the caller.
abstract final class FanartLookupRouter {
  static Future<String?> fetchBestImageUrl(
    FanartApi api,
    MediaType? mediaType,
    Map<String, dynamic> extraMetadata,
  ) async {
    switch (mediaType) {
      case MediaType.film:
        final tmdbId = _asInt(extraMetadata['tmdb_id']);
        if (tmdbId == null) return null;
        final images = await api.getMovieImages(tmdbId);
        return images.bestPosterUrl;
      case MediaType.tv:
        final tvdbId = _asInt(extraMetadata['tvdb_id']);
        if (tvdbId == null) return null;
        final images = await api.getTvImages(tvdbId);
        return images.bestPosterUrl;
      case MediaType.music:
        final mbRgId = _asString(
          extraMetadata['musicbrainz_release_group_id'],
        );
        if (mbRgId == null) return null;
        final images = await api.getAlbumImages(mbRgId);
        return images.bestCoverUrl;
      default:
        return null;
    }
  }

  /// Defensively coerce cached JSON numerics back to `int`. `extraMetadata`
  /// round-trips through JSON where numeric fields may be deserialised as
  /// `double` on some platforms — a bare `as int?` cast would throw.
  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(Object? value) =>
      value is String ? value : value?.toString();
}
