import 'package:json_annotation/json_annotation.dart';

part 'tmdb_list_create_response_dto.g.dart';

/// Response from `POST /list` (v3). The new list ID is returned as `list_id`.
@JsonSerializable()
class TmdbListCreateResponseDto {
  const TmdbListCreateResponseDto({
    required this.success,
    required this.listId,
    this.statusCode,
    this.statusMessage,
  });

  factory TmdbListCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbListCreateResponseDtoFromJson(json);

  final bool success;
  @JsonKey(name: 'list_id')
  final int listId;
  @JsonKey(name: 'status_code')
  final int? statusCode;
  @JsonKey(name: 'status_message')
  final String? statusMessage;

  Map<String, dynamic> toJson() => _$TmdbListCreateResponseDtoToJson(this);
}
