// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musicbrainz_release_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicBrainzSearchResponseDto _$MusicBrainzSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzSearchResponseDto(
  count: (json['count'] as num?)?.toInt(),
  releases: (json['releases'] as List<dynamic>?)
      ?.map((e) => MusicBrainzReleaseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MusicBrainzSearchResponseDtoToJson(
  MusicBrainzSearchResponseDto instance,
) => <String, dynamic>{'count': instance.count, 'releases': instance.releases};

MusicBrainzReleaseDto _$MusicBrainzReleaseDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzReleaseDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  status: json['status'] as String?,
  date: json['date'] as String?,
  country: json['country'] as String?,
  barcode: json['barcode'] as String?,
  score: (json['score'] as num?)?.toInt(),
  packaging: json['packaging'] as String?,
  artistCredit: (json['artist-credit'] as List<dynamic>?)
      ?.map(
        (e) => MusicBrainzArtistCreditDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  releaseGroup: json['release-group'] == null
      ? null
      : MusicBrainzReleaseGroupDto.fromJson(
          json['release-group'] as Map<String, dynamic>,
        ),
  labelInfo: (json['label-info'] as List<dynamic>?)
      ?.map((e) => MusicBrainzLabelInfoDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => MusicBrainzMediaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => MusicBrainzTagDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  trackCount: (json['track-count'] as num?)?.toInt(),
);

Map<String, dynamic> _$MusicBrainzReleaseDtoToJson(
  MusicBrainzReleaseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'date': instance.date,
  'country': instance.country,
  'barcode': instance.barcode,
  'score': instance.score,
  'packaging': instance.packaging,
  'artist-credit': instance.artistCredit,
  'release-group': instance.releaseGroup,
  'label-info': instance.labelInfo,
  'media': instance.media,
  'tags': instance.tags,
  'track-count': instance.trackCount,
};

MusicBrainzArtistCreditDto _$MusicBrainzArtistCreditDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzArtistCreditDto(
  name: json['name'] as String?,
  artist: json['artist'] == null
      ? null
      : MusicBrainzArtistDto.fromJson(json['artist'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MusicBrainzArtistCreditDtoToJson(
  MusicBrainzArtistCreditDto instance,
) => <String, dynamic>{'name': instance.name, 'artist': instance.artist};

MusicBrainzArtistDto _$MusicBrainzArtistDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzArtistDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  sortName: json['sort-name'] as String?,
);

Map<String, dynamic> _$MusicBrainzArtistDtoToJson(
  MusicBrainzArtistDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort-name': instance.sortName,
};

MusicBrainzReleaseGroupDto _$MusicBrainzReleaseGroupDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzReleaseGroupDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  primaryType: json['primary-type'] as String?,
  secondaryTypes: (json['secondary-types'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MusicBrainzReleaseGroupDtoToJson(
  MusicBrainzReleaseGroupDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'primary-type': instance.primaryType,
  'secondary-types': instance.secondaryTypes,
};

MusicBrainzLabelInfoDto _$MusicBrainzLabelInfoDtoFromJson(
  Map<String, dynamic> json,
) => MusicBrainzLabelInfoDto(
  catalogNumber: json['catalog-number'] as String?,
  label: json['label'] == null
      ? null
      : MusicBrainzLabelDto.fromJson(json['label'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MusicBrainzLabelInfoDtoToJson(
  MusicBrainzLabelInfoDto instance,
) => <String, dynamic>{
  'catalog-number': instance.catalogNumber,
  'label': instance.label,
};

MusicBrainzLabelDto _$MusicBrainzLabelDtoFromJson(Map<String, dynamic> json) =>
    MusicBrainzLabelDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$MusicBrainzLabelDtoToJson(
  MusicBrainzLabelDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

MusicBrainzMediaDto _$MusicBrainzMediaDtoFromJson(Map<String, dynamic> json) =>
    MusicBrainzMediaDto(
      format: json['format'] as String?,
      discCount: (json['disc-count'] as num?)?.toInt(),
      trackCount: (json['track-count'] as num?)?.toInt(),
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((e) => MusicBrainzTrackDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MusicBrainzMediaDtoToJson(
  MusicBrainzMediaDto instance,
) => <String, dynamic>{
  'format': instance.format,
  'disc-count': instance.discCount,
  'track-count': instance.trackCount,
  'tracks': instance.tracks,
};

MusicBrainzTrackDto _$MusicBrainzTrackDtoFromJson(Map<String, dynamic> json) =>
    MusicBrainzTrackDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      number: json['number'] as String?,
      length: (json['length'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MusicBrainzTrackDtoToJson(
  MusicBrainzTrackDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'number': instance.number,
  'length': instance.length,
};

MusicBrainzTagDto _$MusicBrainzTagDtoFromJson(Map<String, dynamic> json) =>
    MusicBrainzTagDto(
      count: (json['count'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$MusicBrainzTagDtoToJson(MusicBrainzTagDto instance) =>
    <String, dynamic>{'count': instance.count, 'name': instance.name};
