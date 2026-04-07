// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_conflict.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncConflict _$SyncConflictFromJson(Map<String, dynamic> json) =>
    _SyncConflict(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      fieldName: json['fieldName'] as String,
      localValue: json['localValue'],
      remoteValue: json['remoteValue'],
      localUpdatedAt: (json['localUpdatedAt'] as num).toInt(),
      remoteUpdatedAt: (json['remoteUpdatedAt'] as num).toInt(),
      resolution:
          $enumDecodeNullable(
            _$ConflictResolutionEnumMap,
            json['resolution'],
          ) ??
          ConflictResolution.keepLocal,
    );

Map<String, dynamic> _$SyncConflictToJson(_SyncConflict instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'fieldName': instance.fieldName,
      'localValue': instance.localValue,
      'remoteValue': instance.remoteValue,
      'localUpdatedAt': instance.localUpdatedAt,
      'remoteUpdatedAt': instance.remoteUpdatedAt,
      'resolution': _$ConflictResolutionEnumMap[instance.resolution]!,
    };

const _$ConflictResolutionEnumMap = {
  ConflictResolution.keepLocal: 'keepLocal',
  ConflictResolution.keepRemote: 'keepRemote',
  ConflictResolution.keepBoth: 'keepBoth',
};
