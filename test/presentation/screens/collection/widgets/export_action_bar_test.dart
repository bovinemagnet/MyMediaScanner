// Widget tests for ExportActionBar.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/export_action_bar.dart';

void main() {
  group('ExportActionBar', () {
    testWidgets('renders both export buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExportActionBar(),
            ),
          ),
        ),
      );

      expect(find.text('EXPORT'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Export JSON'), findsOneWidget);
    });

    testWidgets('buttons are enabled by default', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExportActionBar(),
            ),
          ),
        ),
      );

      final csvButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Export CSV'),
      );
      expect(csvButton.onPressed, isNotNull);

      final jsonButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Export JSON'),
      );
      expect(jsonButton.onPressed, isNotNull);
    });
  });
}
