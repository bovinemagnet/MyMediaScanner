import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelf_items_table.dart';

part 'shelves_dao.g.dart';

@DriftAccessor(tables: [ShelvesTable, ShelfItemsTable])
class ShelvesDao extends DatabaseAccessor<AppDatabase>
    with _$ShelvesDaoMixin {
  ShelvesDao(super.db);

  Stream<List<ShelvesTableData>> watchAll() {
    return (select(shelvesTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<ShelvesTableData?> getById(String id) {
    return (select(shelvesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Bulk fetch of `updated_at` keyed by id — one query for a whole pull
  /// batch instead of one [getById] per remote row.
  Future<Map<String, int>> updatedAtByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final rows = await (selectOnly(shelvesTable)
          ..addColumns([shelvesTable.id, shelvesTable.updatedAt])
          ..where(shelvesTable.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.read(shelvesTable.id)!: r.read(shelvesTable.updatedAt)!,
    };
  }

  Future<void> insertShelf(ShelvesTableCompanion shelf) {
    return into(shelvesTable).insert(shelf);
  }

  Future<void> updateShelf(ShelvesTableCompanion shelf) {
    return (update(shelvesTable)..where((t) => t.id.equals(shelf.id.value)))
        .write(shelf);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(shelvesTable)..where((t) => t.id.equals(id))).write(
      ShelvesTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Upsert: re-adding a previously removed item must resurrect the
  /// soft-deleted row, clearing its tombstone.
  Future<void> addItem(
    String shelfId,
    String mediaItemId,
    int position, {
    int? updatedAt,
  }) {
    return into(shelfItemsTable).insertOnConflictUpdate(
      ShelfItemsTableCompanion(
        shelfId: Value(shelfId),
        mediaItemId: Value(mediaItemId),
        position: Value(position),
        updatedAt:
            Value(updatedAt ?? DateTime.now().millisecondsSinceEpoch),
        deleted: const Value(0),
      ),
    );
  }

  /// Soft delete: the tombstone row (deleted = 1) is what replicates the
  /// removal to other devices via sync.
  Future<void> removeItem(
    String shelfId,
    String mediaItemId, {
    int? updatedAt,
  }) {
    return (update(shelfItemsTable)
          ..where((t) =>
              t.shelfId.equals(shelfId) &
              t.mediaItemId.equals(mediaItemId)))
        .write(ShelfItemsTableCompanion(
      deleted: const Value(1),
      updatedAt: Value(updatedAt ?? DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<List<String>> getMediaItemIdsForShelf(String shelfId) async {
    final rows = await (select(shelfItemsTable)
          ..where((t) => t.shelfId.equals(shelfId) & t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => r.mediaItemId).toList();
  }

  /// Atomically rewrite the ordering of items on [shelfId]: every live
  /// row is first tombstoned, then the surviving ids are upserted back
  /// at dense indices 0..N-1. Items absent from [orderedMediaItemIds]
  /// keep the tombstone, which is how their removal syncs; positions
  /// stay dense and unique (the previous single-row `addItem` reorder
  /// produced collisions on any move).
  Future<void> reorderItems(
    String shelfId,
    List<String> orderedMediaItemIds, {
    int? updatedAt,
  }) async {
    final stamp = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      await (update(shelfItemsTable)
            ..where((t) => t.shelfId.equals(shelfId)))
          .write(ShelfItemsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(stamp),
      ));
      for (var i = 0; i < orderedMediaItemIds.length; i++) {
        await into(shelfItemsTable).insertOnConflictUpdate(
          ShelfItemsTableCompanion(
            shelfId: Value(shelfId),
            mediaItemId: Value(orderedMediaItemIds[i]),
            position: Value(i),
            updatedAt: Value(stamp),
            deleted: const Value(0),
          ),
        );
      }
    });
  }

  /// Local `updated_at` for a membership, or null when no row exists.
  /// Used by pull's last-write-wins comparison.
  Future<int?> itemUpdatedAt(String shelfId, String mediaItemId) async {
    final row = await (select(shelfItemsTable)
          ..where((t) =>
              t.shelfId.equals(shelfId) &
              t.mediaItemId.equals(mediaItemId)))
        .getSingleOrNull();
    return row?.updatedAt;
  }

  /// Raw upsert used by sync pull — writes whatever the remote row says,
  /// including tombstones.
  Future<void> upsertItemRow(ShelfItemsTableCompanion row) {
    return into(shelfItemsTable).insertOnConflictUpdate(row);
  }
}
