// Widget tests for LendingStatsCard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/lending_stats_card.dart';

void main() {
  group('LendingStatsCard', () {
    testWidgets('renders active loans count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LendingStatsCard(
                activeLoansCount: 3,
                overdueCount: 0,
                totalLoansAllTime: 10,
                topBorrowers: const {'Alice': 2, 'Bob': 1},
                mostBorrowedItems: const {'Film A': 3, 'Book B': 2},
              ),
            ),
          ),
        ),
      );

      expect(find.text('LENDING'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // all time
    });

    testWidgets('shows overdue badge when overdue > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LendingStatsCard(
                activeLoansCount: 5,
                overdueCount: 2,
                totalLoansAllTime: 15,
                topBorrowers: const {},
                mostBorrowedItems: const {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget); // overdue count
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('shows empty state when no loans exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LendingStatsCard(
              activeLoansCount: 0,
              overdueCount: 0,
              totalLoansAllTime: 0,
              topBorrowers: const {},
              mostBorrowedItems: const {},
            ),
          ),
        ),
      );

      expect(find.text('No lending activity yet'), findsOneWidget);
    });
  });
}
