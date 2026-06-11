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

  /// Bulk fetch of `updated_at` keyed by id — one query for a whole pull
  /// batch instead of one [getById] per remote row.
  Future<Map<String, int>> updatedAtByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final rows = await (selectOnly(borrowersTable)
          ..addColumns([borrowersTable.id, borrowersTable.updatedAt])
          ..where(borrowersTable.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.read(borrowersTable.id)!: r.read(borrowersTable.updatedAt)!,
    };
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
