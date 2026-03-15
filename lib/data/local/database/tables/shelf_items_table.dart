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

  @override
  Set<Column> get primaryKey => {shelfId, mediaItemId};
}
