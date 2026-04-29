// Widget tests for ShelfDetailScreen.
//
// Covers:
//   1. Renders the shelf name ("Shelf" AppBar title) and item list.
//   2. Reorder — drives ReorderableListView.onReorder and asserts the
//      new ordering is persisted via shelfRepository.reorderItems.
//   3. Remove-from-shelf — skipped: ShelfDetailScreen renders a
//      ReorderableListView with no remove action; removal is only
//      triggered from ItemDetailScreen / context menus.
//
// The FutureProvider.family providers (shelfItemIdsProvider,
// mediaItemProvider) delegate to the repository providers, so overriding
// the underlying repositories is sufficient to inject test data without
// needing the database.
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
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelf_detail_screen.dart';

class _MockShelfRepository extends Mock implements IShelfRepository {}

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kShelfId = 'shelf-42';

MediaItem _mediaItem({
  String id = 'item1',
  String title = 'Neuromancer',
}) =>
    MediaItem(
      id: id,
      barcode: 'bc',
      barcodeType: 'isbn13',
      mediaType: MediaType.book,
      title: title,
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      ownershipStatus: OwnershipStatus.owned,
    );

Widget _wrap({
  required IShelfRepository shelfRepo,
  required IMediaItemRepository mediaItemRepo,
  String shelfId = _kShelfId,
}) {
  final router = GoRouter(
    initialLocation: '/shelves/$shelfId',
    routes: [
      GoRoute(
        path: '/shelves/:id',
        builder: (_, state) => ShelfDetailScreen(
          shelfId: state.pathParameters['id']!,
        ),
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
      shelfRepositoryProvider.overrideWithValue(shelfRepo),
      mediaItemRepositoryProvider.overrideWithValue(mediaItemRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockShelfRepository shelfRepo;
  late _MockMediaItemRepository mediaItemRepo;

  setUpAll(() {
    registerFallbackValue(_mediaItem());
  });

  setUp(() {
    shelfRepo = _MockShelfRepository();
    mediaItemRepo = _MockMediaItemRepository();
  });

  // --------------------------------------------------------------------------
  // Test 1: renders the shelf name (AppBar) and item list
  // --------------------------------------------------------------------------
  testWidgets('renders the shelf name and item list', (tester) async {
    final item = _mediaItem(id: 'item1', title: 'Neuromancer');

    // shelfItemIdsProvider(shelfId) delegates to shelfRepo.getMediaItemIdsForShelf
    when(() => shelfRepo.getMediaItemIdsForShelf(_kShelfId))
        .thenAnswer((_) async => ['item1']);

    // mediaItemProvider('item1') delegates to mediaItemRepo.getById
    when(() => mediaItemRepo.getById('item1'))
        .thenAnswer((_) async => item);

    await tester.pumpWidget(
        _wrap(shelfRepo: shelfRepo, mediaItemRepo: mediaItemRepo));
    await tester.pumpAndSettle();

    // The AppBar always shows 'Shelf' as the title on this screen.
    expect(find.text('Shelf'), findsOneWidget);

    // The item title is rendered in the list.
    expect(find.text('Neuromancer'), findsOneWidget);
  });

  // --------------------------------------------------------------------------
  // Test 2: reorder persists the new ordering through the shelf repository
  // --------------------------------------------------------------------------
  testWidgets(
    'dragging an item reorders the list and calls reorderItems',
    (tester) async {
      // Three items in initial order.
      const itemIds = ['item1', 'item2', 'item3'];
      when(() => shelfRepo.getMediaItemIdsForShelf(_kShelfId))
          .thenAnswer((_) async => itemIds);
      for (final id in itemIds) {
        when(() => mediaItemRepo.getById(id)).thenAnswer(
          (_) async => _mediaItem(id: id, title: 'Title $id'),
        );
      }
      when(() => shelfRepo.reorderItems(_kShelfId, any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
          _wrap(shelfRepo: shelfRepo, mediaItemRepo: mediaItemRepo));
      await tester.pumpAndSettle();

      // Sanity-check all three tiles rendered.
      expect(find.text('Title item1'), findsOneWidget);
      expect(find.text('Title item2'), findsOneWidget);
      expect(find.text('Title item3'), findsOneWidget);

      // Invoke onReorder directly — the gesture-driven drag is fragile in
      // a headless test, but onReorder carries all of the production
      // logic (index adjustment + persistence) so calling it is sufficient
      // to cover the behaviour. Move item3 to the front.
      final list =
          tester.widget<ReorderableListView>(find.byType(ReorderableListView));
      list.onReorder(2, 0);
      await tester.pumpAndSettle();

      // The screen reorders the in-memory list and persists the new order.
      // Moving index 2 → index 0 yields ['item3', 'item1', 'item2'].
      verify(() => shelfRepo.reorderItems(
            _kShelfId,
            ['item3', 'item1', 'item2'],
          )).called(1);
    },
  );

  // --------------------------------------------------------------------------
  // Test 3: remove-from-shelf — gap, no widget-level coverage
  // --------------------------------------------------------------------------
  // ShelfDetailScreen uses a ReorderableListView and exposes no "remove"
  // button.  The shelfRepository.removeItem call is only reachable via a
  // right-click ContextMenu (desktop) or from ItemDetailScreen, neither of
  // which is part of this screen's widget tree.  Removal logic should be
  // covered by a dedicated ItemDetailScreen widget test or an integration
  // test that drives the context menu.
}
