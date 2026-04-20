import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/loans_table.dart';

part 'loans_dao.g.dart';

@DriftAccessor(tables: [LoansTable])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  Stream<List<LoansTableData>> watchAll() {
    return (select(loansTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.lentAt)]))
        .watch();
  }

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

  /// Overdue = active loans whose `due_at` is before the current time.
  ///
  /// We watch every active (non-returned, non-deleted) loan and filter
  /// in-memory so that a loan crossing its due date while the stream is
  /// open re-emits on the next periodic tick. Previously `now` was
  /// captured at stream-creation time and embedded in the SQL `WHERE`,
  /// so a loan that silently became overdue mid-session never appeared
  /// until some row mutated.
  Stream<List<LoansTableData>> watchOverdueLoans() {
    final source = (select(loansTable)
          ..where((t) =>
              t.returnedAt.isNull() &
              t.deleted.equals(0) &
              t.dueAt.isNotNull()))
        .watch();

    // Combine with a 60-second tick so passage of time alone causes
    // re-emission. Start with an immediate tick so the first frame has
    // the overdue set without waiting a minute.
    final ticks =
        Stream<void>.periodic(const Duration(seconds: 60)).cast<void>();
    return source.asyncExpand((rows) async* {
      yield _filterOverdue(rows);
      await for (final _ in ticks) {
        yield _filterOverdue(rows);
      }
    });
  }

  static List<LoansTableData> _filterOverdue(List<LoansTableData> rows) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return rows
        .where((r) => r.dueAt != null && r.dueAt! < nowMs)
        .toList();
  }

  Future<void> insertLoan(LoansTableCompanion companion) {
    return into(loansTable).insert(companion);
  }

  Future<void> updateLoan(LoansTableCompanion companion) {
    return (update(loansTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  Future<void> updateDueDate(String loanId, int? dueAt, int updatedAt) {
    return (update(loansTable)..where((t) => t.id.equals(loanId))).write(
      LoansTableCompanion(
        dueAt: Value(dueAt),
        updatedAt: Value(updatedAt),
      ),
    );
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
