import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_record.freezed.dart';
part 'sync_record.g.dart';

@freezed
sealed class SyncRecord with _$SyncRecord {
  const factory SyncRecord({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required int createdAt,
  }) = _SyncRecord;

  factory SyncRecord.fromJson(Map<String, dynamic> json) =>
      _$SyncRecordFromJson(json);
}
