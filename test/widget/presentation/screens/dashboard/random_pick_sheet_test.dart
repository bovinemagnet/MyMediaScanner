import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/random_pick_usecase.dart';
import 'package:mymediascanner/presentation/providers/random_pick_provider.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/random_pick_sheet.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/random_pick_tile.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _item(String id, String title) => MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
      ownershipStatus: OwnershipStatus.owned,
    );

Widget _wrap({
  required IMediaItemRepository repo,
  required int seed,
  required Widget child,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
      GoRoute(
        path: '/collection/item/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      randomPickUsecaseProvider.overrideWithValue(
        RandomPickUsecase(repo, rng: Random(seed)),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('tapping the tile opens the sheet', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value([_item('a', 'Alpha')]));

    await tester.pumpWidget(_wrap(
      repo: repo,
      seed: 0,
      child: const RandomPickTile(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RandomPickTile));
    await tester.pumpAndSettle();

    expect(find.byType(RandomPickSheet), findsOneWidget);
    // Title appears on both the tile and the sheet header.
    expect(find.text('Pick something for me'), findsNWidgets(2));
  });

  testWidgets('tapping Roll shows a result card with the item title',
      (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned))
        .thenAnswer((_) => Stream.value([_item('a', 'Alpha')]));

    await tester.pumpWidget(_wrap(
      repo: repo,
      seed: 0,
      child: const RandomPickSheet(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('random-pick-roll-button')));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.byKey(const ValueKey('random-pick-reroll-button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('random-pick-open-button')),
        findsOneWidget);
  });

  testWidgets('Re-roll picks again', (tester) async {
    final repo = MockMediaItemRepository();
    when(() => repo.watchByStatus(OwnershipStatus.owned)).thenAnswer(
      (_) => Stream.value([_item('a', 'Alpha'), _item('b', 'Bravo')]),
    );

    await tester.pumpWidget(_wrap(
      repo: repo,
      seed: 0,
      child: const RandomPickSheet(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('random-pick-roll-button')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(RegExp(r'Alpha|Bravo')),
      findsWidgets,
    );

    await tester.tap(find.byKey(const ValueKey('random-pick-reroll-button')));
    await tester.pumpAndSettle();

    // The re-roll call finished and we still have a result card.
    expect(find.byKey(const ValueKey('random-pick-reroll-button')),
        findsOneWidget);

    verify(() => repo.watchByStatus(OwnershipStatus.owned))
        .called(greaterThanOrEqualTo(2));
  });
}
