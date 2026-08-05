// Large-text layout sweep for WishlistScreen.
//
// Android 14+ lets users scale text to 200%. The wishlist rows must still fit
// a 411dp phone. 1.0 is the control: a failure there is not a text-scale
// defect.
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
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/wishlist/wishlist_screen.dart';

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _wishlistItem({required String id, required String title}) =>
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

void _configureMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(411, 798);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(IMediaItemRepository repo, double scale) {
  final router = GoRouter(
    initialLocation: '/wishlist',
    routes: [
      GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen()),
      GoRoute(
        path: '/collection',
        builder: (_, _) => const Scaffold(body: Text('collection')),
      ),
      GoRoute(
        path: '/collection/item/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [mediaItemRepositoryProvider.overrideWithValue(repo)],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_wishlistItem(id: 'w1', title: 'x'));
  });

  for (final scale in const [1.0, 1.3, 1.6, 2.0]) {
    testWidgets(
      'lays out without overflow at textScale $scale',
      (tester) async {
        _configureMobileViewport(tester);
        final repo = _MockMediaItemRepository();
        when(() => repo.watchByStatus(OwnershipStatus.wishlist))
            .thenAnswer((_) => Stream.value([
                  _wishlistItem(
                    id: 'w1',
                    title: 'A Rather Long Book Title That Keeps Going',
                  ),
                  _wishlistItem(id: 'w2', title: 'Short'),
                ]));

        await tester.pumpWidget(_wrap(repo, scale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}
