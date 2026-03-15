// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => _SyncRecord(
  entityType: json['entityType'] as String,
  entityId: json['entityId'] as String,
  operation: json['operation'] as String,
  payload: json['payload'] as Map<String, dynamic>,
  createdAt: (json['createdAt'] as num).toInt(),
);

Map<String, dynamic> _$SyncRecordToJson(_SyncRecord instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'operation': instance.operation,
      'payload': instance.payload,
      'createdAt': instance.createdAt,
    };
