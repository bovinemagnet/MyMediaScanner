import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';

class ShelfItemsTable extends Table {
  @override
  String get tableName => 'shelf_items';

  TextColumn get shelfId =>
      text().references(ShelvesTable, #id)();
  TextColumn get mediaItemId =>
      text().references(MediaItemsTable, #id)();
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Last-write-wins basis for sync (epoch millis).
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// Soft-delete tombstone so removals replicate; readers filter on 0.
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {shelfId, mediaItemId};
}
