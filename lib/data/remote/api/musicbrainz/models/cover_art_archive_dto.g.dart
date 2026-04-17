// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_art_archive_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverArtArchiveResponseDto _$CoverArtArchiveResponseDtoFromJson(
  Map<String, dynamic> json,
) => CoverArtArchiveResponseDto(
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => CoverArtArchiveImageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoverArtArchiveResponseDtoToJson(
  CoverArtArchiveResponseDto instance,
) => <String, dynamic>{'images': instance.images};

CoverArtArchiveImageDto _$CoverArtArchiveImageDtoFromJson(
  Map<String, dynamic> json,
) => CoverArtArchiveImageDto(
  front: json['front'] as bool?,
  image: json['image'] as String?,
  thumbnails: json['thumbnails'] == null
      ? null
      : CoverArtArchiveThumbnailsDto.fromJson(
          json['thumbnails'] as Map<String, dynamic>,
        ),
  types: (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$CoverArtArchiveImageDtoToJson(
  CoverArtArchiveImageDto instance,
) => <String, dynamic>{
  'front': instance.front,
  'image': instance.image,
  'thumbnails': instance.thumbnails,
  'types': instance.types,
};

CoverArtArchiveThumbnailsDto _$CoverArtArchiveThumbnailsDtoFromJson(
  Map<String, dynamic> json,
) => CoverArtArchiveThumbnailsDto(
  small: json['small'] as String?,
  large: json['large'] as String?,
  size250: json['250'] as String?,
);

Map<String, dynamic> _$CoverArtArchiveThumbnailsDtoToJson(
  CoverArtArchiveThumbnailsDto instance,
) => <String, dynamic>{
  'small': instance.small,
  'large': instance.large,
  '250': instance.size250,
};
