// Integration tests for rips screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/rips/rips_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('rips screen', () {
    Future<void> setUpWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders Rip Library header', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Navigate to Rips via sidebar
      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify the screen renders with the correct header
      expect(find.byType(RipsScreen), findsOneWidget);
      expect(find.text('Rip Library'), findsOneWidget);
    });

    testWidgets('shows empty state when no rips exist', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Empty state message should appear
      expect(
        find.text(
          'No rip albums found. Use "Scan Library" to discover FLAC rips.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Library and Coverage segment toggle',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Segmented button should show both options
      expect(find.text('Library'), findsWidgets); // sidebar + segment
      expect(find.text('Coverage'), findsOneWidget);
    });
  });
}
