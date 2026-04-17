// Widget tests for ShelfDetailScreen.
//
// Covers:
//   1. Renders the shelf name ("Shelf" AppBar title) and item list.
//   2. Remove-from-shelf — skipped: ShelfDetailScreen renders a
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
  // Test 2: remove-from-shelf — skipped due to tight coupling
  // --------------------------------------------------------------------------
  // TODO: ShelfDetailScreen uses a ReorderableListView and exposes no
  // "remove" button.  The shelfRepository.removeItem call is only
  // reachable via a right-click ContextMenu (desktop) or from
  // ItemDetailScreen, neither of which is part of this screen's widget
  // tree.  Removal logic should be covered in an ItemDetailScreen or
  // integration test instead.
}
