import 'package:drift/drift.dart';

/// Unresolved per-field sync conflicts, persisted so they survive a
/// restart (#131). The pull cursor advances past a conflicted row, so
/// an in-memory list was the only record of the conflict — and the
/// only thing holding the entity's pending push back.
class SyncConflictsTable extends Table {
  @override
  String get tableName => 'sync_conflicts';

  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldName => text()();

  /// JSON-encoded field values on each side.
  TextColumn get localValueJson => text()();
  TextColumn get remoteValueJson => text()();

  IntColumn get localUpdatedAt => integer()();
  IntColumn get remoteUpdatedAt => integer()();
  IntColumn get detectedAt => integer()();

  @override
  Set<Column> get primaryKey => {entityType, entityId, fieldName};
}
