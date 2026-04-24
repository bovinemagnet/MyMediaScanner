// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitch_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitchTokenDto _$TwitchTokenDtoFromJson(Map<String, dynamic> json) =>
    TwitchTokenDto(
      accessToken: json['access_token'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      tokenType: json['token_type'] as String?,
    );

Map<String, dynamic> _$TwitchTokenDtoToJson(TwitchTokenDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
    };
