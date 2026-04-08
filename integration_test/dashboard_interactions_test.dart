// Integration tests for dashboard interactions and reactivity.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('dashboard interactions', () {
    testWidgets('stats cards show correct count after seeding items',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();
      await seedMediaItems(res.db, count: 3);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Stats card should reflect the seeded count
      expect(find.text('TOTAL ITEMS'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('recent additions shows seeded items as media cards',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Recent additions should render MediaItemCard widgets
      expect(find.byType(MediaItemCard), findsWidgets);

      // The first seeded title should be visible
      expect(find.text('The Shawshank Redemption'), findsOneWidget);
    });

    testWidgets('View All button navigates to collection', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();
      // Seed one item so the recent additions section renders with content
      await seedSingleItem(res.db, title: 'Solo Item');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the View All button in the Recent Additions section
      final viewAllButton = find.widgetWithText(TextButton, 'View All');
      expect(viewAllButton, findsOneWidget);
      await tester.tap(viewAllButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Collection screen should now be active — SearchBar is a collection-
      // specific widget that confirms the route change
      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets('items added reactively appear in dashboard', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Empty state should be shown initially
      expect(
        find.text('Scan your first item to get started!'),
        findsOneWidget,
      );

      // Insert an item directly via the database
      await seedSingleItem(res.db, title: 'Reactive Dashboard Item');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The new item title should appear and empty state should be gone
      expect(find.text('Reactive Dashboard Item'), findsOneWidget);
      expect(
        find.text('Scan your first item to get started!'),
        findsNothing,
      );
    });
  });
}
