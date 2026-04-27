import 'dart:async';

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
  ///
  /// The previous implementation merged source and ticks via
  /// `asyncExpand` over an inner periodic generator, which never
  /// completes — so subsequent source events queued forever and the
  /// overdue list froze after first emission. We now drive both inputs
  /// from a single controller so source updates and minute ticks each
  /// trigger an emission against the latest cached row set.
  Stream<List<LoansTableData>> watchOverdueLoans() {
    final controller = StreamController<List<LoansTableData>>();
    StreamSubscription<List<LoansTableData>>? sub;
    Timer? timer;
    var latest = const <LoansTableData>[];

    void emit() {
      if (!controller.isClosed) {
        controller.add(_filterOverdue(latest));
      }
    }

    controller.onListen = () {
      sub = (select(loansTable)
            ..where((t) =>
                t.returnedAt.isNull() &
                t.deleted.equals(0) &
                t.dueAt.isNotNull()))
          .watch()
          .listen(
        (rows) {
          latest = rows;
          emit();
        },
        // Forward the error AND terminate the stream. Forwarding alone
        // (the prior behaviour) left the controller open with the
        // periodic timer still firing emit() on stale data — subscribers
        // that didn't react to the error then sat indefinitely on a
        // half-broken stream. Closing here gives them a clean
        // "stream done" signal so they can rebuild.
        onError: (Object error, StackTrace stack) async {
          if (!controller.isClosed) {
            controller.addError(error, stack);
            timer?.cancel();
            timer = null;
            await controller.close();
          }
        },
      );
      timer = Timer.periodic(const Duration(seconds: 60), (_) => emit());
    };

    controller.onCancel = () async {
      await sub?.cancel();
      timer?.cancel();
      sub = null;
      timer = null;
    };

    return controller.stream;
  }

  static List<LoansTableData> _filterOverdue(List<LoansTableData> rows) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return rows
        .where((r) => r.dueAt != null && r.dueAt! < nowMs)
        .toList();
  }

  Future<LoansTableData?> getById(String id) {
    return (select(loansTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
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
