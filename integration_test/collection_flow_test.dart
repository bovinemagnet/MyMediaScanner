// Integration tests for collection screen flows.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('collection flow', () {
    Future<void> navigateToCollection(WidgetTester tester) async {
      // Set wide surface for expanded sidebar
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('seeded items appear in collection', (tester) async {
      await navigateToCollection(tester);
      final res = await tester.pumpTestApp();
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle();

      // Navigate to Library
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // All 5 items should render as MediaItemCard widgets
      expect(find.byType(MediaItemCard), findsNWidgets(5));

      // Check some titles are visible
      expect(find.text('The Shawshank Redemption'), findsOneWidget);
      expect(find.text('Abbey Road'), findsOneWidget);
    });

    testWidgets('search filters items by title', (tester) async {
      await navigateToCollection(tester);
      final res = await tester.pumpTestApp();
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter search query
      final searchBar = find.byType(SearchBar);
      expect(searchBar, findsOneWidget);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();
      await tester.enterText(searchBar, 'Abbey');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Only Abbey Road should match
      expect(find.text('Abbey Road'), findsOneWidget);
      expect(find.text('The Shawshank Redemption'), findsNothing);
    });

    testWidgets('media type filter shows correct items', (tester) async {
      await navigateToCollection(tester);
      final res = await tester.pumpTestApp();

      // Seed specific types: 2 films and 1 book
      await seedSingleItem(res.db,
          title: 'Film One', mediaType: 'film', barcode: '1000000000001');
      await seedSingleItem(res.db,
          title: 'Film Two', mediaType: 'film', barcode: '1000000000002');
      await seedSingleItem(res.db,
          title: 'Book One', mediaType: 'book', barcode: '1000000000003');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // All 3 items visible initially
      expect(find.byType(MediaItemCard), findsNWidgets(3));

      // Tap the Film filter chip (not the label text on cards)
      final filmChip = find.ancestor(
        of: find.text('Film'),
        matching: find.byType(FilterChip),
      );
      await tester.tap(filmChip.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Only film items should show
      expect(find.text('Film One'), findsOneWidget);
      expect(find.text('Film Two'), findsOneWidget);
      expect(find.text('Book One'), findsNothing);
    });

    testWidgets('item inserted via DB appears reactively', (tester) async {
      await navigateToCollection(tester);
      final res = await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Navigate to empty collection
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show empty state
      expect(find.text('No items yet. Scan a barcode to get started!'),
          findsOneWidget);

      // Insert item via DB — stream should emit
      await seedSingleItem(res.db, title: 'Reactive Item');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Item should appear without re-navigating
      expect(find.text('Reactive Item'), findsOneWidget);
      expect(find.text('No items yet. Scan a barcode to get started!'),
          findsNothing);
    });
  });
}
