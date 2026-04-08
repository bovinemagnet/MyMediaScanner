// Widget tests for RipCoverageCard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/rip_coverage_card.dart';

void main() {
  group('RipCoverageCard', () {
    testWidgets('renders total rip albums', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RipCoverageCard(
                totalRipAlbums: 25,
                matchedRipAlbums: 20,
                unmatchedRipAlbums: 5,
                totalRipSizeBytes: 50000000000, // ~50 GB
                musicItemsWithRips: 18,
                totalMusicItems: 30,
              ),
            ),
          ),
        ),
      );

      expect(find.text('RIP COVERAGE'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('rip albums'), findsOneWidget);
    });

    testWidgets('displays coverage percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RipCoverageCard(
                totalRipAlbums: 10,
                matchedRipAlbums: 8,
                unmatchedRipAlbums: 2,
                totalRipSizeBytes: 10000000000,
                musicItemsWithRips: 6,
                totalMusicItems: 12,
              ),
            ),
          ),
        ),
      );

      // 6/12 = 50%
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('6 of 12 music items ripped'), findsOneWidget);
    });

    testWidgets('shows empty state when no rips exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RipCoverageCard(
              totalRipAlbums: 0,
              matchedRipAlbums: 0,
              unmatchedRipAlbums: 0,
              totalRipSizeBytes: 0,
              musicItemsWithRips: 0,
              totalMusicItems: 0,
            ),
          ),
        ),
      );

      expect(find.text('No rip library data available'), findsOneWidget);
    });
  });
}
