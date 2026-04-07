import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/sync_log_table.dart';

part 'sync_log_dao.g.dart';

@DriftAccessor(tables: [SyncLogTable])
class SyncLogDao extends DatabaseAccessor<AppDatabase>
    with _$SyncLogDaoMixin {
  SyncLogDao(super.db);

  Future<List<SyncLogTableData>> getPending() {
    return (select(syncLogTable)
          ..where((t) => t.synced.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<int> watchPendingCount() {
    return (selectOnly(syncLogTable)
          ..where(syncLogTable.synced.equals(0))
          ..addColumns([syncLogTable.id.count()]))
        .map((row) => row.read(syncLogTable.id.count()) ?? 0)
        .watchSingle();
  }

  Future<void> insertLog(SyncLogTableCompanion log) {
    return into(syncLogTable).insert(log);
  }

  Future<void> markSynced(String id) {
    return (update(syncLogTable)..where((t) => t.id.equals(id))).write(
      const SyncLogTableCompanion(synced: Value(1)),
    );
  }

  Future<void> deleteAll() {
    return delete(syncLogTable).go();
  }

  /// Watch all sync log entries, ordered by creation time descending.
  Stream<List<SyncLogTableData>> watchAll() {
    return (select(syncLogTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get paginated sync history.
  Future<List<SyncLogTableData>> getHistory({
    int limit = 50,
    int offset = 0,
  }) {
    return (select(syncLogTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Purge log entries older than the given epoch timestamp (milliseconds).
  Future<int> purgeOlderThan(int epochMs) {
    return (delete(syncLogTable)
          ..where((t) => t.createdAt.isSmallerThanValue(epochMs)))
        .go();
  }

  /// Get all failed (error) entries that have not been synced.
  Future<List<SyncLogTableData>> getFailedEntries() {
    return (select(syncLogTable)
          ..where((t) => t.synced.equals(0))
          ..where((t) => t.errorMessage.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Update a log entry with sync result details.
  Future<void> updateLogResult(
    String id, {
    int? durationMs,
    String? errorMessage,
    String? direction,
    String? resolvedBy,
  }) {
    return (update(syncLogTable)..where((t) => t.id.equals(id))).write(
      SyncLogTableCompanion(
        durationMs: durationMs != null ? Value(durationMs) : const Value.absent(),
        errorMessage:
            errorMessage != null ? Value(errorMessage) : const Value.absent(),
        direction:
            direction != null ? Value(direction) : const Value.absent(),
        resolvedBy:
            resolvedBy != null ? Value(resolvedBy) : const Value.absent(),
        attemptedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
