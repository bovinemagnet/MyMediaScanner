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
    final artistIds = dto.artistCredit
            ?.map((c) => c.artist?.id)
            .whereType<String>()
            .toList() ??
        const <String>[];
    final artistNames = dto.artistCredit
            ?.map((c) => c.name ?? c.artist?.name)
            .whereType<String>()
            .toList() ??
        const <String>[];
    final primaryMedia = dto.media?.firstOrNull;
    final trackListing = dto.media
            ?.expand((m) => m.tracks ?? const <MusicBrainzTrackDto>[])
            .map((t) => <String, dynamic>{
                  'position': t.number,
                  'title': t.title,
                  'duration_ms': t.length,
                })
            .toList() ??
        const <Map<String, dynamic>>[];

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
      genres:
          dto.tags?.map((t) => t.name).whereType<String>().toList() ?? const [],
      extraMetadata: {
        'musicbrainz_release_id': dto.id,
        'musicbrainz_release_group_id': dto.releaseGroupId,
        'musicbrainz_artist_ids': artistIds,
        'artists': artistNames,
        'catalogue_number': dto.labelInfo?.firstOrNull?.catalogNumber,
        'label': dto.effectiveLabel,
        'country': dto.country,
        'release_date': dto.date,
        'release_country': dto.country,
        'packaging': dto.packaging,
        'status': dto.status,
        'track_count': primaryMedia?.trackCount ?? dto.trackCount,
        'disc_count': primaryMedia?.discCount,
        'track_listing': trackListing,
      },
      sourceApis: const ['musicbrainz'],
      seriesExternalId:
          dto.releaseGroupId != null ? 'mb:${dto.releaseGroupId}' : null,
      seriesName: dto.releaseGroup?.title,
    );
  }

  static MetadataCandidate toCandidate(MusicBrainzReleaseDto dto) {
    final primaryMedia = dto.media?.firstOrNull;
    return MetadataCandidate(
      sourceApi: 'musicbrainz',
      sourceId: dto.id ?? '',
      title: dto.title ?? '',
      subtitle: dto.effectiveArtist,
      coverUrl: dto.coverUrl,
      year: dto.effectiveYear,
      format: dto.effectiveFormat,
      mediaType: MediaType.music,
      country: dto.country,
      label: dto.effectiveLabel,
      catalogueNumber: dto.labelInfo?.firstOrNull?.catalogNumber,
      trackCount: primaryMedia?.trackCount ?? dto.trackCount,
      status: dto.status,
      packaging: dto.packaging,
    );
  }
}
