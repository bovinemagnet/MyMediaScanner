import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class TvdbMapper {
  static MetadataResult fromSeries(
    TvdbSeriesDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.tv,
      title: dto.name,
      description: dto.overview,
      coverUrl: dto.image,
      year: dto.effectiveYear,
      genres: dto.genres?.map((g) => g.name).whereType<String>().toList() ??
          [],
      extraMetadata: {
        'tvdb_id': dto.id,
        'tvdb_slug': dto.slug,
      },
      sourceApis: ['tvdb'],
    );
  }

  static MetadataResult fromSearchResult(
    TvdbSearchResultDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: dto.type == 'movie' ? MediaType.film : MediaType.tv,
      title: dto.name,
      description: dto.overview,
      coverUrl: dto.imageUrl,
      year: dto.effectiveYear,
      genres: dto.genres ?? [],
      extraMetadata: {
        'tvdb_id': dto.tvdbId,
        'tvdb_slug': dto.slug,
        'network': dto.network,
        'country': dto.country,
      },
      sourceApis: ['tvdb'],
    );
  }

  static MetadataCandidate toCandidate(TvdbSearchResultDto dto) {
    return MetadataCandidate(
      sourceApi: 'tvdb',
      sourceId: dto.tvdbId ?? '',
      title: dto.name ?? '',
      subtitle: dto.network,
      coverUrl: dto.imageUrl,
      year: dto.effectiveYear,
      mediaType: dto.type == 'movie' ? MediaType.film : MediaType.tv,
    );
  }
}
