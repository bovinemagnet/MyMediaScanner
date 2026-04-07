// DAO for batch session and queue item CRUD operations.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/batch_sessions_table.dart';
import 'package:mymediascanner/data/local/database/tables/batch_queue_items_table.dart';

part 'batch_session_dao.g.dart';

@DriftAccessor(tables: [BatchSessionsTable, BatchQueueItemsTable])
class BatchSessionDao extends DatabaseAccessor<AppDatabase>
    with _$BatchSessionDaoMixin {
  BatchSessionDao(super.db);

  /// Creates a new active batch session and returns its ID.
  Future<String> createSession(String id) async {
    await into(batchSessionsTable).insert(
      BatchSessionsTableCompanion.insert(
        id: id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: const Value('active'),
        itemCount: const Value(0),
      ),
    );
    return id;
  }

  /// Returns the current active session (at most one).
  Future<BatchSessionsTableData?> getActiveSession() {
    return (select(batchSessionsTable)
          ..where((t) => t.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Marks a session as completed or discarded.
  Future<void> completeSession(String id, {required String status}) {
    return (update(batchSessionsTable)..where((t) => t.id.equals(id))).write(
      BatchSessionsTableCompanion(
        status: Value(status),
        completedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Updates the item count for a session.
  Future<void> updateSessionItemCount(String id, int count) {
    return (update(batchSessionsTable)..where((t) => t.id.equals(id))).write(
      BatchSessionsTableCompanion(
        itemCount: Value(count),
      ),
    );
  }

  /// Returns a paginated list of completed/discarded sessions.
  Future<List<BatchSessionsTableData>> getSessionHistory({
    int limit = 20,
    int offset = 0,
  }) {
    return (select(batchSessionsTable)
          ..where((t) => t.status.isNotIn(['active']))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Inserts or updates a queue item.
  Future<void> upsertQueueItem(BatchQueueItemsTableCompanion item) {
    return into(batchQueueItemsTable).insertOnConflictUpdate(item);
  }

  /// Returns all queue items for a session, ordered by sort order.
  Future<List<BatchQueueItemsTableData>> getQueueItems(String sessionId) {
    return (select(batchQueueItemsTable)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Deletes a single queue item.
  Future<void> deleteQueueItem(String id) {
    return (delete(batchQueueItemsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all queue items for a session.
  Future<void> deleteSessionQueueItems(String sessionId) {
    return (delete(batchQueueItemsTable)
          ..where((t) => t.sessionId.equals(sessionId)))
        .go();
  }
}
