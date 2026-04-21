import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/dashboard/dashboard_screen.dart';

class _MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(OwnershipStatus.owned);
  });

  testWidgets('Dashboard exposes both Quick Scan and Quick Add CTAs',
      (tester) async {
    final repo = _MockMediaItemRepository();
    when(() => repo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value(const <MediaItem>[]));
    when(() => repo.watchByStatus(any()))
        .thenAnswer((_) => Stream.value(const <MediaItem>[]));
    when(() => repo.watchInProgress())
        .thenAnswer((_) => Stream.value(const <MediaItem>[]));

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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaItemRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('Quick Scan'), findsOneWidget);
    expect(find.text('Quick Add'), findsOneWidget);
  });
}
