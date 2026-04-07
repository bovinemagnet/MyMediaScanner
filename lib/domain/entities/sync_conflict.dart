import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_conflict.freezed.dart';
part 'sync_conflict.g.dart';

/// Represents a conflict detected during sync where the same field
/// has been modified on both the local and remote sides.
@freezed
sealed class SyncConflict with _$SyncConflict {
  const factory SyncConflict({
    required String entityType,
    required String entityId,
    required String fieldName,
    required dynamic localValue,
    required dynamic remoteValue,
    required int localUpdatedAt,
    required int remoteUpdatedAt,
    @Default(ConflictResolution.keepLocal)
    ConflictResolution resolution,
  }) = _SyncConflict;

  factory SyncConflict.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictFromJson(json);
}

/// How a sync conflict should be resolved.
enum ConflictResolution {
  keepLocal,
  keepRemote,
  keepBoth,
}
