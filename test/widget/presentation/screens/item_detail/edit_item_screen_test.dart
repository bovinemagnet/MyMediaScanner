// Widget tests for EditItemScreen.
//
// Covers:
//   1. The form is pre-populated with the item's current values.
//   2. Saving applies the edits via repository.update and pops back.
//   3. A missing item shows the error state instead of a form.
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
import 'package:mymediascanner/presentation/screens/item_detail/edit_item_screen.dart';

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

const _kItemId = 'item-1';

const _item = MediaItem(
  id: _kItemId,
  barcode: '5099902894225',
  barcodeType: 'ean13',
  mediaType: MediaType.music,
  title: 'Original Title',
  subtitle: 'Original Subtitle',
  publisher: 'Original Label',
  userRating: 4.0,
  ownershipStatus: OwnershipStatus.owned,
  dateAdded: 1000,
  dateScanned: 1000,
  updatedAt: 1000,
);

Widget _wrap(IMediaItemRepository repo) {
  final router = GoRouter(
    initialLocation: '/collection/item/$_kItemId/edit',
    routes: [
      GoRoute(
        path: '/collection/item/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => EditItemScreen(
              itemId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late _MockMediaItemRepository repo;

  setUp(() {
    repo = _MockMediaItemRepository();
    registerFallbackValue(_item);
    when(() => repo.getById(_kItemId)).thenAnswer((_) async => _item);
    when(() => repo.update(any())).thenAnswer((_) async {});
  });

  testWidgets('pre-populates the form with the item values', (tester) async {
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('Edit Item'), findsOneWidget);
    expect(find.text('Original Title'), findsOneWidget);
    expect(find.text('Original Subtitle'), findsOneWidget);
    expect(find.text('Original Label'), findsOneWidget);
  });

  testWidgets('saving persists the edits and pops back to detail',
      (tester) async {
    // Tall viewport so the save button at the foot of the form is
    // on-screen and tappable.
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Original Title'), 'Edited Title');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final updated = verify(() => repo.update(captureAny())).captured.single
        as MediaItem;
    expect(updated.id, _kItemId);
    expect(updated.title, 'Edited Title');
    expect(updated.userRating, 4.0,
        reason: 'user data must survive a metadata edit');
    expect(updated.updatedAt, greaterThan(1000));

    expect(find.text('detail:$_kItemId'), findsOneWidget,
        reason: 'save pops back to the detail route');
  });

  testWidgets('shows error state when the item does not exist',
      (tester) async {
    when(() => repo.getById(_kItemId)).thenAnswer((_) async => null);

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('Item not found'), findsOneWidget);
    expect(find.text('Save Changes'), findsNothing);
  });
}
