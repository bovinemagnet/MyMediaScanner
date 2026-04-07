// Widget tests for TimePeriodSelector.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/time_period_selector.dart';

void main() {
  group('TimePeriodSelector', () {
    testWidgets('renders all period options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const TimePeriodSelector(),
            ),
          ),
        ),
      );

      expect(find.text('TIME PERIOD'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('6 months'), findsOneWidget);
      expect(find.text('12 months'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
    });
  });
}
