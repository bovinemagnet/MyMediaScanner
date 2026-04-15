import 'package:json_annotation/json_annotation.dart';

part 'tmdb_movie_detail_dto.g.dart';

/// Response from `/movie/{id}` — the subset of fields needed for series
/// (collection) detection. Other detail fields are ignored on purpose.
@JsonSerializable()
class TmdbMovieDetailDto {
  const TmdbMovieDetailDto({
    this.id,
    this.title,
    this.belongsToCollection,
  });

  factory TmdbMovieDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbMovieDetailDtoFromJson(json);

  final int? id;
  final String? title;

  @JsonKey(name: 'belongs_to_collection')
  final TmdbCollectionRefDto? belongsToCollection;

  Map<String, dynamic> toJson() => _$TmdbMovieDetailDtoToJson(this);
}

/// Lightweight reference embedded in movie detail. Full collection detail
/// is fetched separately via `/collection/{id}` when needed for the series
/// detail screen.
@JsonSerializable()
class TmdbCollectionRefDto {
  const TmdbCollectionRefDto({this.id, this.name});

  factory TmdbCollectionRefDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCollectionRefDtoFromJson(json);

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => _$TmdbCollectionRefDtoToJson(this);
}
