import 'package:json_annotation/json_annotation.dart';

part 'fanart_images_dto.g.dart';

@JsonSerializable()
class FanartMovieImagesDto {
  const FanartMovieImagesDto({this.movieposter, this.moviethumb});

  factory FanartMovieImagesDto.fromJson(Map<String, dynamic> json) =>
      _$FanartMovieImagesDtoFromJson(json);

  final List<FanartImageDto>? movieposter;
  final List<FanartImageDto>? moviethumb;

  Map<String, dynamic> toJson() => _$FanartMovieImagesDtoToJson(this);

  /// Best available poster URL.
  String? get bestPosterUrl =>
      movieposter?.firstOrNull?.url ?? moviethumb?.firstOrNull?.url;
}

@JsonSerializable()
class FanartTvImagesDto {
  const FanartTvImagesDto({this.tvposter, this.tvthumb});

  factory FanartTvImagesDto.fromJson(Map<String, dynamic> json) =>
      _$FanartTvImagesDtoFromJson(json);

  final List<FanartImageDto>? tvposter;
  final List<FanartImageDto>? tvthumb;

  Map<String, dynamic> toJson() => _$FanartTvImagesDtoToJson(this);

  String? get bestPosterUrl =>
      tvposter?.firstOrNull?.url ?? tvthumb?.firstOrNull?.url;
}

@JsonSerializable()
class FanartAlbumImagesDto {
  const FanartAlbumImagesDto({this.albums});

  factory FanartAlbumImagesDto.fromJson(Map<String, dynamic> json) =>
      _$FanartAlbumImagesDtoFromJson(json);

  final Map<String, FanartAlbumArtDto>? albums;

  Map<String, dynamic> toJson() => _$FanartAlbumImagesDtoToJson(this);

  /// Best available album cover URL from the first album entry.
  String? get bestCoverUrl =>
      albums?.values.firstOrNull?.albumcover?.firstOrNull?.url;
}

@JsonSerializable()
class FanartAlbumArtDto {
  const FanartAlbumArtDto({this.albumcover, this.cdart});

  factory FanartAlbumArtDto.fromJson(Map<String, dynamic> json) =>
      _$FanartAlbumArtDtoFromJson(json);

  final List<FanartImageDto>? albumcover;
  final List<FanartImageDto>? cdart;

  Map<String, dynamic> toJson() => _$FanartAlbumArtDtoToJson(this);
}

@JsonSerializable()
class FanartImageDto {
  const FanartImageDto({this.id, this.url, this.likes, this.lang});

  factory FanartImageDto.fromJson(Map<String, dynamic> json) =>
      _$FanartImageDtoFromJson(json);

  final String? id;
  final String? url;
  final String? likes;
  final String? lang;

  Map<String, dynamic> toJson() => _$FanartImageDtoToJson(this);
}
