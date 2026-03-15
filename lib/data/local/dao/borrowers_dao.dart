import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/borrowers_table.dart';

part 'borrowers_dao.g.dart';

@DriftAccessor(tables: [BorrowersTable])
class BorrowersDao extends DatabaseAccessor<AppDatabase>
    with _$BorrowersDaoMixin {
  BorrowersDao(super.db);

  Stream<List<BorrowersTableData>> watchAll() {
    return (select(borrowersTable)..where((t) => t.deleted.equals(0))).watch();
  }

  Future<BorrowersTableData?> getById(String id) {
    return (select(borrowersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertBorrower(BorrowersTableCompanion companion) {
    return into(borrowersTable).insert(companion);
  }

  Future<void> updateBorrower(BorrowersTableCompanion companion) {
    return (update(borrowersTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(borrowersTable)..where((t) => t.id.equals(id))).write(
      BorrowersTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}
