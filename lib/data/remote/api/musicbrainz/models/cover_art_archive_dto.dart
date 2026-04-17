import 'package:json_annotation/json_annotation.dart';

part 'cover_art_archive_dto.g.dart';

@JsonSerializable()
class CoverArtArchiveResponseDto {
  const CoverArtArchiveResponseDto({this.images});

  factory CoverArtArchiveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveResponseDtoFromJson(json);

  final List<CoverArtArchiveImageDto>? images;

  Map<String, dynamic> toJson() => _$CoverArtArchiveResponseDtoToJson(this);
}

@JsonSerializable()
class CoverArtArchiveImageDto {
  const CoverArtArchiveImageDto({
    this.front,
    this.image,
    this.thumbnails,
    this.types,
  });

  factory CoverArtArchiveImageDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveImageDtoFromJson(json);

  final bool? front;
  final String? image;
  final CoverArtArchiveThumbnailsDto? thumbnails;
  final List<String>? types;

  Map<String, dynamic> toJson() => _$CoverArtArchiveImageDtoToJson(this);
}

@JsonSerializable()
class CoverArtArchiveThumbnailsDto {
  const CoverArtArchiveThumbnailsDto({this.small, this.large, this.size250});

  factory CoverArtArchiveThumbnailsDto.fromJson(Map<String, dynamic> json) =>
      _$CoverArtArchiveThumbnailsDtoFromJson(json);

  final String? small;
  final String? large;
  @JsonKey(name: '250')
  final String? size250;

  Map<String, dynamic> toJson() => _$CoverArtArchiveThumbnailsDtoToJson(this);
}
