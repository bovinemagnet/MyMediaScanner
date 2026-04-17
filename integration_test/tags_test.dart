// Integration tests for tag management in item detail panel.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_detail_panel.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('tags', () {
    testWidgets('new tag button is visible in detail panel', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Test Film',
        mediaType: 'film',
        barcode: '5051892209243',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Test Film'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(CollectionDetailPanel), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'New Tag'), findsOneWidget);
    });

    testWidgets('create tag via dialog', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Test Film',
        mediaType: 'film',
        barcode: '5051892209243',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Test Film'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Open the create tag dialog via the ActionChip
      await tester.tap(find.widgetWithText(ActionChip, 'New Tag'));
      await tester.pumpAndSettle();

      // Verify the dialog is visible
      expect(find.text('Create Tag'), findsOneWidget);

      // Enter the tag name into the dialog's TextField — scope by
      // AlertDialog ancestor since the Collection screen's SearchBar
      // also contains a TextField that `.first` would otherwise match.
      final dialogTextField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(dialogTextField, 'Horror');
      await tester.pumpAndSettle();

      // Tap the Create button
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The dialog should be dismissed
      expect(find.text('Create Tag'), findsNothing);

      // The new tag FilterChip should be visible and selected
      final horrorChip = find.widgetWithText(FilterChip, 'Horror');
      expect(horrorChip, findsOneWidget);
      final chip = tester.widget<FilterChip>(horrorChip);
      expect(chip.selected, isTrue);
    });

    testWidgets('pre-existing tags appear as filter chips', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Test Film',
        mediaType: 'film',
        barcode: '5051892209243',
      );

      // Insert a tag directly via DAO before navigating
      final now = DateTime.now().millisecondsSinceEpoch;
      await res.db.tagsDao.insertTag(
        TagsTableCompanion(
          id: const drift.Value('tag-1'),
          name: const drift.Value('Favourites'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Test Film'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // The pre-existing tag should appear as a FilterChip
      expect(find.widgetWithText(FilterChip, 'Favourites'), findsOneWidget);
    });

    testWidgets('toggle tag assignment', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      final itemId = await seedSingleItem(
        res.db,
        title: 'Test Film',
        mediaType: 'film',
        barcode: '5051892209243',
      );

      // Insert a tag and assign it to the item via DAO
      final now = DateTime.now().millisecondsSinceEpoch;
      const tagId = 'tag-assigned-1';
      await res.db.tagsDao.insertTag(
        TagsTableCompanion(
          id: const drift.Value(tagId),
          name: const drift.Value('Sci-Fi'),
          updatedAt: drift.Value(now),
          deleted: const drift.Value(0),
        ),
      );
      await res.db.tagsDao.assignToMediaItem(tagId, itemId);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Test Film'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // The assigned tag chip should be selected
      final sciFiChipFinder = find.widgetWithText(FilterChip, 'Sci-Fi');
      expect(sciFiChipFinder, findsOneWidget);
      final selectedChip = tester.widget<FilterChip>(sciFiChipFinder);
      expect(selectedChip.selected, isTrue);

      // Tap the chip to deselect (remove assignment)
      await tester.tap(sciFiChipFinder);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The chip should now be unselected
      final deselectedChip = tester.widget<FilterChip>(sciFiChipFinder);
      expect(deselectedChip.selected, isFalse);
    });
  });
}
