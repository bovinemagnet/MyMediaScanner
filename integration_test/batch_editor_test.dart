// Integration tests for batch editor screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';

void main() {
  group('batch editor screen', () {
    Future<void> setUpWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('shows empty state when no batch items exist',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Navigate to Batch Editor via sidebar
      await tester.tap(find.text('Batch Editor').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show the empty batch view
      expect(find.text('No Batch Items'), findsOneWidget);
      expect(
        find.text(
          'Enable batch mode in the scanner to queue\n'
          'multiple items for review here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty state has Start Scanning button', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batch Editor').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The gradient "Start Scanning" button should be visible
      expect(find.text('Start Scanning'), findsOneWidget);
    });
  });
}
