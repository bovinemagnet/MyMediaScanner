/// Maps GnuDB DTOs into MyMediaScanner domain objects.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

/// Builds [MetadataResult]s and [MetadataCandidate]s from [GnudbDiscDto]s.
abstract final class GnudbMapper {
  /// Converts a fully-resolved GnuDB disc into a [MetadataResult].
  ///
  /// [category] is the GnuDB genre bucket the entry was found under (e.g.
  /// `rock`, `classical`). It is retained in `extraMetadata` so it can be
  /// round-tripped back to the API for re-reads.
  static MetadataResult toMetadataResult(
    GnudbDiscDto dto, {
    required String category,
  }) {
    final trackListing = <Map<String, dynamic>>[
      for (var i = 0; i < dto.trackTitles.length; i++)
        {
          'position': i + 1,
          'title': dto.trackTitles[i],
        },
    ];

    return MetadataResult(
      barcode: 'gnudb:${dto.discId}',
      barcodeType: 'cddb',
      mediaType: MediaType.music,
      title: dto.albumTitle,
      subtitle: dto.artist,
      year: dto.year,
      genres: (dto.genre == null || dto.genre!.isEmpty) ? const [] : [dto.genre!],
      extraMetadata: {
        'gnudb_disc_id': dto.discId,
        'gnudb_category': category,
        'gnudb_track_titles': dto.trackTitles,
        if (dto.extendedAlbum != null && dto.extendedAlbum!.isNotEmpty)
          'gnudb_album_notes': dto.extendedAlbum,
        'track_listing': trackListing,
      },
      sourceApis: const ['gnudb'],
    );
  }

  /// Lighter-weight candidate used by disambiguation UIs.
  static MetadataCandidate toCandidate(
    GnudbDiscDto dto, {
    required String category,
  }) {
    return MetadataCandidate(
      sourceApi: 'gnudb',
      sourceId: '$category:${dto.discId}',
      title: dto.albumTitle,
      subtitle: dto.artist,
      year: dto.year,
      mediaType: MediaType.music,
    );
  }
}
