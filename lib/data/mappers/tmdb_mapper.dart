import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class TmdbMapper {
  static MetadataResult fromSearchResult(
    TmdbSearchResultDto dto,
    String barcode,
    String barcodeType,
  ) {
    final isTV = dto.mediaType == 'tv';
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: isTV ? MediaType.tv : MediaType.film,
      title: dto.effectiveTitle,
      coverUrl: dto.posterUrl,
      year: dto.effectiveYear,
      description: dto.overview,
      extraMetadata: {
        'tmdb_id': dto.id,
        if (isTV) 'media_type': 'tv' else 'media_type': 'film',
      },
      sourceApis: ['tmdb'],
      criticScore: dto.voteAverage, // TMDB is already 0-10 scale
      criticSource: dto.voteAverage != null ? 'TMDB' : null,
    );
  }
}
