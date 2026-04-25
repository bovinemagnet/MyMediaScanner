import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/loans_dao.dart';

void main() {
  late AppDatabase db;
  late LoansDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.loansDao;
  });

  tearDown(() => db.close());

  /// Helper to insert a media item (required by foreign key).
  Future<void> insertMediaItem(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.mediaItemsTable).insert(MediaItemsTableCompanion(
          id: Value(id),
          barcode: Value('barcode-$id'),
          barcodeType: const Value('ean13'),
          mediaType: const Value('film'),
          title: Value('Item $id'),
          dateAdded: Value(now),
          dateScanned: Value(now),
          updatedAt: Value(now),
        ));
  }

  /// Helper to insert a borrower (required by foreign key).
  Future<void> insertBorrower(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.borrowersTable).insert(BorrowersTableCompanion(
          id: Value(id),
          name: Value('Borrower $id'),
          updatedAt: Value(now),
        ));
  }

  group('LoansDao', () {
    test('insert and watch active loan for item', () async {
      await insertMediaItem('item-1');
      await insertBorrower('borrower-1');

      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertLoan(LoansTableCompanion(
        id: const Value('loan-1'),
        mediaItemId: const Value('item-1'),
        borrowerId: const Value('borrower-1'),
        lentAt: Value(now),
        updatedAt: Value(now),
      ));

      final activeLoan = await dao.watchActiveLoanForItem('item-1').first;
      expect(activeLoan, isNotNull);
      expect(activeLoan!.id, 'loan-1');
      expect(activeLoan.mediaItemId, 'item-1');
      expect(activeLoan.borrowerId, 'borrower-1');
      expect(activeLoan.returnedAt, isNull);
    });

    test('returnItem sets returnedAt', () async {
      await insertMediaItem('item-1');
      await insertBorrower('borrower-1');

      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertLoan(LoansTableCompanion(
        id: const Value('loan-1'),
        mediaItemId: const Value('item-1'),
        borrowerId: const Value('borrower-1'),
        lentAt: Value(now),
        updatedAt: Value(now),
      ));

      final returnTime = now + 86400000;
      await dao.returnItem('loan-1', returnTime, returnTime);

      final loan = await dao.watchActiveLoanForItem('item-1').first;
      expect(loan, isNull);

      // Verify through history
      final history = await dao.watchLoansForItem('item-1').first;
      expect(history.length, 1);
      expect(history.first.returnedAt, returnTime);
    });

    test('returned loan no longer appears in active loans', () async {
      await insertMediaItem('item-1');
      await insertBorrower('borrower-1');

      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertLoan(LoansTableCompanion(
        id: const Value('loan-1'),
        mediaItemId: const Value('item-1'),
        borrowerId: const Value('borrower-1'),
        lentAt: Value(now),
        updatedAt: Value(now),
      ));

      // Before return
      var active = await dao.watchActiveLoans().first;
      expect(active.length, 1);

      // After return
      await dao.returnItem('loan-1', now + 1000, now + 1000);
      active = await dao.watchActiveLoans().first;
      expect(active, isEmpty);
    });

    test(
      'watchOverdueLoans re-emits when a new loan is inserted after the first emission',
      () async {
        // Regression test for the bug where the overdue stream froze
        // after first emission because asyncExpand wrapped an inner
        // generator that never completed. Subsequent source events
        // (a brand-new loan) were never observed by the stream.
        await insertMediaItem('item-1');
        await insertMediaItem('item-2');
        await insertBorrower('borrower-1');

        final now = DateTime.now().millisecondsSinceEpoch;
        final pastDue = now - const Duration(days: 1).inMilliseconds;

        // First overdue loan exists at subscription time.
        await dao.insertLoan(LoansTableCompanion(
          id: const Value('loan-1'),
          mediaItemId: const Value('item-1'),
          borrowerId: const Value('borrower-1'),
          lentAt: Value(pastDue),
          dueAt: Value(pastDue),
          updatedAt: Value(now),
        ));

        final emissions = <List<int>>[];
        final sub = dao.watchOverdueLoans().listen(
          (rows) => emissions.add(rows.map((r) => r.dueAt!).toList()),
        );

        // Wait for first emission to land.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(emissions, isNotEmpty,
            reason: 'first emission should fire on subscribe');
        expect(emissions.last.length, 1);

        // Insert a second overdue loan — the source stream should fire
        // and the merged stream should emit the new combined set.
        await dao.insertLoan(LoansTableCompanion(
          id: const Value('loan-2'),
          mediaItemId: const Value('item-2'),
          borrowerId: const Value('borrower-1'),
          lentAt: Value(pastDue),
          dueAt: Value(pastDue),
          updatedAt: Value(now),
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(emissions.last.length, 2,
            reason:
                'second insert must reach the stream (the asyncExpand bug '
                'previously kept the stream stuck at the first emission)');
      },
    );
  });
}
