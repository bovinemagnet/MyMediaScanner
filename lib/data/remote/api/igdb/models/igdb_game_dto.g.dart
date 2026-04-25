// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'igdb_game_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IgdbGameDto _$IgdbGameDtoFromJson(Map<String, dynamic> json) => IgdbGameDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  summary: json['summary'] as String?,
  cover: json['cover'] == null
      ? null
      : IgdbCoverDto.fromJson(json['cover'] as Map<String, dynamic>),
  platforms: (json['platforms'] as List<dynamic>?)
      ?.map((e) => IgdbPlatformDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  involvedCompanies: (json['involved_companies'] as List<dynamic>?)
      ?.map((e) => IgdbInvolvedCompanyDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  genres: (json['genres'] as List<dynamic>?)
      ?.map((e) => IgdbGenreDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  firstReleaseDate: (json['first_release_date'] as num?)?.toInt(),
  aggregatedRating: (json['aggregated_rating'] as num?)?.toDouble(),
  rating: (json['rating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$IgdbGameDtoToJson(IgdbGameDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'summary': instance.summary,
      'cover': instance.cover,
      'platforms': instance.platforms,
      'involved_companies': instance.involvedCompanies,
      'genres': instance.genres,
      'first_release_date': instance.firstReleaseDate,
      'aggregated_rating': instance.aggregatedRating,
      'rating': instance.rating,
    };

IgdbCoverDto _$IgdbCoverDtoFromJson(Map<String, dynamic> json) => IgdbCoverDto(
  id: (json['id'] as num?)?.toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$IgdbCoverDtoToJson(IgdbCoverDto instance) =>
    <String, dynamic>{'id': instance.id, 'url': instance.url};

IgdbPlatformDto _$IgdbPlatformDtoFromJson(Map<String, dynamic> json) =>
    IgdbPlatformDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$IgdbPlatformDtoToJson(IgdbPlatformDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

IgdbGenreDto _$IgdbGenreDtoFromJson(Map<String, dynamic> json) => IgdbGenreDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$IgdbGenreDtoToJson(IgdbGenreDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

IgdbInvolvedCompanyDto _$IgdbInvolvedCompanyDtoFromJson(
  Map<String, dynamic> json,
) => IgdbInvolvedCompanyDto(
  id: (json['id'] as num?)?.toInt(),
  company: json['company'] == null
      ? null
      : IgdbCompanyDto.fromJson(json['company'] as Map<String, dynamic>),
  developer: json['developer'] as bool?,
  publisher: json['publisher'] as bool?,
);

Map<String, dynamic> _$IgdbInvolvedCompanyDtoToJson(
  IgdbInvolvedCompanyDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'company': instance.company,
  'developer': instance.developer,
  'publisher': instance.publisher,
};

IgdbCompanyDto _$IgdbCompanyDtoFromJson(Map<String, dynamic> json) =>
    IgdbCompanyDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$IgdbCompanyDtoToJson(IgdbCompanyDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
