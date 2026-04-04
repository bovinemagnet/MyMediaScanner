import 'package:json_annotation/json_annotation.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';

part 'tmdb_find_result_dto.g.dart';

/// Response from TMDB `/find/{external_id}` endpoint.
@JsonSerializable()
class TmdbFindResponseDto {
  const TmdbFindResponseDto({this.movieResults, this.tvResults});

  factory TmdbFindResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbFindResponseDtoFromJson(json);

  @JsonKey(name: 'movie_results')
  final List<TmdbSearchResultDto>? movieResults;

  @JsonKey(name: 'tv_results')
  final List<TmdbSearchResultDto>? tvResults;

  Map<String, dynamic> toJson() => _$TmdbFindResponseDtoToJson(this);

  /// All results combined, with media_type set.
  List<TmdbSearchResultDto> get allResults {
    final results = <TmdbSearchResultDto>[];
    if (movieResults != null) {
      for (final r in movieResults!) {
        // The find endpoint doesn't always include media_type in results,
        // so we tag them manually based on which array they came from.
        results.add(TmdbSearchResultDto(
          id: r.id,
          title: r.title,
          name: r.name,
          overview: r.overview,
          posterPath: r.posterPath,
          releaseDate: r.releaseDate,
          firstAirDate: r.firstAirDate,
          genreIds: r.genreIds,
          mediaType: 'movie',
          voteAverage: r.voteAverage,
          voteCount: r.voteCount,
        ));
      }
    }
    if (tvResults != null) {
      for (final r in tvResults!) {
        results.add(TmdbSearchResultDto(
          id: r.id,
          title: r.title,
          name: r.name,
          overview: r.overview,
          posterPath: r.posterPath,
          releaseDate: r.releaseDate,
          firstAirDate: r.firstAirDate,
          genreIds: r.genreIds,
          mediaType: 'tv',
          voteAverage: r.voteAverage,
          voteCount: r.voteCount,
        ));
      }
    }
    return results;
  }
}
