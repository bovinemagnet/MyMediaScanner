import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/sync_conflicts_table.dart';

part 'sync_conflicts_dao.g.dart';

@DriftAccessor(tables: [SyncConflictsTable])
class SyncConflictsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncConflictsDaoMixin {
  SyncConflictsDao(super.db);

  Future<List<SyncConflictsTableData>> getAll() {
    return (select(syncConflictsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.detectedAt),
            (t) => OrderingTerm.asc(t.entityId),
            (t) => OrderingTerm.asc(t.fieldName),
          ]))
        .get();
  }

  Future<int> count() async {
    final countExp = syncConflictsTable.fieldName.count();
    final row = await (selectOnly(syncConflictsTable)..addColumns([countExp]))
        .getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Ids of [entityType] entities with at least one unresolved conflict.
  Future<Set<String>> conflictedEntityIds(String entityType) async {
    final rows = await (selectOnly(syncConflictsTable, distinct: true)
          ..addColumns([syncConflictsTable.entityId])
          ..where(syncConflictsTable.entityType.equals(entityType)))
        .get();
    return {for (final r in rows) r.read(syncConflictsTable.entityId)!};
  }

  /// Replace every conflict recorded for one entity with [conflicts]
  /// (possibly none), atomically.
  Future<void> replaceForEntity(
    String entityType,
    String entityId,
    List<SyncConflictsTableCompanion> conflicts,
  ) {
    return transaction(() async {
      await (delete(syncConflictsTable)
            ..where((t) =>
                t.entityType.equals(entityType) &
                t.entityId.equals(entityId)))
          .go();
      if (conflicts.isNotEmpty) {
        await batch((b) => b.insertAll(syncConflictsTable, conflicts));
      }
    });
  }

  Future<int> deleteField(
    String entityType,
    String entityId,
    String fieldName,
  ) {
    return (delete(syncConflictsTable)
          ..where((t) =>
              t.entityType.equals(entityType) &
              t.entityId.equals(entityId) &
              t.fieldName.equals(fieldName)))
        .go();
  }

  Future<int> deleteAllConflicts() => delete(syncConflictsTable).go();
}
