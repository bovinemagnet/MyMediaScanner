import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/borrowers_table.dart';

class LoansTable extends Table {
  @override
  String get tableName => 'loans';

  TextColumn get id => text()();
  TextColumn get mediaItemId => text().references(MediaItemsTable, #id)();
  TextColumn get borrowerId => text().references(BorrowersTable, #id)();
  IntColumn get lentAt => integer()();
  IntColumn get returnedAt => integer().nullable()();
  IntColumn get dueAt => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
