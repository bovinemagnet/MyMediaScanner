// Integration tests for item detail panel (desktop master-detail view).
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_detail_panel.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/metadata_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('item detail panel', () {
    testWidgets(
        'tapping an item shows detail panel with title and barcode',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Blade Runner 2049',
        mediaType: 'film',
        barcode: '5051892209243',
        barcodeType: 'ean13',
      );
      await tester.pumpAndSettle();

      // Navigate to Library via sidebar
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the item card to select it in the detail panel
      await tester.tap(find.text('Blade Runner 2049'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify the detail panel renders
      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // Title should be visible in the detail panel toolbar
      expect(find.text('Blade Runner 2049'), findsWidgets);

      // Barcode should appear in the metadata section
      expect(find.text('5051892209243 (ean13)'), findsOneWidget);
    });

    testWidgets('metadata section and star rating are visible',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Test Album',
        mediaType: 'music',
        barcode: '0602547202888',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Test Album'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // MetadataSection widget should be rendered
      expect(find.byType(MetadataSection), findsOneWidget);

      // The DETAILS header should be visible within the section
      expect(find.text('DETAILS'), findsOneWidget);

      // Star rating widget should be present
      expect(find.byType(StarRatingWidget), findsOneWidget);
    });

    testWidgets('detail panel has edit, refresh, and delete actions',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();

      await seedSingleItem(
        res.db,
        title: 'Action Test Item',
        mediaType: 'book',
        barcode: '9780141036144',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Action Test Item'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Toolbar action buttons should be present
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
