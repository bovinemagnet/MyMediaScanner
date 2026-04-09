// Integration tests for lending and borrower management.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('lending', () {
    Future<void> setWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> navigateToBorrowers(WidgetTester tester) async {
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll down to reveal the Borrowers list tile
      await tester.drag(find.byType(ListView).last, const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Borrowers').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    testWidgets('borrowers screen shows empty state', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await navigateToBorrowers(tester);

      expect(find.text('No borrowers yet'), findsOneWidget);
      expect(find.text('Add Borrower'), findsOneWidget);
    });

    testWidgets('add borrower via dialog', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await navigateToBorrowers(tester);

      // Tap the Add Borrower button in the screen header
      await tester.tap(find.text('Add Borrower').first);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Add Borrower'), findsWidgets);

      // Enter name in the first TextField
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Alice Smith');
      await tester.pumpAndSettle();

      // Enter email in the second TextField
      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'alice@example.com');
      await tester.pumpAndSettle();

      // Tap Add to confirm
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Borrower should appear in the list
      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('search filters borrowers', (tester) async {
      await setWideScreen(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Seed two borrowers directly via DAO
      final now = DateTime.now().millisecondsSinceEpoch;
      await res.db.borrowersDao.insertBorrower(
        BorrowersTableCompanion(
          id: const drift.Value('borrower-alice'),
          name: const drift.Value('Alice Smith'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );
      await res.db.borrowersDao.insertBorrower(
        BorrowersTableCompanion(
          id: const drift.Value('borrower-bob'),
          name: const drift.Value('Bob Jones'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      await navigateToBorrowers(tester);

      // Both borrowers should be visible
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);

      // Enter search term in the search TextField (first TextField on the screen)
      await tester.enterText(find.byType(TextField).first, 'Alice');
      await tester.pumpAndSettle();

      // Only Alice should remain visible
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsNothing);
    });

    testWidgets('borrower with active loan shows badge', (tester) async {
      await setWideScreen(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      final now = DateTime.now().millisecondsSinceEpoch;

      // Seed a borrower
      await res.db.borrowersDao.insertBorrower(
        BorrowersTableCompanion(
          id: const drift.Value('borrower-lender'),
          name: const drift.Value('Carol White'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      // Seed a media item
      final itemId = await seedSingleItem(
        res.db,
        id: 'item-for-loan',
        title: 'Borrowed Film',
      );

      // Seed an active loan (no returnedAt = active)
      await res.db.loansDao.insertLoan(
        LoansTableCompanion(
          id: const drift.Value('loan-active'),
          mediaItemId: drift.Value(itemId),
          borrowerId: const drift.Value('borrower-lender'),
          lentAt: drift.Value(now),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      await navigateToBorrowers(tester);

      // The active loan badge should be visible
      expect(find.text('1 active'), findsOneWidget);
    });

    testWidgets('delete borrower removes from list', (tester) async {
      await setWideScreen(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      final now = DateTime.now().millisecondsSinceEpoch;

      // Seed a borrower
      await res.db.borrowersDao.insertBorrower(
        BorrowersTableCompanion(
          id: const drift.Value('borrower-delete'),
          name: const drift.Value('Dave Green'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      await navigateToBorrowers(tester);

      // Borrower should be visible
      expect(find.text('Dave Green'), findsOneWidget);

      // Tap the delete IconButton
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Borrower should be gone
      expect(find.text('Dave Green'), findsNothing);
    });
  });
}
