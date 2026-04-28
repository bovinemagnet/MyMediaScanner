import 'package:json_annotation/json_annotation.dart';

part 'tmdb_account_list_page_dto.g.dart';

@JsonSerializable()
class TmdbAccountListPageDto {
  const TmdbAccountListPageDto({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory TmdbAccountListPageDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListPageDtoFromJson(json);

  final int page;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;
  final List<TmdbAccountListItemDto> results;

  Map<String, dynamic> toJson() => _$TmdbAccountListPageDtoToJson(this);
}

@JsonSerializable()
class TmdbAccountListItemDto {
  const TmdbAccountListItemDto({
    required this.id,
    this.title,
    this.name,
    this.releaseDate,
    this.firstAirDate,
    this.posterPath,
    this.rating,
    this.mediaType,
  });

  factory TmdbAccountListItemDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListItemDtoFromJson(json);

  final int id;
  final String? title; // movie
  final String? name; // tv
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  final double? rating;
  @JsonKey(name: 'media_type')
  final String? mediaType;

  Map<String, dynamic> toJson() => _$TmdbAccountListItemDtoToJson(this);
}
