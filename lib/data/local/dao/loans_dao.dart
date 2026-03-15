import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/loans_table.dart';

part 'loans_dao.g.dart';

@DriftAccessor(tables: [LoansTable])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  Stream<List<LoansTableData>> watchActiveLoans() {
    return (select(loansTable)
          ..where(
              (t) => t.returnedAt.isNull() & t.deleted.equals(0)))
        .watch();
  }

  Stream<LoansTableData?> watchActiveLoanForItem(String mediaItemId) {
    return (select(loansTable)
          ..where((t) =>
              t.mediaItemId.equals(mediaItemId) &
              t.returnedAt.isNull() &
              t.deleted.equals(0)))
        .watchSingleOrNull();
  }

  Stream<List<LoansTableData>> watchLoansForItem(String mediaItemId) {
    return (select(loansTable)
          ..where((t) =>
              t.mediaItemId.equals(mediaItemId) & t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.lentAt)]))
        .watch();
  }

  Stream<List<LoansTableData>> watchLoansForBorrower(String borrowerId) {
    return (select(loansTable)
          ..where(
              (t) => t.borrowerId.equals(borrowerId) & t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.lentAt)]))
        .watch();
  }

  Future<void> insertLoan(LoansTableCompanion companion) {
    return into(loansTable).insert(companion);
  }

  Future<void> updateLoan(LoansTableCompanion companion) {
    return (update(loansTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  Future<void> returnItem(String loanId, int returnedAt, int updatedAt) {
    return (update(loansTable)..where((t) => t.id.equals(loanId))).write(
      LoansTableCompanion(
        returnedAt: Value(returnedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}
