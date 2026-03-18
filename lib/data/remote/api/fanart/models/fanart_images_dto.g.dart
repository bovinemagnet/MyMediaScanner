// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fanart_images_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FanartMovieImagesDto _$FanartMovieImagesDtoFromJson(
  Map<String, dynamic> json,
) => FanartMovieImagesDto(
  movieposter: (json['movieposter'] as List<dynamic>?)
      ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  moviethumb: (json['moviethumb'] as List<dynamic>?)
      ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FanartMovieImagesDtoToJson(
  FanartMovieImagesDto instance,
) => <String, dynamic>{
  'movieposter': instance.movieposter,
  'moviethumb': instance.moviethumb,
};

FanartTvImagesDto _$FanartTvImagesDtoFromJson(Map<String, dynamic> json) =>
    FanartTvImagesDto(
      tvposter: (json['tvposter'] as List<dynamic>?)
          ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      tvthumb: (json['tvthumb'] as List<dynamic>?)
          ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FanartTvImagesDtoToJson(FanartTvImagesDto instance) =>
    <String, dynamic>{
      'tvposter': instance.tvposter,
      'tvthumb': instance.tvthumb,
    };

FanartAlbumImagesDto _$FanartAlbumImagesDtoFromJson(
  Map<String, dynamic> json,
) => FanartAlbumImagesDto(
  albums: (json['albums'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, FanartAlbumArtDto.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$FanartAlbumImagesDtoToJson(
  FanartAlbumImagesDto instance,
) => <String, dynamic>{'albums': instance.albums};

FanartAlbumArtDto _$FanartAlbumArtDtoFromJson(Map<String, dynamic> json) =>
    FanartAlbumArtDto(
      albumcover: (json['albumcover'] as List<dynamic>?)
          ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      cdart: (json['cdart'] as List<dynamic>?)
          ?.map((e) => FanartImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FanartAlbumArtDtoToJson(FanartAlbumArtDto instance) =>
    <String, dynamic>{
      'albumcover': instance.albumcover,
      'cdart': instance.cdart,
    };

FanartImageDto _$FanartImageDtoFromJson(Map<String, dynamic> json) =>
    FanartImageDto(
      id: json['id'] as String?,
      url: json['url'] as String?,
      likes: json['likes'] as String?,
      lang: json['lang'] as String?,
    );

Map<String, dynamic> _$FanartImageDtoToJson(FanartImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'likes': instance.likes,
      'lang': instance.lang,
    };
