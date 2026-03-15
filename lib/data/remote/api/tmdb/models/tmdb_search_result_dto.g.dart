// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_search_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbSearchResultDto _$TmdbSearchResultDtoFromJson(Map<String, dynamic> json) =>
    TmdbSearchResultDto(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      name: json['name'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      mediaType: json['media_type'] as String?,
    );

Map<String, dynamic> _$TmdbSearchResultDtoToJson(
  TmdbSearchResultDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'name': instance.name,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'release_date': instance.releaseDate,
  'first_air_date': instance.firstAirDate,
  'genre_ids': instance.genreIds,
  'media_type': instance.mediaType,
};

TmdbSearchResponseDto _$TmdbSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => TmdbSearchResponseDto(
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => TmdbSearchResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalResults: (json['total_results'] as num?)?.toInt(),
);

Map<String, dynamic> _$TmdbSearchResponseDtoToJson(
  TmdbSearchResponseDto instance,
) => <String, dynamic>{
  'results': instance.results,
  'total_results': instance.totalResults,
};
