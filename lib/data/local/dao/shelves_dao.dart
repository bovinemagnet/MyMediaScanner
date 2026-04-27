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

  Future<void> addItem(String shelfId, String mediaItemId, int position) {
    return into(shelfItemsTable).insert(
      ShelfItemsTableCompanion(
        shelfId: Value(shelfId),
        mediaItemId: Value(mediaItemId),
        position: Value(position),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> removeItem(String shelfId, String mediaItemId) {
    return (delete(shelfItemsTable)
          ..where((t) =>
              t.shelfId.equals(shelfId) &
              t.mediaItemId.equals(mediaItemId)))
        .go();
  }

  Future<List<String>> getMediaItemIdsForShelf(String shelfId) async {
    final rows = await (select(shelfItemsTable)
          ..where((t) => t.shelfId.equals(shelfId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => r.mediaItemId).toList();
  }

  /// Atomically rewrite the ordering of items on [shelfId]. Deletes every
  /// existing shelf_items row for the shelf and re-inserts them at indices
  /// 0..N-1 so positions are dense and unique. The previous single-row
  /// `addItem` reorder produced position collisions on any move.
  Future<void> reorderItems(
    String shelfId,
    List<String> orderedMediaItemIds,
  ) async {
    await transaction(() async {
      await (delete(shelfItemsTable)
            ..where((t) => t.shelfId.equals(shelfId)))
          .go();
      for (var i = 0; i < orderedMediaItemIds.length; i++) {
        await into(shelfItemsTable).insert(
          ShelfItemsTableCompanion(
            shelfId: Value(shelfId),
            mediaItemId: Value(orderedMediaItemIds[i]),
            position: Value(i),
          ),
        );
      }
    });
  }
}
