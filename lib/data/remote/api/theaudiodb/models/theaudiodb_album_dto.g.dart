// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theaudiodb_album_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TheAudioDbAlbumResponseDto _$TheAudioDbAlbumResponseDtoFromJson(
  Map<String, dynamic> json,
) => TheAudioDbAlbumResponseDto(
  album: (json['album'] as List<dynamic>?)
      ?.map((e) => TheAudioDbAlbumDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TheAudioDbAlbumResponseDtoToJson(
  TheAudioDbAlbumResponseDto instance,
) => <String, dynamic>{'album': instance.album};

TheAudioDbAlbumDto _$TheAudioDbAlbumDtoFromJson(Map<String, dynamic> json) =>
    TheAudioDbAlbumDto(
      idAlbum: json['idAlbum'] as String?,
      strAlbum: json['strAlbum'] as String?,
      strArtist: json['strArtist'] as String?,
      intYearReleased: json['intYearReleased'] as String?,
      strGenre: json['strGenre'] as String?,
      strStyle: json['strStyle'] as String?,
      strDescriptionEN: json['strDescriptionEN'] as String?,
      strAlbumThumb: json['strAlbumThumb'] as String?,
      strAlbumCDart: json['strAlbumCDart'] as String?,
      intScore: json['intScore'] as String?,
      intScoreVotes: json['intScoreVotes'] as String?,
      strReview: json['strReview'] as String?,
    );

Map<String, dynamic> _$TheAudioDbAlbumDtoToJson(TheAudioDbAlbumDto instance) =>
    <String, dynamic>{
      'idAlbum': instance.idAlbum,
      'strAlbum': instance.strAlbum,
      'strArtist': instance.strArtist,
      'intYearReleased': instance.intYearReleased,
      'strGenre': instance.strGenre,
      'strStyle': instance.strStyle,
      'strDescriptionEN': instance.strDescriptionEN,
      'strAlbumThumb': instance.strAlbumThumb,
      'strAlbumCDart': instance.strAlbumCDart,
      'intScore': instance.intScore,
      'intScoreVotes': instance.intScoreVotes,
      'strReview': instance.strReview,
    };
