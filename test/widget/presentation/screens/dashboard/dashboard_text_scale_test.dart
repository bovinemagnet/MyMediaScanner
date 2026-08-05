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
import 'package:mymediascanner/presentation/screens/dashboard/dashboard_screen.dart';

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void _configureMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(411, 798);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

int _ts = 1700000000000;

MediaItem _item({required String id, required String title}) => MediaItem(
      id: id,
      barcode: '1234567890123',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: title,
      dateAdded: _ts++,
      dateScanned: _ts++,
      updatedAt: _ts++,
      ownershipStatus: OwnershipStatus.owned,
    );

void _stub(_MockMediaItemRepository repo, List<MediaItem> items) {
  when(() => repo.watchAll(
        mediaType: any(named: 'mediaType'),
        searchQuery: any(named: 'searchQuery'),
        tagIds: any(named: 'tagIds'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
      )).thenAnswer((_) => Stream.value(items));
  when(() => repo.watchByStatus(any())).thenAnswer((_) => Stream.value(items));
  when(() => repo.watchInProgress()).thenAnswer((_) => Stream.value(items));
}

Widget _wrap(_MockMediaItemRepository repo, double scale) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
      GoRoute(
        path: '/scan',
        builder: (_, _) => const Scaffold(body: Text('scan')),
      ),
      GoRoute(
        path: '/collection/add-manual',
        builder: (_, _) => const Scaffold(body: Text('add-manual')),
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
    registerFallbackValue(OwnershipStatus.owned);
  });

  // Android 14+ lets users scale text to 200%. The dashboard hero text and
  // the quick-action CTAs must still fit a 411dp phone.
  // 1.0 is the control: anything failing there is not a text-scale defect.
  for (final scale in const [1.0, 1.3, 1.6, 2.0]) {
    testWidgets(
      'lays out without overflow at textScale $scale',
      (tester) async {
        _configureMobileViewport(tester);
        final repo = _MockMediaItemRepository();
        _stub(repo, [
          _item(id: 'p1', title: 'A Really Rather Long Film Title Indeed'),
          _item(id: 'p2', title: 'Short'),
        ]);

        // The dashboard runs a continuous ambient animation, so
        // pumpAndSettle never returns. Pump a bounded number of frames
        // instead — layout is stable well before this.
        await tester.pumpWidget(_wrap(repo, scale));
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}
