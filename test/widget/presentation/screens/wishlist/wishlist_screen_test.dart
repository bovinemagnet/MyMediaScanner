import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/wishlist/wishlist_screen.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _wishlistItem({String id = 'w1', String title = 'A Book'}) =>
    MediaItem(
      id: id,
      barcode: 'bc',
      barcodeType: 'isbn13',
      mediaType: MediaType.book,
      title: title,
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      ownershipStatus: OwnershipStatus.wishlist,
    );

Widget _wrap(IMediaItemRepository repo, {GoRouter? router}) {
  final goRouter = router ??
      GoRouter(
        initialLocation: '/wishlist',
        routes: [
          GoRoute(
            path: '/wishlist',
            builder: (_, _) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/collection/item/:id',
            builder: (_, state) =>
                Scaffold(body: Text('detail:${state.pathParameters['id']}')),
          ),
        ],
      );
  return ProviderScope(
    overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: goRouter),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_wishlistItem());
  });

  testWidgets('shows items and convert button', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value([_wishlistItem()]));

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('A Book'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('shows EmptyState when wishlist is empty', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value(<MediaItem>[]));

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Your wishlist is empty'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a tile navigates to item detail', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value([_wishlistItem(id: 'w42')]));

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    // Tap the tile body (title text) — not the trailing button.
    await tester.tap(find.text('A Book'));
    await tester.pumpAndSettle();

    expect(find.text('detail:w42'), findsOneWidget);
  });

  testWidgets('tapping Mark owned invokes convert usecase', (tester) async {
    final repo = MockMediaItemRepository();
    final item = _wishlistItem(id: 'w7');
    when(() => repo.watchByStatus(OwnershipStatus.wishlist))
        .thenAnswer((_) => Stream.value([item]));
    when(() => repo.getById('w7')).thenAnswer((_) async => item);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    final captured =
        verify(() => repo.update(captureAny())).captured.single as MediaItem;
    expect(captured.id, 'w7');
    expect(captured.ownershipStatus, OwnershipStatus.owned);
    expect(captured.acquiredAt, isNotNull);
  });
}
