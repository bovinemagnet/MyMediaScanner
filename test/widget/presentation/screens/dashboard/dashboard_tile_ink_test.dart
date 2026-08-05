// The dashboard's in-progress and recommendation tiles sit inside sections
// that paint their own opaque background. A ListTile with no Material of its
// own sends its ink to the nearest ancestor Material, which is *behind* that
// background — the splash is painted, but the user never sees it.
//
// These tests press each tile and assert the ink lands in a Material that
// sits inside the section background, which is what makes it visible.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/recommendations_section.dart';

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

int _ts = 1700000000000;

MediaItem _item({required String id, required String title}) => MediaItem(
      id: id,
      barcode: '1234567890123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      dateAdded: _ts++,
      dateScanned: _ts++,
      updatedAt: _ts++,
      ownershipStatus: OwnershipStatus.owned,
    );

/// The nearest [Material] above [tile], but only if it sits inside the
/// section's decorated background. Resolves to nothing when the tile has no
/// Material of its own, because the nearest one is then outside the
/// background container.
Finder _inkHostInsideBackground(Finder tile) {
  final background = find.ancestor(
    of: tile,
    matching: find.byWidgetPredicate(
      (w) => w is Container && w.decoration != null,
    ),
  );
  return find.descendant(
    of: background.first,
    matching: find.ancestor(of: tile, matching: find.byType(Material)),
  );
}

/// Material 3's default splash (InkSparkle) draws through a fragment shader.
/// Nothing else in these tiles paints with one, so this identifies the splash
/// without depending on its colour or bounds. If Flutter changes its default
/// splash, this predicate is the thing to revisit.
bool _isSplash(Symbol method, List<dynamic> arguments) =>
    method == #drawRect &&
    arguments.length > 1 &&
    arguments[1] is Paint &&
    (arguments[1] as Paint).shader != null;

/// Presses [tile] and asserts the splash is painted into [inkHost].
Future<void> _expectPressPaintsSplash(
  WidgetTester tester, {
  required Finder tile,
  required Finder inkHost,
}) async {
  expect(
    inkHost,
    isNot(paints..something(_isSplash)),
    reason: 'no splash should be painted before the tile is pressed',
  );

  final gesture = await tester.startGesture(tester.getCenter(tile));
  addTearDown(() => gesture.cancel());
  // Inside a scrollable the tap is not recognised until the gesture arena
  // resolves, so the splash needs a few frames rather than one long one.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  expect(
    inkHost,
    paints..something(_isSplash),
    reason: 'pressing the tile should paint a splash into its own Material',
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(OwnershipStatus.owned);
  });

  testWidgets('recommendation tile paints its ink inside the section background',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          topRecommendationsProvider.overrideWithValue(
            AsyncValue.data([
              Recommendation(
                item: _item(id: 'r1', title: 'Recommended Film'),
                score: 0.8,
                reasons: const [
                  RecommendationReason(label: 'Highly rated', weight: 1),
                ],
              ),
            ]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RecommendationsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.ancestor(
      of: find.text('Recommended Film'),
      matching: find.byType(ListTile),
    );
    expect(tile, findsOneWidget);

    final inkHost = _inkHostInsideBackground(tile);
    expect(
      inkHost,
      findsOneWidget,
      reason: 'the tile needs a Material inside the section background, '
          'otherwise its ink is hidden behind that background',
    );

    await _expectPressPaintsSplash(tester, tile: tile, inkHost: inkHost);
  });

  testWidgets('in-progress tile paints its ink inside the section background',
      (tester) async {
    // Tall enough that the in-progress section is on screen without
    // scrolling — a press outside the viewport never reaches the tile.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _MockMediaItemRepository();
    final inProgress = [_item(id: 'p1', title: 'Currently Watching')];

    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value(inProgress));
    when(() => repo.watchInProgress())
        .thenAnswer((_) => Stream.value(inProgress));
    // Empty so the recommendations section stays hidden and the only tile on
    // screen is the in-progress one.
    when(() => repo.watchByStatus(any()))
        .thenAnswer((_) => Stream.value(const []));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [mediaItemRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // The dashboard runs a continuous ambient animation, so pumpAndSettle
    // never returns. Layout is stable well before this.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final tile = find.ancestor(
      of: find.text('Currently Watching'),
      matching: find.byType(ListTile),
    );
    expect(tile, findsOneWidget);

    final inkHost = _inkHostInsideBackground(tile);
    expect(
      inkHost,
      findsOneWidget,
      reason: 'the tile needs a Material inside the section background, '
          'otherwise its ink is hidden behind that background',
    );

    await _expectPressPaintsSplash(tester, tile: tile, inkHost: inkHost);
  });
}
