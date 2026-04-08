// Widget tests for GrowthChart.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/growth_chart.dart';

void main() {
  group('GrowthChart', () {
    testWidgets('renders without error with sample data', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GrowthChart(
                monthlyGrowth: {
                  '2026-01': 5,
                  '2026-02': 12,
                  '2026-03': 8,
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('COLLECTION GROWTH'), findsOneWidget);
      expect(find.text('No growth data available yet'), findsNothing);
    });

    testWidgets('shows placeholder message when data is empty',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GrowthChart(monthlyGrowth: {}),
            ),
          ),
        ),
      );

      expect(find.text('No growth data available yet'), findsOneWidget);
    });
  });
}
