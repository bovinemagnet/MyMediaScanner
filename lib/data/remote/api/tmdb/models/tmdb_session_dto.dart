import 'package:json_annotation/json_annotation.dart';

part 'tmdb_session_dto.g.dart';

@JsonSerializable()
class TmdbSessionDto {
  const TmdbSessionDto({required this.success, required this.sessionId});

  factory TmdbSessionDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSessionDtoFromJson(json);

  final bool success;
  @JsonKey(name: 'session_id')
  final String sessionId;

  Map<String, dynamic> toJson() => _$TmdbSessionDtoToJson(this);
}
