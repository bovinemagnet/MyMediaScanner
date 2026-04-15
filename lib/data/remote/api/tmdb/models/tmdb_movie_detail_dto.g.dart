// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_movie_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbMovieDetailDto _$TmdbMovieDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbMovieDetailDto(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      belongsToCollection: json['belongs_to_collection'] == null
          ? null
          : TmdbCollectionRefDto.fromJson(
              json['belongs_to_collection'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TmdbMovieDetailDtoToJson(TmdbMovieDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'belongs_to_collection': instance.belongsToCollection,
    };

TmdbCollectionRefDto _$TmdbCollectionRefDtoFromJson(
  Map<String, dynamic> json,
) => TmdbCollectionRefDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$TmdbCollectionRefDtoToJson(
  TmdbCollectionRefDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
