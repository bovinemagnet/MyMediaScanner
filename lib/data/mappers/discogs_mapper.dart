import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class DiscogsMapper {
  static MetadataResult fromRelease(
    DiscogsReleaseDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.music,
      title: dto.title,
      coverUrl: dto.primaryImageUrl,
      year: dto.year,
      publisher: dto.labelName,
      genres: dto.genres ?? [],
      extraMetadata: {
        'discogs_release_id': dto.id,
        'artists': dto.artists?.map((a) => a.name).toList() ?? [],
        'catalogue_number': dto.catno,
        'label': dto.labelName,
        'track_listing': dto.tracklist
                ?.map((t) => {
                      'position': t.position,
                      'title': t.title,
                      'duration': t.duration,
                    })
                .toList() ??
            [],
      },
      sourceApis: ['discogs'],
    );
  }
}
