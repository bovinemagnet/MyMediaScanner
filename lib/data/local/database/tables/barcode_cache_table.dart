import 'package:drift/drift.dart';

class BarcodeCacheTable extends Table {
  @override
  String get tableName => 'barcode_cache';

  TextColumn get barcode => text()();
  TextColumn get mediaTypeHint => text().nullable()();
  TextColumn get responseJson => text()();
  TextColumn get sourceApi => text()();
  IntColumn get cachedAt => integer()();

  @override
  Set<Column> get primaryKey => {barcode};
}
