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
  });
}
