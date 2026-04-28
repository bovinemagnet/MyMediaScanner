// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbSessionDto _$TmdbSessionDtoFromJson(Map<String, dynamic> json) =>
    TmdbSessionDto(
      success: json['success'] as bool,
      sessionId: json['session_id'] as String,
    );

Map<String, dynamic> _$TmdbSessionDtoToJson(TmdbSessionDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'session_id': instance.sessionId,
    };
