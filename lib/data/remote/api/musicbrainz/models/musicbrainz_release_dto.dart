import 'package:json_annotation/json_annotation.dart';

part 'musicbrainz_release_dto.g.dart';

@JsonSerializable()
class MusicBrainzSearchResponseDto {
  const MusicBrainzSearchResponseDto({this.count, this.releases});

  factory MusicBrainzSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzSearchResponseDtoFromJson(json);

  final int? count;
  final List<MusicBrainzReleaseDto>? releases;

  Map<String, dynamic> toJson() => _$MusicBrainzSearchResponseDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzReleaseDto {
  const MusicBrainzReleaseDto({
    this.id,
    this.title,
    this.status,
    this.date,
    this.country,
    this.barcode,
    this.score,
    this.packaging,
    this.artistCredit,
    this.releaseGroup,
    this.labelInfo,
    this.media,
    this.tags,
    this.trackCount,
  });

  factory MusicBrainzReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzReleaseDtoFromJson(json);

  final String? id;
  final String? title;
  final String? status;
  final String? date;
  final String? country;
  final String? barcode;
  final int? score;
  final String? packaging;
  @JsonKey(name: 'artist-credit')
  final List<MusicBrainzArtistCreditDto>? artistCredit;
  @JsonKey(name: 'release-group')
  final MusicBrainzReleaseGroupDto? releaseGroup;
  @JsonKey(name: 'label-info')
  final List<MusicBrainzLabelInfoDto>? labelInfo;
  final List<MusicBrainzMediaDto>? media;
  final List<MusicBrainzTagDto>? tags;
  @JsonKey(name: 'track-count')
  final int? trackCount;

  Map<String, dynamic> toJson() => _$MusicBrainzReleaseDtoToJson(this);

  /// Combined artist name from credits.
  String? get effectiveArtist => artistCredit
      ?.map((c) => c.name ?? c.artist?.name)
      .whereType<String>()
      .join(', ');

  /// Release year extracted from date string.
  int? get effectiveYear {
    if (date == null || date!.length < 4) return null;
    return int.tryParse(date!.substring(0, 4));
  }

  /// Primary label name.
  String? get effectiveLabel => labelInfo?.firstOrNull?.label?.name;

  /// Format of the first medium (e.g. "CD", "Vinyl").
  String? get effectiveFormat => media?.firstOrNull?.format;

  /// MusicBrainz release group ID (used for TheAudioDB/fanart.tv lookups).
  String? get releaseGroupId => releaseGroup?.id;

  /// Cover art URL via Cover Art Archive.
  String? get coverUrl =>
      id != null ? 'https://coverartarchive.org/release/$id/front-250' : null;
}

@JsonSerializable()
class MusicBrainzArtistCreditDto {
  const MusicBrainzArtistCreditDto({this.name, this.artist});

  factory MusicBrainzArtistCreditDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzArtistCreditDtoFromJson(json);

  final String? name;
  final MusicBrainzArtistDto? artist;

  Map<String, dynamic> toJson() => _$MusicBrainzArtistCreditDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzArtistDto {
  const MusicBrainzArtistDto({this.id, this.name, this.sortName});

  factory MusicBrainzArtistDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzArtistDtoFromJson(json);

  final String? id;
  final String? name;
  @JsonKey(name: 'sort-name')
  final String? sortName;

  Map<String, dynamic> toJson() => _$MusicBrainzArtistDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzReleaseGroupDto {
  const MusicBrainzReleaseGroupDto({
    this.id,
    this.title,
    this.primaryType,
    this.secondaryTypes,
  });

  factory MusicBrainzReleaseGroupDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzReleaseGroupDtoFromJson(json);

  final String? id;
  final String? title;
  @JsonKey(name: 'primary-type')
  final String? primaryType;
  @JsonKey(name: 'secondary-types')
  final List<String>? secondaryTypes;

  Map<String, dynamic> toJson() => _$MusicBrainzReleaseGroupDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzLabelInfoDto {
  const MusicBrainzLabelInfoDto({this.catalogNumber, this.label});

  factory MusicBrainzLabelInfoDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzLabelInfoDtoFromJson(json);

  @JsonKey(name: 'catalog-number')
  final String? catalogNumber;
  final MusicBrainzLabelDto? label;

  Map<String, dynamic> toJson() => _$MusicBrainzLabelInfoDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzLabelDto {
  const MusicBrainzLabelDto({this.id, this.name});

  factory MusicBrainzLabelDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzLabelDtoFromJson(json);

  final String? id;
  final String? name;

  Map<String, dynamic> toJson() => _$MusicBrainzLabelDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzMediaDto {
  const MusicBrainzMediaDto({
    this.format,
    this.discCount,
    this.trackCount,
    this.tracks,
  });

  factory MusicBrainzMediaDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzMediaDtoFromJson(json);

  final String? format;
  @JsonKey(name: 'disc-count')
  final int? discCount;
  @JsonKey(name: 'track-count')
  final int? trackCount;
  final List<MusicBrainzTrackDto>? tracks;

  Map<String, dynamic> toJson() => _$MusicBrainzMediaDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzTrackDto {
  const MusicBrainzTrackDto({this.id, this.title, this.number, this.length});

  factory MusicBrainzTrackDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzTrackDtoFromJson(json);

  final String? id;
  final String? title;
  final String? number;
  final int? length;

  Map<String, dynamic> toJson() => _$MusicBrainzTrackDtoToJson(this);
}

@JsonSerializable()
class MusicBrainzTagDto {
  const MusicBrainzTagDto({this.count, this.name});

  factory MusicBrainzTagDto.fromJson(Map<String, dynamic> json) =>
      _$MusicBrainzTagDtoFromJson(json);

  final int? count;
  final String? name;

  Map<String, dynamic> toJson() => _$MusicBrainzTagDtoToJson(this);
}
