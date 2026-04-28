import 'package:json_annotation/json_annotation.dart';

part 'tmdb_request_token_dto.g.dart';

@JsonSerializable()
class TmdbRequestTokenDto {
  const TmdbRequestTokenDto({
    required this.success,
    required this.requestToken,
    this.expiresAt,
  });

  factory TmdbRequestTokenDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbRequestTokenDtoFromJson(json);

  final bool success;
  @JsonKey(name: 'request_token')
  final String requestToken;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  Map<String, dynamic> toJson() => _$TmdbRequestTokenDtoToJson(this);
}
