// Integration tests for master-detail layout in collection screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_detail_panel.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('master-detail layout', () {
    Future<void> setUpWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('collection renders in master-detail mode on wide screen',
        (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      await seedSingleItem(res.db,
          title: 'Item One', mediaType: 'film', barcode: '1000000000001');
      await seedSingleItem(res.db,
          title: 'Item Two', mediaType: 'film', barcode: '1000000000002');
      await seedSingleItem(res.db,
          title: 'Item Three', mediaType: 'book', barcode: '1000000000003');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // MasterDetailLayout is present in the widget tree at desktop widths
      expect(find.byType(MasterDetailLayout), findsOneWidget);

      // All three seeded items should appear in the master list
      expect(find.byType(MediaItemCard), findsNWidgets(3));
    });

    testWidgets('selecting item opens detail panel alongside list',
        (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      await seedSingleItem(res.db,
          title: 'Film A', mediaType: 'film', barcode: '2000000000001');
      await seedSingleItem(res.db,
          title: 'Film B', mediaType: 'film', barcode: '2000000000002');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap Film A to open it in the detail panel
      await tester.tap(find.text('Film A'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Detail panel should now be visible
      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // Film A title should appear in the detail panel
      expect(find.text('Film A'), findsWidgets);

      // Film B should still be visible in the master list
      expect(find.text('Film B'), findsOneWidget);
    });

    testWidgets('close button dismisses detail panel', (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      await seedSingleItem(res.db,
          title: 'Close Me', mediaType: 'film', barcode: '3000000000001');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the item to open it in the detail panel
      await tester.tap(find.text('Close Me'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify detail panel is open
      expect(find.byType(CollectionDetailPanel), findsOneWidget);

      // Tap the close button to dismiss the detail panel
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Detail panel should be gone
      expect(find.byType(CollectionDetailPanel), findsNothing);
    });

    testWidgets('selecting different item updates detail panel',
        (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      await seedSingleItem(res.db,
          title: 'Alpha Item', mediaType: 'film', barcode: '4000000000001');
      await seedSingleItem(res.db,
          title: 'Beta Item', mediaType: 'film', barcode: '4000000000002');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Open Alpha Item in the detail panel
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Detail panel should show Alpha Item
      expect(find.byType(CollectionDetailPanel), findsOneWidget);
      expect(find.text('Alpha Item'), findsWidgets);

      // Tap Beta Item in the master list to switch selection
      await tester.tap(find.text('Beta Item'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Detail panel should now show Beta Item
      expect(find.byType(CollectionDetailPanel), findsOneWidget);
      expect(find.text('Beta Item'), findsWidgets);
    });
  });
}
