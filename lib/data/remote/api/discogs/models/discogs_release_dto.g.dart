// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discogs_release_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscogsReleaseDto _$DiscogsReleaseDtoFromJson(
  Map<String, dynamic> json,
) => DiscogsReleaseDto(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  year: (json['year'] as num?)?.toInt(),
  artists: (json['artists'] as List<dynamic>?)
      ?.map((e) => DiscogsArtistDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  labels: (json['labels'] as List<dynamic>?)
      ?.map((e) => DiscogsLabelDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  tracklist: (json['tracklist'] as List<dynamic>?)
      ?.map((e) => DiscogsTrackDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => DiscogsImageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  catno: json['catno'] as String?,
);

Map<String, dynamic> _$DiscogsReleaseDtoToJson(DiscogsReleaseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'year': instance.year,
      'artists': instance.artists,
      'labels': instance.labels,
      'genres': instance.genres,
      'styles': instance.styles,
      'tracklist': instance.tracklist,
      'images': instance.images,
      'catno': instance.catno,
    };

DiscogsArtistDto _$DiscogsArtistDtoFromJson(Map<String, dynamic> json) =>
    DiscogsArtistDto(name: json['name'] as String?);

Map<String, dynamic> _$DiscogsArtistDtoToJson(DiscogsArtistDto instance) =>
    <String, dynamic>{'name': instance.name};

DiscogsLabelDto _$DiscogsLabelDtoFromJson(Map<String, dynamic> json) =>
    DiscogsLabelDto(
      name: json['name'] as String?,
      catno: json['catno'] as String?,
    );

Map<String, dynamic> _$DiscogsLabelDtoToJson(DiscogsLabelDto instance) =>
    <String, dynamic>{'name': instance.name, 'catno': instance.catno};

DiscogsTrackDto _$DiscogsTrackDtoFromJson(Map<String, dynamic> json) =>
    DiscogsTrackDto(
      position: json['position'] as String?,
      title: json['title'] as String?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$DiscogsTrackDtoToJson(DiscogsTrackDto instance) =>
    <String, dynamic>{
      'position': instance.position,
      'title': instance.title,
      'duration': instance.duration,
    };

DiscogsImageDto _$DiscogsImageDtoFromJson(Map<String, dynamic> json) =>
    DiscogsImageDto(uri: json['uri'] as String?, type: json['type'] as String?);

Map<String, dynamic> _$DiscogsImageDtoToJson(DiscogsImageDto instance) =>
    <String, dynamic>{'uri': instance.uri, 'type': instance.type};

DiscogsSearchResponseDto _$DiscogsSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => DiscogsSearchResponseDto(
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => DiscogsSearchResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DiscogsSearchResponseDtoToJson(
  DiscogsSearchResponseDto instance,
) => <String, dynamic>{'results': instance.results};

DiscogsSearchResultDto _$DiscogsSearchResultDtoFromJson(
  Map<String, dynamic> json,
) => DiscogsSearchResultDto(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  year: json['year'] as String?,
  coverImage: json['cover_image'] as String?,
);

Map<String, dynamic> _$DiscogsSearchResultDtoToJson(
  DiscogsSearchResultDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'year': instance.year,
  'cover_image': instance.coverImage,
};
