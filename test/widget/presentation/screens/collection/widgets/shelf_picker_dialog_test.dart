import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/shelf_picker_dialog.dart';

class MockShelfRepository extends Mock implements IShelfRepository {}

Shelf _shelf({String id = 's1', String name = 'Fiction'}) => Shelf(
      id: id,
      name: name,
      updatedAt: 0,
    );

Widget _wrap(IShelfRepository repo, {String mediaItemId = 'item1'}) {
  return ProviderScope(
    overrides: [
      shelfRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) => ShelfPickerDialog(mediaItemId: mediaItemId),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_shelf());
  });

  testWidgets('lists all available shelves', (tester) async {
    final repo = MockShelfRepository();
    when(() => repo.watchAll()).thenAnswer(
      (_) => Stream.value([
        _shelf(id: 's1', name: 'Fiction'),
        _shelf(id: 's2', name: 'Science'),
      ]),
    );
    // addItem is not called in this test, but stub so the mock is lenient
    when(() => repo.addItem(any(), any(), any())).thenAnswer((_) async {});
    when(() => repo.getMediaItemIdsForShelf(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(_wrap(repo));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Fiction'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
  });

  testWidgets('tapping a shelf invokes addItem and dismisses the dialog',
      (tester) async {
    final repo = MockShelfRepository();
    when(() => repo.watchAll()).thenAnswer(
      (_) => Stream.value([_shelf(id: 'shelf99', name: 'Classics')]),
    );
    when(() => repo.addItem(any(), any(), any())).thenAnswer((_) async {});
    when(() => repo.getMediaItemIdsForShelf(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(_wrap(repo, mediaItemId: 'myitem'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Classics'));
    await tester.pumpAndSettle();

    // The dialog should be gone after tapping.
    expect(find.byType(AlertDialog), findsNothing);

    // Verify the repository was told to add the item to the correct shelf.
    verify(() => repo.addItem('shelf99', 'myitem', 0)).called(1);
  });

  testWidgets('displays empty state message when there are no shelves',
      (tester) async {
    final repo = MockShelfRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(_wrap(repo));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('No shelves yet. Create one first.'), findsOneWidget);
  });
}
