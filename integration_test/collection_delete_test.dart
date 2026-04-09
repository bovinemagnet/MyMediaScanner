// Integration tests for deleting items from the collection.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_detail_panel.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('collection delete', () {
    testWidgets('delete button is present in detail panel', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Panel Delete Test',
        mediaType: 'film',
        barcode: '5055201825407',
      );
      await tester.pumpAndSettle();

      // Navigate to Library via sidebar
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the item card to open the detail panel
      await tester.tap(find.text('Panel Delete Test'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Detail panel should be visible
      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // Delete button should be present in the toolbar
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('deleting item removes it from collection', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Item to Delete',
        mediaType: 'film',
        barcode: '5055201825408',
      );
      await seedSingleItem(
        res.db,
        title: 'Item to Keep',
        mediaType: 'book',
        barcode: '9780141036145',
      );
      await tester.pumpAndSettle();

      // Navigate to Library and verify both items are present
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(MediaItemCard), findsNWidgets(2));
      expect(find.text('Item to Delete'), findsOneWidget);
      expect(find.text('Item to Keep'), findsOneWidget);

      // Tap the item to be deleted
      await tester.tap(find.text('Item to Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the delete button in the detail panel toolbar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete item?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Deleted item should be gone; kept item should remain
      expect(find.text('Item to Delete'), findsNothing);
      expect(find.text('Item to Keep'), findsOneWidget);
    });

    testWidgets('empty state shown after deleting last item', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Last Item',
        mediaType: 'film',
        barcode: '5055201825409',
      );
      await tester.pumpAndSettle();

      // Navigate to Library
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Last Item'), findsOneWidget);

      // Tap the item to open the detail panel
      await tester.tap(find.text('Last Item'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap delete button and confirm
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete item?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Empty state message should be visible
      expect(
        find.text('No items yet. Scan a barcode to get started!'),
        findsOneWidget,
      );
    });
  });
}
