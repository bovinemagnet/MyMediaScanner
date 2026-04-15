import 'package:drift/drift.dart';

/// Hierarchical physical-location entity (Room → Shelf → Box → Slot).
///
/// Distinct from `shelves` — locations describe where the item physically
/// lives, while shelves are virtual collections. A location can have a
/// nullable `parent_id` that references another row in this table; depth
/// is unbounded and enforced only by the application (DAO) which prevents
/// cycles when reparenting.
class LocationsTable extends Table {
  @override
  String get tableName => 'locations';

  TextColumn get id => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
