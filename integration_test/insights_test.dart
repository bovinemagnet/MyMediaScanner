// Integration tests for insights/analytics screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/statistics_screen.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('insights screen', () {
    Future<void> setUpWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders Analytics header with empty collection',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Navigate to Insights via sidebar
      await tester.tap(find.text('Insights').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify the Analytics header renders on desktop
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('shows zero items catalogued with empty collection',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insights').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Hero stat should show 0 items
      expect(find.text('0'), findsWidgets);
      expect(find.text('ITEMS CATALOGUED'), findsOneWidget);
    });

    testWidgets('shows correct item count after seeding data',
        (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      // Seed 5 items
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insights').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show 5 items catalogued
      expect(find.text('5'), findsWidgets);
      expect(find.text('ITEMS CATALOGUED'), findsOneWidget);
    });

    testWidgets('genre distribution section renders', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insights').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Genre distribution heading should be present
      expect(find.text('Genre Distribution'), findsOneWidget);
    });
  });
}
