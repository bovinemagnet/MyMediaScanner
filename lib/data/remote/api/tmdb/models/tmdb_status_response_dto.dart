import 'package:json_annotation/json_annotation.dart';

part 'tmdb_status_response_dto.g.dart';

/// Generic TMDB success/status payload returned by mutation endpoints.
@JsonSerializable()
class TmdbStatusResponseDto {
  const TmdbStatusResponseDto({
    required this.statusCode,
    this.statusMessage,
    this.success,
  });

  factory TmdbStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbStatusResponseDtoFromJson(json);

  @JsonKey(name: 'status_code')
  final int statusCode;
  @JsonKey(name: 'status_message')
  final String? statusMessage;
  final bool? success;

  Map<String, dynamic> toJson() => _$TmdbStatusResponseDtoToJson(this);
}
