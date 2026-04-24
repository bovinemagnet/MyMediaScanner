import 'package:json_annotation/json_annotation.dart';

part 'twitch_token_dto.g.dart';

/// Response from `POST https://id.twitch.tv/oauth2/token` for the
/// `client_credentials` grant.
///
/// The returned `accessToken` is the bearer token to send to IGDB (along
/// with the Twitch Client-ID as a separate header). `expiresIn` is the
/// lifetime in seconds — typically around 60 days.
@JsonSerializable()
class TwitchTokenDto {
  const TwitchTokenDto({
    this.accessToken,
    this.expiresIn,
    this.tokenType,
  });

  factory TwitchTokenDto.fromJson(Map<String, dynamic> json) =>
      _$TwitchTokenDtoFromJson(json);

  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  @JsonKey(name: 'token_type')
  final String? tokenType;

  Map<String, dynamic> toJson() => _$TwitchTokenDtoToJson(this);
}
