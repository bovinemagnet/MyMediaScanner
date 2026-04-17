// Widget tests for ShelvesScreen.
//
// Covers:
//   1. Empty state is shown when no shelves exist.
//   2. A card per shelf is rendered with the shelf name.
//   3. Tapping the add-shelf button opens the form and saves via the repository.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelves_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockShelfRepository extends Mock implements IShelfRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Shelf _shelf({
  String id = 's1',
  String name = 'Science Fiction',
  String? description,
}) =>
    Shelf(
      id: id,
      name: name,
      description: description,
      updatedAt: 1_000_000,
    );

Widget _wrap(IShelfRepository shelfRepo) {
  final router = GoRouter(
    initialLocation: '/shelves',
    routes: [
      GoRoute(
        path: '/shelves',
        builder: (_, _) => const ShelvesScreen(),
      ),
      GoRoute(
        path: '/shelves/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/collection',
        builder: (_, _) => const Scaffold(body: Text('collection')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      shelfRepositoryProvider.overrideWithValue(shelfRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockShelfRepository shelfRepo;

  setUpAll(() {
    registerFallbackValue(_shelf());
    // MasterDetailLayout reads SharedPreferences for the split ratio.
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    shelfRepo = _MockShelfRepository();
  });

  // --------------------------------------------------------------------------
  // Test 1: empty state
  // --------------------------------------------------------------------------
  testWidgets('renders empty state when no shelves exist', (tester) async {
    when(() => shelfRepo.watchAll())
        .thenAnswer((_) => Stream.value(<Shelf>[]));

    await tester.pumpWidget(_wrap(shelfRepo));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No shelves yet'),
      findsOneWidget,
    );
  });

  // --------------------------------------------------------------------------
  // Test 2: a card per shelf with shelf name
  // --------------------------------------------------------------------------
  testWidgets('renders a card per shelf with item count', (tester) async {
    final shelf1 = _shelf(id: 's1', name: 'Science Fiction');
    final shelf2 = _shelf(id: 's2', name: 'Horror');

    when(() => shelfRepo.watchAll())
        .thenAnswer((_) => Stream.value([shelf1, shelf2]));

    await tester.pumpWidget(_wrap(shelfRepo));
    await tester.pumpAndSettle();

    expect(find.text('Science Fiction'), findsOneWidget);
    expect(find.text('Horror'), findsOneWidget);
  });

  // --------------------------------------------------------------------------
  // Test 3: add shelf dialog saves via repository
  // --------------------------------------------------------------------------
  testWidgets('add shelf button opens a form and saves through the repository',
      (tester) async {
    when(() => shelfRepo.watchAll())
        .thenAnswer((_) => Stream.value(<Shelf>[]));
    when(() => shelfRepo.save(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(shelfRepo));
    await tester.pumpAndSettle();

    // On mobile the AppBar "+" action is used; find whichever Icons.add exists.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    // Dialog is open.
    expect(find.text('Create Shelf'), findsOneWidget);

    // Enter a shelf name.
    await tester.enterText(
        find.widgetWithText(TextField, 'Shelf name'), 'Fantasy');
    await tester.pumpAndSettle();

    // Confirm creation.
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    // Repository must have received a save call with the correct name.
    final captured =
        verify(() => shelfRepo.save(captureAny())).captured.single as Shelf;
    expect(captured.name, 'Fantasy');
  });
}
