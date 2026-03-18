import 'package:mymediascanner/data/remote/api/theaudiodb/models/theaudiodb_album_dto.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

/// Merges enrichment data from TheAudioDB and fanart.tv into an existing
/// [MetadataResult] without overwriting existing non-null values.
abstract final class EnrichmentMerger {
  /// Merge TheAudioDB album data into the result.
  ///
  /// Upgrades [criticScore] and [criticSource] if not already set,
  /// and adds review text and additional artwork to [extraMetadata].
  static MetadataResult mergeAudioDb(
    MetadataResult base,
    TheAudioDbAlbumDto audioDb,
  ) {
    final extra = Map<String, dynamic>.from(base.extraMetadata);

    if (audioDb.strDescriptionEN != null) {
      extra['theaudiodb_description'] = audioDb.strDescriptionEN;
    }
    if (audioDb.strReview != null) {
      extra['theaudiodb_review'] = audioDb.strReview;
    }
    if (audioDb.idAlbum != null) {
      extra['theaudiodb_id'] = audioDb.idAlbum;
    }

    return base.copyWith(
      // Only upgrade cover if we don't already have one
      coverUrl: base.coverUrl ?? audioDb.strAlbumThumb,
      // Only set critic score if not already present
      criticScore: base.criticScore ?? audioDb.effectiveScore,
      criticSource: base.criticSource ??
          (audioDb.effectiveScore != null ? 'TheAudioDB' : null),
      // Merge description if not present
      description: base.description ?? audioDb.strDescriptionEN,
      extraMetadata: extra,
    );
  }

  /// Merge fanart.tv artwork into the result.
  ///
  /// Upgrades [coverUrl] if the existing cover is missing or is a
  /// low-resolution placeholder.
  static MetadataResult mergeFanartCover(
    MetadataResult base,
    String? fanartCoverUrl,
  ) {
    if (fanartCoverUrl == null) return base;
    // Only upgrade if we don't have a cover, or current cover is from
    // Cover Art Archive (lower quality).
    final currentCover = base.coverUrl;
    if (currentCover == null || currentCover.contains('coverartarchive.org')) {
      return base.copyWith(coverUrl: fanartCoverUrl);
    }
    return base;
  }
}
