import 'package:json_annotation/json_annotation.dart';

part 'theaudiodb_album_dto.g.dart';

@JsonSerializable()
class TheAudioDbAlbumResponseDto {
  const TheAudioDbAlbumResponseDto({this.album});

  factory TheAudioDbAlbumResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TheAudioDbAlbumResponseDtoFromJson(json);

  final List<TheAudioDbAlbumDto>? album;

  Map<String, dynamic> toJson() => _$TheAudioDbAlbumResponseDtoToJson(this);
}

@JsonSerializable()
class TheAudioDbAlbumDto {
  const TheAudioDbAlbumDto({
    this.idAlbum,
    this.strAlbum,
    this.strArtist,
    this.intYearReleased,
    this.strGenre,
    this.strStyle,
    this.strDescriptionEN,
    this.strAlbumThumb,
    this.strAlbumCDart,
    this.intScore,
    this.intScoreVotes,
    this.strReview,
  });

  factory TheAudioDbAlbumDto.fromJson(Map<String, dynamic> json) =>
      _$TheAudioDbAlbumDtoFromJson(json);

  final String? idAlbum;
  final String? strAlbum;
  final String? strArtist;
  final String? intYearReleased;
  final String? strGenre;
  final String? strStyle;
  final String? strDescriptionEN;
  final String? strAlbumThumb;
  final String? strAlbumCDart;
  final String? intScore;
  final String? intScoreVotes;
  final String? strReview;

  Map<String, dynamic> toJson() => _$TheAudioDbAlbumDtoToJson(this);

  /// Critic score as double (0-10 scale, TheAudioDB uses 0-10).
  double? get effectiveScore =>
      intScore != null ? double.tryParse(intScore!) : null;
}
