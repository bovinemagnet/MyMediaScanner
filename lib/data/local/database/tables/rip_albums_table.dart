import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';

class RipAlbumsTable extends Table {
  @override
  String get tableName => 'rip_albums';

  TextColumn get id => text()();
  TextColumn get libraryPath => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get albumTitle => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get trackCount => integer()();
  IntColumn get discCount => integer().withDefault(const Constant(1))();
  IntColumn get totalSizeBytes => integer()();
  TextColumn get mediaItemId =>
      text().nullable().references(MediaItemsTable, #id)();
  IntColumn get lastScannedAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
