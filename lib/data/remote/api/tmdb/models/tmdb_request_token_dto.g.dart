// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_request_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbRequestTokenDto _$TmdbRequestTokenDtoFromJson(Map<String, dynamic> json) =>
    TmdbRequestTokenDto(
      success: json['success'] as bool,
      requestToken: json['request_token'] as String,
      expiresAt: json['expires_at'] as String?,
    );

Map<String, dynamic> _$TmdbRequestTokenDtoToJson(
  TmdbRequestTokenDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'request_token': instance.requestToken,
  'expires_at': instance.expiresAt,
};
