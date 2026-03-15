import 'package:drift/drift.dart';

class BorrowersTable extends Table {
  @override
  String get tableName => 'borrowers';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
