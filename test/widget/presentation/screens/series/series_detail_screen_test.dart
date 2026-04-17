// Widget tests for [SeriesDetailScreen].
//
// Covers:
//   1. Renders the series name in the AppBar and owned items in position order.
//   2. Shows "No owned entries yet" when the items list is empty.
//   3. Series-position subtitle (#N) is displayed for each positioned item.
//
// Author: Paul Snow
// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/series/series_detail_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSeriesRepository extends Mock implements ISeriesRepository {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kSeriesId = 'series-abc';

Series _makeSeries({String id = _kSeriesId, String name = 'My Franchise'}) =>
    Series(
      id: id,
      externalId: 'tmdb:$id',
      name: name,
      mediaType: MediaType.film,
      source: 'tmdb',
      totalCount: 5,
      updatedAt: 0,
    );

SeriesWithCounts _withCounts({
  Series? series,
  int ownedCount = 2,
}) =>
    SeriesWithCounts(
      series: series ?? _makeSeries(),
      ownedCount: ownedCount,
    );

MediaItem _item({
  required String id,
  required String title,
  int? position,
  int? year,
  String? coverUrl,
}) =>
    MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      seriesId: _kSeriesId,
      seriesPosition: position,
      year: year,
      coverUrl: coverUrl,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

/// Builds the widget tree.
///
/// [seriesEntries]  – what [allSeriesProvider] emits.
/// [itemIds]        – what [seriesRepositoryProvider.getMediaItemIds] returns.
/// [items]          – [MediaItem] objects fetched by id (via [mediaItemRepositoryProvider]).
Widget _wrap(
  MockSeriesRepository seriesRepo,
  MockMediaItemRepository mediaRepo,
) {
  final goRouter = GoRouter(
    initialLocation: '/series/$_kSeriesId',
    routes: [
      GoRoute(
        path: '/series/:id',
        builder: (_, state) =>
            SeriesDetailScreen(seriesId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/collection/item/:id',
        builder: (_, state) =>
            Scaffold(body: Text('item:${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      seriesRepositoryProvider.overrideWithValue(seriesRepo),
      mediaItemRepositoryProvider.overrideWithValue(mediaRepo),
    ],
    child: MaterialApp.router(routerConfig: goRouter),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSeriesRepository mockSeriesRepo;
  late MockMediaItemRepository mockMediaRepo;

  setUp(() {
    mockSeriesRepo = MockSeriesRepository();
    mockMediaRepo = MockMediaItemRepository();
  });

  group('SeriesDetailScreen', () {
    testWidgets(
        'renders the series name and position-ordered item list',
        (tester) async {
      final series = _makeSeries(name: 'Marvel Cinematic Universe');
      final entry = _withCounts(series: series, ownedCount: 2);

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));

      final item1 = _item(id: 'i1', title: 'Iron Man', position: 1);
      final item2 = _item(id: 'i2', title: 'The Incredible Hulk', position: 2);

      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => ['i1', 'i2']);
      when(() => mockMediaRepo.getById('i1')).thenAnswer((_) async => item1);
      when(() => mockMediaRepo.getById('i2')).thenAnswer((_) async => item2);

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      await tester.pumpAndSettle();

      // Series name appears in the AppBar.
      expect(find.text('Marvel Cinematic Universe'), findsOneWidget);

      // Both item titles are rendered.
      expect(find.text('Iron Man'), findsOneWidget);
      expect(find.text('The Incredible Hulk'), findsOneWidget);

      // Position subtitles are shown as #N.
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
    });

    testWidgets(
        'shows "No owned entries yet" when the items list is empty',
        (tester) async {
      final entry = _withCounts(ownedCount: 0);

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));
      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      await tester.pumpAndSettle();

      expect(find.text('No owned entries yet.'), findsOneWidget);
    });

    testWidgets(
        'shows completeness percentage when totalCount is known',
        (tester) async {
      // Series with 3 of 5 owned → 60% complete.
      final series = _makeSeries(name: 'Fast & Furious');
      final entry = SeriesWithCounts(series: series, ownedCount: 3);

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));
      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      await tester.pumpAndSettle();

      expect(find.text('3 of 5 owned'), findsOneWidget);
      expect(find.text('60% complete'), findsOneWidget);
    });

    testWidgets(
        'shows "total unknown" label when series totalCount is null',
        (tester) async {
      final series = _makeSeries().copyWith(totalCount: null);
      final entry = SeriesWithCounts(series: series, ownedCount: 4);

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));
      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      // Use pump(Duration) rather than pumpAndSettle because a null-value
      // LinearProgressIndicator is indeterminate and animates forever.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('4 owned (total unknown)'), findsOneWidget);
    });

    testWidgets(
        'shows "Series not found" when the id is not in the series list',
        (tester) async {
      // allSeriesProvider returns an entry for a *different* id.
      final other = _withCounts(series: _makeSeries(id: 'other-id'));

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([other]));
      // seriesItemsProvider will still be called but can return empty.
      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      await tester.pumpAndSettle();

      expect(find.text('Series not found.'), findsOneWidget);
    });

    testWidgets(
        'tapping an item tile navigates to the item detail route',
        (tester) async {
      final entry = _withCounts(ownedCount: 1);

      when(() => mockSeriesRepo.watchAllWithCounts())
          .thenAnswer((_) => Stream.value([entry]));
      when(() => mockSeriesRepo.getMediaItemIds(_kSeriesId))
          .thenAnswer((_) async => ['tap1']);
      when(() => mockMediaRepo.getById('tap1')).thenAnswer(
          (_) async => _item(id: 'tap1', title: 'Tappable Film', position: 1));

      await tester.pumpWidget(_wrap(mockSeriesRepo, mockMediaRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tappable Film'));
      await tester.pumpAndSettle();

      expect(find.text('item:tap1'), findsOneWidget);
    });
  });
}
