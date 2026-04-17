import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/repositories/i_location_repository.dart';
import 'package:mymediascanner/presentation/providers/location_provider.dart';
import 'package:mymediascanner/presentation/screens/locations/location_browser_screen.dart';

class MockLocationRepository extends Mock implements ILocationRepository {}

Location _location({
  String id = 'loc1',
  String name = 'Living Room',
  String? parentId,
}) =>
    Location(
      id: id,
      name: name,
      parentId: parentId,
      updatedAt: 0,
    );

Widget _wrap(ILocationRepository repo) {
  return ProviderScope(
    overrides: [
      locationRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      home: LocationBrowserScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_location());
  });

  testWidgets('renders the hierarchical location tree', (tester) async {
    final repo = MockLocationRepository();
    // Two root locations and one child under the first.
    when(() => repo.watchAll()).thenAnswer(
      (_) => Stream.value([
        _location(id: 'r1', name: 'Living Room'),
        _location(id: 'r2', name: 'Study'),
        _location(id: 'c1', name: 'Shelf A', parentId: 'r1'),
      ]),
    );

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('Living Room'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);

    // The child should not be visible until the parent is expanded.
    expect(find.text('Shelf A'), findsNothing);

    // Expand the Living Room node.
    await tester.tap(find.text('Living Room'));
    await tester.pumpAndSettle();

    expect(find.text('Shelf A'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no locations', (tester) async {
    final repo = MockLocationRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('No locations yet'), findsOneWidget);
  });
}
