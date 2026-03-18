import 'package:json_annotation/json_annotation.dart';

part 'tvdb_series_dto.g.dart';

// -- Login --

@JsonSerializable()
class TvdbLoginRequestDto {
  const TvdbLoginRequestDto({required this.apikey});

  factory TvdbLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbLoginRequestDtoFromJson(json);

  final String apikey;

  Map<String, dynamic> toJson() => _$TvdbLoginRequestDtoToJson(this);
}

@JsonSerializable()
class TvdbLoginResponseDto {
  const TvdbLoginResponseDto({this.status, this.data});

  factory TvdbLoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbLoginResponseDtoFromJson(json);

  final String? status;
  final TvdbTokenDto? data;

  Map<String, dynamic> toJson() => _$TvdbLoginResponseDtoToJson(this);
}

@JsonSerializable()
class TvdbTokenDto {
  const TvdbTokenDto({this.token});

  factory TvdbTokenDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbTokenDtoFromJson(json);

  final String? token;

  Map<String, dynamic> toJson() => _$TvdbTokenDtoToJson(this);
}

// -- Search --

@JsonSerializable()
class TvdbSearchResponseDto {
  const TvdbSearchResponseDto({this.status, this.data});

  factory TvdbSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbSearchResponseDtoFromJson(json);

  final String? status;
  final List<TvdbSearchResultDto>? data;

  Map<String, dynamic> toJson() => _$TvdbSearchResponseDtoToJson(this);
}

@JsonSerializable()
class TvdbSearchResultDto {
  const TvdbSearchResultDto({
    this.tvdbId,
    this.name,
    this.type,
    this.year,
    this.slug,
    this.overview,
    this.imageUrl,
    this.country,
    this.network,
    this.primaryLanguage,
    this.genres,
    this.remoteIds,
  });

  factory TvdbSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbSearchResultDtoFromJson(json);

  @JsonKey(name: 'tvdb_id')
  final String? tvdbId;
  final String? name;
  final String? type;
  final String? year;
  final String? slug;
  final String? overview;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? country;
  final String? network;
  @JsonKey(name: 'primary_language')
  final String? primaryLanguage;
  final List<String>? genres;
  @JsonKey(name: 'remote_ids')
  final List<TvdbRemoteIdDto>? remoteIds;

  Map<String, dynamic> toJson() => _$TvdbSearchResultDtoToJson(this);

  int? get effectiveYear => year != null ? int.tryParse(year!) : null;
}

@JsonSerializable()
class TvdbRemoteIdDto {
  const TvdbRemoteIdDto({this.id, this.type, this.sourceName});

  factory TvdbRemoteIdDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbRemoteIdDtoFromJson(json);

  final String? id;
  final int? type;
  @JsonKey(name: 'sourceName')
  final String? sourceName;

  Map<String, dynamic> toJson() => _$TvdbRemoteIdDtoToJson(this);
}

// -- Series detail --

@JsonSerializable()
class TvdbSeriesResponseDto {
  const TvdbSeriesResponseDto({this.status, this.data});

  factory TvdbSeriesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbSeriesResponseDtoFromJson(json);

  final String? status;
  final TvdbSeriesDto? data;

  Map<String, dynamic> toJson() => _$TvdbSeriesResponseDtoToJson(this);
}

@JsonSerializable()
class TvdbSeriesDto {
  const TvdbSeriesDto({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.year,
    this.overview,
    this.score,
    this.genres,
  });

  factory TvdbSeriesDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbSeriesDtoFromJson(json);

  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? year;
  final String? overview;
  final int? score;
  final List<TvdbGenreDto>? genres;

  Map<String, dynamic> toJson() => _$TvdbSeriesDtoToJson(this);

  int? get effectiveYear => year != null ? int.tryParse(year!) : null;
}

@JsonSerializable()
class TvdbGenreDto {
  const TvdbGenreDto({this.id, this.name});

  factory TvdbGenreDto.fromJson(Map<String, dynamic> json) =>
      _$TvdbGenreDtoFromJson(json);

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => _$TvdbGenreDtoToJson(this);
}
