// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_account_list_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbAccountListPageDto _$TmdbAccountListPageDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAccountListPageDto(
  page: (json['page'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  totalResults: (json['total_results'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => TmdbAccountListItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TmdbAccountListPageDtoToJson(
  TmdbAccountListPageDto instance,
) => <String, dynamic>{
  'page': instance.page,
  'total_pages': instance.totalPages,
  'total_results': instance.totalResults,
  'results': instance.results,
};

TmdbAccountListItemDto _$TmdbAccountListItemDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAccountListItemDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  name: json['name'] as String?,
  releaseDate: json['release_date'] as String?,
  firstAirDate: json['first_air_date'] as String?,
  posterPath: json['poster_path'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  mediaType: json['media_type'] as String?,
);

Map<String, dynamic> _$TmdbAccountListItemDtoToJson(
  TmdbAccountListItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'name': instance.name,
  'release_date': instance.releaseDate,
  'first_air_date': instance.firstAirDate,
  'poster_path': instance.posterPath,
  'rating': instance.rating,
  'media_type': instance.mediaType,
};
