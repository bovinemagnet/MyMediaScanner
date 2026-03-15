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
}
