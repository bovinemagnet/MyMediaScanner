// Integration tests for shelf CRUD operations.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart' as drift;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

import 'helpers/test_app.dart';

void main() {
  group('shelf CRUD', () {
    Future<void> setWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('shelves screen shows empty state', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shelves').first);
      await tester.pumpAndSettle();

      expect(
        find.text('No shelves yet. Create one to organise your collection!'),
        findsOneWidget,
      );
      expect(find.text('New Shelf'), findsWidgets); // header button + empty state button
    });

    testWidgets('create shelf via dialog', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shelves').first);
      await tester.pumpAndSettle();

      // Tap "New Shelf" button in the header
      await tester.tap(find.text('New Shelf').first);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Create Shelf'), findsOneWidget);

      // Enter shelf name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'My Test Shelf');
      await tester.pumpAndSettle();

      // Tap Create button in dialog
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Shelf should appear in the list
      expect(find.text('My Test Shelf'), findsOneWidget);
      expect(
        find.text('No shelves yet. Create one to organise your collection!'),
        findsNothing,
      );
    });

    testWidgets('rename shelf via context menu', (tester) async {
      await setWideScreen(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Create a shelf first via the database
      final now = DateTime.now().millisecondsSinceEpoch;
      await res.db.shelvesDao.insertShelf(
        ShelvesTableCompanion(
          id: const drift.Value('shelf-1'),
          name: const drift.Value('Original Name'),
          sortOrder: const drift.Value(0),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      await tester.tap(find.text('Shelves').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Original Name'), findsOneWidget);

      // Right-click to open context menu
      await tester.tap(
        find.text('Original Name'),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      // Tap Rename in context menu
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Dialog should appear with current name
      expect(find.text('Rename Shelf'), findsOneWidget);

      // Clear and enter new name
      final nameField = find.byType(TextField);
      await tester.enterText(nameField.first, 'Updated Name');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rename').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Updated Name'), findsOneWidget);
      expect(find.text('Original Name'), findsNothing);
    });

    testWidgets('delete shelf via context menu', (tester) async {
      await setWideScreen(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Create a shelf
      final now = DateTime.now().millisecondsSinceEpoch;
      await res.db.shelvesDao.insertShelf(
        ShelvesTableCompanion(
          id: const drift.Value('shelf-del'),
          name: const drift.Value('Doomed Shelf'),
          sortOrder: const drift.Value(0),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );

      await tester.tap(find.text('Shelves').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Doomed Shelf'), findsOneWidget);

      // Right-click to open context menu
      await tester.tap(
        find.text('Doomed Shelf'),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm dialog
      expect(find.text('Delete shelf?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Shelf should be gone
      expect(find.text('Doomed Shelf'), findsNothing);
    });
  });
}
