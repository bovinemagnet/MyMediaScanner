import 'package:json_annotation/json_annotation.dart';

part 'discogs_release_dto.g.dart';

@JsonSerializable()
class DiscogsReleaseDto {
  const DiscogsReleaseDto({
    this.id,
    this.title,
    this.year,
    this.artists,
    this.labels,
    this.genres,
    this.styles,
    this.tracklist,
    this.images,
    this.catno,
  });

  factory DiscogsReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsReleaseDtoFromJson(json);

  final int? id;
  final String? title;
  final int? year;
  final List<DiscogsArtistDto>? artists;
  final List<DiscogsLabelDto>? labels;
  final List<String>? genres;
  final List<String>? styles;
  final List<DiscogsTrackDto>? tracklist;
  final List<DiscogsImageDto>? images;
  final String? catno;

  Map<String, dynamic> toJson() => _$DiscogsReleaseDtoToJson(this);

  String? get primaryImageUrl =>
      images?.isNotEmpty == true ? images!.first.uri : null;

  String? get artistName =>
      artists?.map((a) => a.name).join(', ');

  String? get labelName =>
      labels?.isNotEmpty == true ? labels!.first.name : null;
}

@JsonSerializable()
class DiscogsArtistDto {
  const DiscogsArtistDto({this.name});
  factory DiscogsArtistDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsArtistDtoFromJson(json);
  final String? name;
  Map<String, dynamic> toJson() => _$DiscogsArtistDtoToJson(this);
}

@JsonSerializable()
class DiscogsLabelDto {
  const DiscogsLabelDto({this.name, this.catno});
  factory DiscogsLabelDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsLabelDtoFromJson(json);
  final String? name;
  final String? catno;
  Map<String, dynamic> toJson() => _$DiscogsLabelDtoToJson(this);
}

@JsonSerializable()
class DiscogsTrackDto {
  const DiscogsTrackDto({this.position, this.title, this.duration});
  factory DiscogsTrackDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsTrackDtoFromJson(json);
  final String? position;
  final String? title;
  final String? duration;
  Map<String, dynamic> toJson() => _$DiscogsTrackDtoToJson(this);
}

@JsonSerializable()
class DiscogsImageDto {
  const DiscogsImageDto({this.uri, this.type});
  factory DiscogsImageDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsImageDtoFromJson(json);
  final String? uri;
  final String? type;
  Map<String, dynamic> toJson() => _$DiscogsImageDtoToJson(this);
}

@JsonSerializable()
class DiscogsSearchResponseDto {
  const DiscogsSearchResponseDto({this.results});
  factory DiscogsSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsSearchResponseDtoFromJson(json);
  final List<DiscogsSearchResultDto>? results;
  Map<String, dynamic> toJson() => _$DiscogsSearchResponseDtoToJson(this);
}

@JsonSerializable()
class DiscogsSearchResultDto {
  const DiscogsSearchResultDto({this.id, this.title, this.year, this.coverImage});
  factory DiscogsSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsSearchResultDtoFromJson(json);
  final int? id;
  final String? title;
  final String? year;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  Map<String, dynamic> toJson() => _$DiscogsSearchResultDtoToJson(this);
}
