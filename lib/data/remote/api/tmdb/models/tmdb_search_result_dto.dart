import 'package:json_annotation/json_annotation.dart';

part 'tmdb_search_result_dto.g.dart';

@JsonSerializable()
class TmdbSearchResultDto {
  const TmdbSearchResultDto({
    this.id,
    this.title,
    this.name,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.firstAirDate,
    this.genreIds,
    this.mediaType,
  });

  factory TmdbSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResultDtoFromJson(json);

  final int? id;
  final String? title;
  final String? name;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  @JsonKey(name: 'media_type')
  final String? mediaType;

  Map<String, dynamic> toJson() => _$TmdbSearchResultDtoToJson(this);

  /// Effective title (movies use title, TV uses name).
  String? get effectiveTitle => title ?? name;

  /// Effective release year.
  int? get effectiveYear {
    final date = releaseDate ?? firstAirDate;
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  /// Full poster URL.
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;
}

@JsonSerializable()
class TmdbSearchResponseDto {
  const TmdbSearchResponseDto({this.results, this.totalResults});

  factory TmdbSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResponseDtoFromJson(json);

  final List<TmdbSearchResultDto>? results;
  @JsonKey(name: 'total_results')
  final int? totalResults;

  Map<String, dynamic> toJson() => _$TmdbSearchResponseDtoToJson(this);
}
