// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_find_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbFindResponseDto _$TmdbFindResponseDtoFromJson(Map<String, dynamic> json) =>
    TmdbFindResponseDto(
      movieResults: (json['movie_results'] as List<dynamic>?)
          ?.map((e) => TmdbSearchResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      tvResults: (json['tv_results'] as List<dynamic>?)
          ?.map((e) => TmdbSearchResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TmdbFindResponseDtoToJson(
  TmdbFindResponseDto instance,
) => <String, dynamic>{
  'movie_results': instance.movieResults,
  'tv_results': instance.tvResults,
};
