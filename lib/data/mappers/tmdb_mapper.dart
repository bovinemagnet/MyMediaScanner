import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_movie_detail_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
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

  /// Returns the input result with collection (series) fields populated
  /// from a movie-detail response. Used after a search/find resolves to
  /// a single movie and we have an extra round-trip budget.
  static MetadataResult enrichWithMovieDetail(
    MetadataResult result,
    TmdbMovieDetailDto detail,
  ) {
    final collection = detail.belongsToCollection;
    if (collection?.id == null) return result;
    return result.copyWith(
      seriesExternalId: 'tmdb:${collection!.id}',
      seriesName: collection.name,
    );
  }

  static MetadataCandidate toCandidate(TmdbSearchResultDto dto) {
    final isTV = dto.mediaType == 'tv';
    return MetadataCandidate(
      sourceApi: 'tmdb',
      sourceId: dto.id?.toString() ?? '',
      title: dto.effectiveTitle ?? '',
      coverUrl: dto.posterUrl,
      year: dto.effectiveYear,
      mediaType: isTV ? MediaType.tv : MediaType.film,
    );
  }
}
