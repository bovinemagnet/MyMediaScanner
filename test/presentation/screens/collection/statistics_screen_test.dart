// Widget tests for the Insights & Analytics screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/insights_data.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/statistics_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/statistics_screen.dart';

const _sampleInsights = InsightsData(
  totalItems: 42,
  byMediaType: {MediaType.film: 20, MediaType.music: 15, MediaType.book: 7},
  byYear: {2024: 10, 2025: 20, 2026: 12},
  byGenre: {'Action': 8, 'Drama': 6, 'Rock': 5},
  averageRating: 3.8,
  ratedCount: 30,
  monthlyGrowth: {'2026-01': 5, '2026-02': 12, '2026-03': 8},
  activeLoansCount: 3,
  overdueCount: 1,
  totalLoansAllTime: 10,
  topBorrowers: {'Alice': 2, 'Bob': 1},
  mostBorrowedItems: {'Film A': 3, 'Book B': 2},
  totalRipAlbums: 8,
  matchedRipAlbums: 6,
  unmatchedRipAlbums: 2,
  totalRipSizeBytes: 5000000000,
  musicItemsWithRips: 10,
  totalMusicItems: 15,
);

final _sampleItems = <MediaItem>[
  MediaItem(
    id: 'i1',
    barcode: '123',
    barcodeType: 'ean13',
    mediaType: MediaType.film,
    title: 'Test Film',
    dateAdded: DateTime.now().millisecondsSinceEpoch,
    dateScanned: DateTime.now().millisecondsSinceEpoch,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
    userRating: 4.5,
  ),
];

class _FakeInsightsNotifier extends DebouncedInsightsNotifier {
  _FakeInsightsNotifier(this._data);
  final InsightsData _data;

  @override
  Future<InsightsData> build() async => _data;
}

Widget _buildTestScreen({InsightsData? insights}) {
  final data = insights ?? _sampleInsights;
  return ProviderScope(
    overrides: [
      insightsProvider.overrideWith(() => _FakeInsightsNotifier(data)),
      collectionProvider.overrideWith((ref) => Stream.value(_sampleItems)),
    ],
    child: const MaterialApp(
      home: StatisticsScreen(),
    ),
  );
}

void main() {
  group('StatisticsScreen', () {
    testWidgets('renders with mock InsightsData', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pumpAndSettle();

      // Hero stats visible
      expect(find.text('42'), findsOneWidget);
      expect(find.text('COLLECTION GROWTH'), findsOneWidget);
    });

    testWidgets('lending section visible when loans exist', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pumpAndSettle();

      // Scroll down to find the lending section
      await tester.scrollUntilVisible(
        find.text('LENDING'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('LENDING'), findsOneWidget);
    });

    testWidgets('rip section hidden when no rip data', (tester) async {
      const noRipInsights = InsightsData(
        totalItems: 5,
        byMediaType: {MediaType.film: 5},
        byYear: {2026: 5},
        byGenre: {'Action': 5},
        averageRating: 4.0,
        ratedCount: 5,
        monthlyGrowth: {'2026-01': 5},
        activeLoansCount: 0,
        overdueCount: 0,
        totalLoansAllTime: 0,
        topBorrowers: {},
        mostBorrowedItems: {},
        totalRipAlbums: 0,
        matchedRipAlbums: 0,
        unmatchedRipAlbums: 0,
        totalRipSizeBytes: 0,
        musicItemsWithRips: 0,
        totalMusicItems: 0,
      );

      await tester.pumpWidget(_buildTestScreen(insights: noRipInsights));
      await tester.pumpAndSettle();

      expect(find.text('RIP COVERAGE'), findsNothing);
    });

    testWidgets('export buttons present', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pumpAndSettle();

      // Scroll down to find the export section
      await tester.scrollUntilVisible(
        find.text('EXPORT'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('EXPORT'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Export JSON'), findsOneWidget);
    });

    testWidgets('time period selector visible', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.text('TIME PERIOD'), findsOneWidget);
      expect(find.text('12 months'), findsOneWidget);
    });

    testWidgets('collection value tile renders value when present',
        (tester) async {
      final insights = _sampleInsights.copyWith(totalValue: 123.45);
      await tester.pumpWidget(_buildTestScreen(insights: insights));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('collection-value-tile')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('COLLECTION VALUE'), findsOneWidget);
      // Currency formatting depends on locale; just ensure something like
      // "123.45" appears in the tile's text.
      expect(find.textContaining('123.45'), findsOneWidget);
    });

    testWidgets('collection value tile shows em dash when null',
        (tester) async {
      final insights = _sampleInsights.copyWith(totalValue: null);
      await tester.pumpWidget(_buildTestScreen(insights: insights));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('collection-value-tile')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget);
    });
  });
}
