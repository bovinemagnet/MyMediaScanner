// Widget tests for MediaTypePieChart.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_type_pie_chart.dart';

void main() {
  group('MediaTypePieChart', () {
    testWidgets('renders without error with sample data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaTypePieChart(
              byMediaType: {
                MediaType.film: 10,
                MediaType.music: 5,
                MediaType.book: 3,
              },
              totalItems: 18,
            ),
          ),
        ),
      );

      expect(find.text('MEDIA TYPES'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('No data yet'), findsNothing);
    });

    testWidgets('shows placeholder when data is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaTypePieChart(
              byMediaType: {},
              totalItems: 0,
            ),
          ),
        ),
      );

      expect(find.text('No data yet'), findsOneWidget);
    });
  });
}
