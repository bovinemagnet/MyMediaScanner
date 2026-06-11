/// Maps GnuDB discs into MyMediaScanner domain objects.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

/// Builds [MetadataResult]s and [MetadataCandidate]s from [GnudbDisc]s.
abstract final class GnudbMapper {
  /// Converts a fully-resolved GnuDB disc into a [MetadataResult].
  ///
  /// [category] is the GnuDB genre bucket the entry was found under (e.g.
  /// `rock`, `classical`). It is retained in `extraMetadata` so it can be
  /// round-tripped back to the API for re-reads.
  static MetadataResult toMetadataResult(
    GnudbDisc disc, {
    required String category,
  }) {
    final trackListing = <Map<String, dynamic>>[
      for (var i = 0; i < disc.trackTitles.length; i++)
        {
          'position': i + 1,
          'title': disc.trackTitles[i],
        },
    ];

    return MetadataResult(
      barcode: 'gnudb:${disc.discId}',
      barcodeType: 'cddb',
      mediaType: MediaType.music,
      title: disc.albumTitle,
      subtitle: disc.artist,
      year: disc.year,
      genres:
          (disc.genre == null || disc.genre!.isEmpty) ? const [] : [disc.genre!],
      extraMetadata: {
        'gnudb_disc_id': disc.discId,
        'gnudb_category': category,
        'gnudb_track_titles': disc.trackTitles,
        if (disc.extendedAlbum != null && disc.extendedAlbum!.isNotEmpty)
          'gnudb_album_notes': disc.extendedAlbum,
        'track_listing': trackListing,
      },
      sourceApis: const ['gnudb'],
    );
  }

  /// Lighter-weight candidate used by disambiguation UIs.
  static MetadataCandidate toCandidate(
    GnudbDisc disc, {
    required String category,
  }) {
    return MetadataCandidate(
      sourceApi: 'gnudb',
      sourceId: '$category:${disc.discId}',
      title: disc.albumTitle,
      subtitle: disc.artist,
      year: disc.year,
      mediaType: MediaType.music,
    );
  }
}
