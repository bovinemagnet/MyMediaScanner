// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tvdb_series_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TvdbLoginRequestDto _$TvdbLoginRequestDtoFromJson(Map<String, dynamic> json) =>
    TvdbLoginRequestDto(apikey: json['apikey'] as String);

Map<String, dynamic> _$TvdbLoginRequestDtoToJson(
  TvdbLoginRequestDto instance,
) => <String, dynamic>{'apikey': instance.apikey};

TvdbLoginResponseDto _$TvdbLoginResponseDtoFromJson(
  Map<String, dynamic> json,
) => TvdbLoginResponseDto(
  status: json['status'] as String?,
  data: json['data'] == null
      ? null
      : TvdbTokenDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TvdbLoginResponseDtoToJson(
  TvdbLoginResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

TvdbTokenDto _$TvdbTokenDtoFromJson(Map<String, dynamic> json) =>
    TvdbTokenDto(token: json['token'] as String?);

Map<String, dynamic> _$TvdbTokenDtoToJson(TvdbTokenDto instance) =>
    <String, dynamic>{'token': instance.token};

TvdbSearchResponseDto _$TvdbSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => TvdbSearchResponseDto(
  status: json['status'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => TvdbSearchResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TvdbSearchResponseDtoToJson(
  TvdbSearchResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

TvdbSearchResultDto _$TvdbSearchResultDtoFromJson(Map<String, dynamic> json) =>
    TvdbSearchResultDto(
      tvdbId: json['tvdb_id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      year: json['year'] as String?,
      slug: json['slug'] as String?,
      overview: json['overview'] as String?,
      imageUrl: json['image_url'] as String?,
      country: json['country'] as String?,
      network: json['network'] as String?,
      primaryLanguage: json['primary_language'] as String?,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      remoteIds: (json['remote_ids'] as List<dynamic>?)
          ?.map((e) => TvdbRemoteIdDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TvdbSearchResultDtoToJson(
  TvdbSearchResultDto instance,
) => <String, dynamic>{
  'tvdb_id': instance.tvdbId,
  'name': instance.name,
  'type': instance.type,
  'year': instance.year,
  'slug': instance.slug,
  'overview': instance.overview,
  'image_url': instance.imageUrl,
  'country': instance.country,
  'network': instance.network,
  'primary_language': instance.primaryLanguage,
  'genres': instance.genres,
  'remote_ids': instance.remoteIds,
};

TvdbRemoteIdDto _$TvdbRemoteIdDtoFromJson(Map<String, dynamic> json) =>
    TvdbRemoteIdDto(
      id: json['id'] as String?,
      type: (json['type'] as num?)?.toInt(),
      sourceName: json['sourceName'] as String?,
    );

Map<String, dynamic> _$TvdbRemoteIdDtoToJson(TvdbRemoteIdDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'sourceName': instance.sourceName,
    };

TvdbSeriesResponseDto _$TvdbSeriesResponseDtoFromJson(
  Map<String, dynamic> json,
) => TvdbSeriesResponseDto(
  status: json['status'] as String?,
  data: json['data'] == null
      ? null
      : TvdbSeriesDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TvdbSeriesResponseDtoToJson(
  TvdbSeriesResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

TvdbSeriesDto _$TvdbSeriesDtoFromJson(Map<String, dynamic> json) =>
    TvdbSeriesDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      image: json['image'] as String?,
      year: json['year'] as String?,
      overview: json['overview'] as String?,
      score: (json['score'] as num?)?.toInt(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => TvdbGenreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TvdbSeriesDtoToJson(TvdbSeriesDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'image': instance.image,
      'year': instance.year,
      'overview': instance.overview,
      'score': instance.score,
      'genres': instance.genres,
    };

TvdbGenreDto _$TvdbGenreDtoFromJson(Map<String, dynamic> json) => TvdbGenreDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$TvdbGenreDtoToJson(TvdbGenreDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
