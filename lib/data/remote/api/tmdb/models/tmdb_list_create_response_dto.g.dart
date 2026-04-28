// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_list_create_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbListCreateResponseDto _$TmdbListCreateResponseDtoFromJson(
  Map<String, dynamic> json,
) => TmdbListCreateResponseDto(
  success: json['success'] as bool,
  listId: (json['list_id'] as num).toInt(),
  statusCode: (json['status_code'] as num?)?.toInt(),
  statusMessage: json['status_message'] as String?,
);

Map<String, dynamic> _$TmdbListCreateResponseDtoToJson(
  TmdbListCreateResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'list_id': instance.listId,
  'status_code': instance.statusCode,
  'status_message': instance.statusMessage,
};
