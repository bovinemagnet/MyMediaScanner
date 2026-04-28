// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_status_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbStatusResponseDto _$TmdbStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => TmdbStatusResponseDto(
  statusCode: (json['status_code'] as num).toInt(),
  statusMessage: json['status_message'] as String?,
  success: json['success'] as bool?,
);

Map<String, dynamic> _$TmdbStatusResponseDtoToJson(
  TmdbStatusResponseDto instance,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'status_message': instance.statusMessage,
  'success': instance.success,
};
