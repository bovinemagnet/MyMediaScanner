import 'package:json_annotation/json_annotation.dart';

part 'igdb_game_dto.g.dart';

/// Response model for an IGDB game returned by `POST /v4/games` with an
/// Apicalypse query that field-expands cover, platforms, involved_companies,
/// and genres.
@JsonSerializable()
class IgdbGameDto {
  const IgdbGameDto({
    this.id,
    this.name,
    this.summary,
    this.cover,
    this.platforms,
    this.involvedCompanies,
    this.genres,
    this.firstReleaseDate,
    this.aggregatedRating,
    this.rating,
  });

  factory IgdbGameDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbGameDtoFromJson(json);

  final int? id;
  final String? name;
  final String? summary;
  final IgdbCoverDto? cover;
  final List<IgdbPlatformDto>? platforms;

  @JsonKey(name: 'involved_companies')
  final List<IgdbInvolvedCompanyDto>? involvedCompanies;

  final List<IgdbGenreDto>? genres;

  /// Seconds since Unix epoch. IGDB returns this as an integer.
  @JsonKey(name: 'first_release_date')
  final int? firstReleaseDate;

  /// Critic average (0–100). Null when IGDB has no aggregated critic data.
  @JsonKey(name: 'aggregated_rating')
  final double? aggregatedRating;

  /// User score (0–100). Fallback when aggregatedRating is null.
  final double? rating;

  Map<String, dynamic> toJson() => _$IgdbGameDtoToJson(this);
}

@JsonSerializable()
class IgdbCoverDto {
  const IgdbCoverDto({this.id, this.url});

  factory IgdbCoverDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbCoverDtoFromJson(json);

  final int? id;

  /// IGDB returns scheme-less URLs like `//images.igdb.com/igdb/image/upload/t_thumb/...`
  /// The `t_thumb` size is upgraded to `t_cover_big` during mapping.
  final String? url;

  Map<String, dynamic> toJson() => _$IgdbCoverDtoToJson(this);
}

@JsonSerializable()
class IgdbPlatformDto {
  const IgdbPlatformDto({this.id, this.name});

  factory IgdbPlatformDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbPlatformDtoFromJson(json);

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => _$IgdbPlatformDtoToJson(this);
}

@JsonSerializable()
class IgdbGenreDto {
  const IgdbGenreDto({this.id, this.name});

  factory IgdbGenreDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbGenreDtoFromJson(json);

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => _$IgdbGenreDtoToJson(this);
}

@JsonSerializable()
class IgdbInvolvedCompanyDto {
  const IgdbInvolvedCompanyDto({
    this.id,
    this.company,
    this.developer,
    this.publisher,
  });

  factory IgdbInvolvedCompanyDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbInvolvedCompanyDtoFromJson(json);

  final int? id;
  final IgdbCompanyDto? company;
  final bool? developer;
  final bool? publisher;

  Map<String, dynamic> toJson() => _$IgdbInvolvedCompanyDtoToJson(this);
}

@JsonSerializable()
class IgdbCompanyDto {
  const IgdbCompanyDto({this.id, this.name});

  factory IgdbCompanyDto.fromJson(Map<String, dynamic> json) =>
      _$IgdbCompanyDtoFromJson(json);

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => _$IgdbCompanyDtoToJson(this);
}
