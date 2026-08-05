// Large-text layout sweep for ShelvesScreen.
//
// Android 14+ lets users scale text to 200%. The shelf cards must still fit
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
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/shelves/shelves_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockShelfRepository extends Mock implements IShelfRepository {}

Shelf _shelf({required String id, required String name}) => Shelf(
      id: id,
      name: name,
      updatedAt: 1_000_000,
    );

void _configureMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(411, 798);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(IShelfRepository shelfRepo, double scale) {
  final router = GoRouter(
    initialLocation: '/shelves',
    routes: [
      GoRoute(path: '/shelves', builder: (_, _) => const ShelvesScreen()),
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
    overrides: [shelfRepositoryProvider.overrideWithValue(shelfRepo)],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_shelf(id: 's1', name: 'x'));
    SharedPreferences.setMockInitialValues({});
  });

  for (final scale in const [1.0, 1.3, 1.6, 2.0]) {
    testWidgets(
      'lays out without overflow at textScale $scale',
      (tester) async {
        _configureMobileViewport(tester);
        final shelfRepo = _MockShelfRepository();
        when(() => shelfRepo.watchAll()).thenAnswer((_) => Stream.value([
              _shelf(
                id: 's1',
                name: 'Science Fiction and Fantasy Paperbacks',
              ),
              _shelf(id: 's2', name: 'Horror'),
            ]));

        await tester.pumpWidget(_wrap(shelfRepo, scale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}
