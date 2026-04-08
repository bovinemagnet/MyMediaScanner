// Integration tests for sidebar navigation.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/scanner/scanner_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('sidebar navigation', () {
    testWidgets('can navigate to all sidebar destinations', (tester) async {
      // Set a wide surface so the sidebar is expanded with labels visible
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Dashboard is the initial route
      expect(find.text('Your Digital\nVault.'), findsOneWidget);

      // Navigate to Library (index 1)
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle();
      // Library screen has ScreenHeader with title 'Library'
      // (sidebar also shows 'Library' — check for the ScreenHeader instance)
      expect(find.text('Library'), findsWidgets);

      // Navigate to Scanner (index 2)
      await tester.tap(find.text('Scanner'));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsOneWidget);

      // Navigate to Shelves (index 3)
      await tester.tap(find.text('Shelves'));
      await tester.pumpAndSettle();
      expect(find.text('Shelves'), findsWidgets);

      // Navigate to Batch Editor (index 4)
      await tester.tap(find.text('Batch Editor'));
      await tester.pumpAndSettle();
      expect(find.text('Batch Editor'), findsWidgets);

      // Navigate to Insights (index 5)
      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);

      // Navigate to Settings (index 6)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);

      // Navigate to Rips (index 7)
      await tester.tap(find.text('Rips'));
      await tester.pumpAndSettle();
      expect(find.text('Rip Library'), findsOneWidget);

      // Navigate back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Your Digital\nVault.'), findsOneWidget);
    });
  });
}
