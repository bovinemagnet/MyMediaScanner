// Integration tests for app launch and dashboard rendering.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('app launch', () {
    testWidgets('shows dashboard with empty collection', (tester) async {
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      expect(find.text('Your Digital\nVault.'), findsOneWidget);
      expect(find.text('Catalogue anything in seconds.'), findsOneWidget);
      expect(find.text('Quick Scan'), findsOneWidget);
      expect(
        find.text('Scan your first item to get started!'),
        findsOneWidget,
      );
    });

    testWidgets('shows dashboard with seeded collection', (tester) async {
      final res = await tester.pumpTestApp();

      // Seed data before settling — the StreamProviders will pick it up
      await seedMediaItems(res.db, count: 3);

      // Allow streams to emit and widgets to rebuild
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Stats card should show item count (labels are uppercased)
      expect(find.text('3'), findsOneWidget);
      expect(find.text('TOTAL ITEMS'), findsOneWidget);

      // Recent additions should show seeded titles
      expect(find.text('The Shawshank Redemption'), findsOneWidget);
      expect(find.text('To Kill a Mockingbird'), findsOneWidget);
      expect(find.text('Abbey Road'), findsOneWidget);

      // Empty state should not appear
      expect(
        find.text('Scan your first item to get started!'),
        findsNothing,
      );
    });
  });
}
