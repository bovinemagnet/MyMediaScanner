// Widget tests for [SeriesListScreen].
//
// Covers:
//   1. Empty state when no series exist.
//   2. A card is rendered per series with owned/total counts.
//   3. Tapping a card navigates to the detail route.
//
// Author: Paul Snow
// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/series/series_list_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSeriesRepository extends Mock implements ISeriesRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Series _series({
  String id = 's1',
  String name = 'Test Series',
  MediaType mediaType = MediaType.film,
  String source = 'tmdb',
  int? totalCount = 7,
}) =>
    Series(
      id: id,
      externalId: 'tmdb:$id',
      name: name,
      mediaType: mediaType,
      source: source,
      totalCount: totalCount,
      updatedAt: 0,
    );

SeriesWithCounts _seriesWithCounts({
  Series? series,
  int ownedCount = 3,
}) =>
    SeriesWithCounts(
      series: series ?? _series(),
      ownedCount: ownedCount,
    );

/// Wraps the screen under test with a ProviderScope that overrides
/// [seriesRepositoryProvider] and routes through GoRouter.
Widget _wrap(
  ISeriesRepository repo, {
  GoRouter? router,
}) {
  final goRouter = router ??
      GoRouter(
        initialLocation: '/series',
        routes: [
          GoRoute(
            path: '/series',
            builder: (_, __) => const SeriesListScreen(),
          ),
          GoRoute(
            path: '/series/:id',
            builder: (_, state) =>
                Scaffold(body: Text('detail:${state.pathParameters['id']}')),
          ),
        ],
      );

  return ProviderScope(
    overrides: [
      seriesRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: goRouter),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSeriesRepository mockRepo;

  setUp(() {
    mockRepo = MockSeriesRepository();
  });

  group('SeriesListScreen', () {
    testWidgets(
        'renders empty state when no series exist',
        (tester) async {
      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value(<SeriesWithCounts>[]));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('No series yet'), findsOneWidget);
      // The descriptive helper text should also be visible.
      expect(find.textContaining('Series populate automatically'), findsOneWidget);
    });

    testWidgets(
        'renders a card per series with completion counts',
        (tester) async {
      final entries = [
        _seriesWithCounts(
          series: _series(id: 's1', name: 'Star Wars', totalCount: 9),
          ownedCount: 3,
        ),
        _seriesWithCounts(
          series: _series(id: 's2', name: 'Harry Potter', totalCount: 8),
          ownedCount: 5,
        ),
      ];

      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value(entries));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      // Both series names appear.
      expect(find.text('Star Wars'), findsOneWidget);
      expect(find.text('Harry Potter'), findsOneWidget);

      // Completion counts: "X of Y owned".
      expect(find.text('3 of 9 owned'), findsOneWidget);
      expect(find.text('5 of 8 owned'), findsOneWidget);
    });

    testWidgets(
        'renders owned count only when totalCount is null',
        (tester) async {
      final entry = _seriesWithCounts(
        series: _series(id: 's3', name: 'Standalone Series', totalCount: null),
        ownedCount: 2,
      );

      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));

      await tester.pumpWidget(_wrap(mockRepo));
      // Use pump(Duration) rather than pumpAndSettle because a null-value
      // LinearProgressIndicator is indeterminate and animates forever.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No total, so just "N owned" without "of X".
      expect(find.text('2 owned'), findsOneWidget);
    });

    testWidgets(
        'tapping a series card navigates to the detail screen',
        (tester) async {
      final entry = _seriesWithCounts(
        series: _series(id: 'nav1', name: 'Navigate Me'),
      );

      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Navigate Me'));
      await tester.pumpAndSettle();

      expect(find.text('detail:nav1'), findsOneWidget);
    });

    testWidgets(
        'shows a loading spinner while the stream is loading',
        (tester) async {
      // A StreamController that never emits keeps the provider in loading state.
      final controller =
          StreamController<List<SeriesWithCounts>>.broadcast();
      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_wrap(mockRepo));
      // Only pump once — do not settle so the loading indicator is still showing.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets(
        'shows an error message when the stream errors',
        (tester) async {
      when(() => mockRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.error(Exception('db failure')));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
