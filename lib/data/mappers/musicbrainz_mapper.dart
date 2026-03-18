import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class MusicBrainzMapper {
  static MetadataResult fromRelease(
    MusicBrainzReleaseDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.music,
      title: dto.title,
      subtitle: dto.effectiveArtist,
      coverUrl: dto.coverUrl,
      year: dto.effectiveYear,
      publisher: dto.effectiveLabel,
      format: dto.effectiveFormat,
      genres: dto.tags?.map((t) => t.name).whereType<String>().toList() ?? [],
      extraMetadata: {
        'musicbrainz_release_id': dto.id,
        'musicbrainz_release_group_id': dto.releaseGroupId,
        'artists': dto.artistCredit
                ?.map((c) => c.name ?? c.artist?.name)
                .whereType<String>()
                .toList() ??
            [],
        'catalogue_number': dto.labelInfo?.firstOrNull?.catalogNumber,
        'label': dto.effectiveLabel,
        'country': dto.country,
        'track_listing': dto.media
                ?.expand((m) => m.tracks ?? <MusicBrainzTrackDto>[])
                .map((t) => {
                      'position': t.number,
                      'title': t.title,
                      'duration_ms': t.length,
                    })
                .toList() ??
            [],
      },
      sourceApis: ['musicbrainz'],
    );
  }

  static MetadataCandidate toCandidate(MusicBrainzReleaseDto dto) {
    return MetadataCandidate(
      sourceApi: 'musicbrainz',
      sourceId: dto.id ?? '',
      title: dto.title ?? '',
      subtitle: dto.effectiveArtist,
      coverUrl: dto.coverUrl,
      year: dto.effectiveYear,
      format: dto.effectiveFormat,
      mediaType: MediaType.music,
    );
  }
}
