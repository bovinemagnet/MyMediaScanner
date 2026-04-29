// Widget tests for CollectionScreen.
//
// Covers: empty state, list rendering, media-type filtering and search
// filtering.  All external dependencies are replaced with lightweight
// hand-written fakes so the tests remain fast and isolated.
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
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

class MockLoanRepository extends Mock implements ILoanRepository {}

class MockBorrowerRepository extends Mock implements IBorrowerRepository {}

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _ts = 1_000_000;

MediaItem _item({
  String id = 'i1',
  String title = 'Test Item',
  MediaType mediaType = MediaType.film,
}) {
  return MediaItem(
    id: id,
    barcode: '1234567890123',
    barcodeType: 'ean13',
    mediaType: mediaType,
    title: title,
    dateAdded: _ts++,
    dateScanned: _ts++,
    updatedAt: _ts++,
    ownershipStatus: OwnershipStatus.owned,
  );
}

/// Sets a desktop-sized viewport (1280×800) so [CollectionScreen]'s
/// desktop layout (`ScreenHeader`, `MasterDetailLayout`, grid) has room
/// to lay out without overflowing.
void _configureDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Wraps [CollectionScreen] in a minimal GoRouter + ProviderScope so that
/// GoRouter-dependent code (context.go, etc.) does not throw.
Widget _wrap({
  required IMediaItemRepository mediaRepo,
  required ILoanRepository loanRepo,
  required IBorrowerRepository borrowerRepo,
  required IRipLibraryRepository ripRepo,
}) {
  final router = GoRouter(
    initialLocation: '/collection',
    routes: [
      GoRoute(
        path: '/collection',
        builder: (_, _) => const CollectionScreen(),
      ),
      GoRoute(
        path: '/collection/item/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/scan',
        builder: (_, _) => const Scaffold(body: Text('scan')),
      ),
      GoRoute(
        path: '/shelves',
        builder: (_, _) => const Scaffold(body: Text('shelves')),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (_, _) => const Scaffold(body: Text('wishlist')),
      ),
      GoRoute(
        path: '/collection/statistics',
        builder: (_, _) => const Scaffold(body: Text('statistics')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      mediaItemRepositoryProvider.overrideWithValue(mediaRepo),
      loanRepositoryProvider.overrideWithValue(loanRepo),
      borrowerRepositoryProvider.overrideWithValue(borrowerRepo),
      ripLibraryRepositoryProvider.overrideWithValue(ripRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void _stubEmpty(
  MockMediaItemRepository repo,
  MockLoanRepository loanRepo,
  MockRipLibraryRepository ripRepo,
) {
  when(() => repo.watchByStatus(OwnershipStatus.owned))
      .thenAnswer((_) => Stream.value(<MediaItem>[]));
  when(() => repo.watchAll(
        mediaType: any(named: 'mediaType'),
        searchQuery: any(named: 'searchQuery'),
        tagIds: any(named: 'tagIds'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
      )).thenAnswer((_) => Stream.value(<MediaItem>[]));
  when(() => loanRepo.watchActiveLoans())
      .thenAnswer((_) => Stream.value([]));
  when(() => loanRepo.watchAll()).thenAnswer((_) => Stream.value([]));
  when(() => ripRepo.watchRippedMediaItemIds())
      .thenAnswer((_) => Stream.value(<String>{}));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_item());
    registerFallbackValue(OwnershipStatus.owned);
  });

  group('CollectionScreen', () {
    late MockMediaItemRepository mediaRepo;
    late MockLoanRepository loanRepo;
    late MockBorrowerRepository borrowerRepo;
    late MockRipLibraryRepository ripRepo;

    setUp(() {
      // Mock SharedPreferences so any provider that reads it (e.g. the
      // split-ratio provider used by MasterDetailLayout) resolves
      // synchronously instead of hanging the platform channel.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      mediaRepo = MockMediaItemRepository();
      loanRepo = MockLoanRepository();
      borrowerRepo = MockBorrowerRepository();
      ripRepo = MockRipLibraryRepository();
    });

    testWidgets(
      'renders the empty state when the collection is empty',
      (tester) async {
        _configureDesktopViewport(tester);
        _stubEmpty(mediaRepo, loanRepo, ripRepo);

        await tester.pumpWidget(
          _wrap(
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('No items yet'),
          findsOneWidget,
        );
      },
      // Force the desktop branch of CollectionScreen — the mobile branch
      // puts a SortSelector (DropdownButton in a Flexible) into
      // AppBar.actions where the unbounded width trips a layout assert.
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'renders a card per item when the list is non-empty',
      (tester) async {
        _configureDesktopViewport(tester);

        final items = [
          _item(id: 'i1', title: 'Film One'),
          _item(id: 'i2', title: 'Film Two'),
          _item(id: 'i3', title: 'Film Three'),
        ];

        when(() => mediaRepo.watchByStatus(OwnershipStatus.owned))
            .thenAnswer((_) => Stream.value(items));
        when(() => loanRepo.watchActiveLoans())
            .thenAnswer((_) => Stream.value([]));
        when(() => loanRepo.watchAll())
            .thenAnswer((_) => Stream.value([]));
        when(() => ripRepo.watchRippedMediaItemIds())
            .thenAnswer((_) => Stream.value(<String>{}));

        await tester.pumpWidget(
          _wrap(
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Film One'), findsOneWidget);
        expect(find.text('Film Two'), findsOneWidget);
        expect(find.text('Film Three'), findsOneWidget);
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'filter-by-type restricts the visible items',
      (tester) async {
        _configureDesktopViewport(tester);

        // Three items: two films, one music album.
        final filmOne = _item(id: 'f1', title: 'Action Film', mediaType: MediaType.film);
        final filmTwo = _item(id: 'f2', title: 'Drama Film', mediaType: MediaType.film);
        final album = _item(id: 'm1', title: 'Rock Album', mediaType: MediaType.music);

        // The collection provider first loads all owned items …
        when(() => mediaRepo.watchByStatus(OwnershipStatus.owned))
            .thenAnswer((_) => Stream.value([filmOne, filmTwo, album]));
        // … then when a mediaType filter is active it calls watchAll (via
        // watchByStatus for the no-search branch, filtering in memory).
        // We stub watchAll defensively as well.
        when(() => mediaRepo.watchAll(
              mediaType: any(named: 'mediaType'),
              searchQuery: any(named: 'searchQuery'),
              tagIds: any(named: 'tagIds'),
              sortBy: any(named: 'sortBy'),
              ascending: any(named: 'ascending'),
            )).thenAnswer((_) => Stream.value([filmOne, filmTwo]));
        when(() => loanRepo.watchActiveLoans())
            .thenAnswer((_) => Stream.value([]));
        when(() => loanRepo.watchAll())
            .thenAnswer((_) => Stream.value([]));
        when(() => ripRepo.watchRippedMediaItemIds())
            .thenAnswer((_) => Stream.value(<String>{}));

        await tester.pumpWidget(
          _wrap(
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Confirm all three items are initially visible.
        expect(find.text('Action Film'), findsOneWidget);
        expect(find.text('Rock Album'), findsOneWidget);

        // Tap the 'Film' filter chip.
        await tester.tap(find.text('Film').first);
        await tester.pumpAndSettle();

        // Only films should remain; music item filtered out.
        expect(find.text('Action Film'), findsOneWidget);
        expect(find.text('Drama Film'), findsOneWidget);
        expect(find.text('Rock Album'), findsNothing);
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'search input filters by title',
      (tester) async {
        _configureDesktopViewport(tester);

        final items = [
          _item(id: 's1', title: 'Blade Runner'),
          _item(id: 's2', title: 'The Matrix'),
          _item(id: 's3', title: 'Blade II'),
        ];

        // Initial load uses watchByStatus.
        when(() => mediaRepo.watchByStatus(OwnershipStatus.owned))
            .thenAnswer((_) => Stream.value(items));

        // When a search query is present the collection provider calls
        // watchAll (the FTS path).  Return only the "Blade" results.
        when(() => mediaRepo.watchAll(
              mediaType: any(named: 'mediaType'),
              searchQuery: any(named: 'searchQuery'),
              tagIds: any(named: 'tagIds'),
              sortBy: any(named: 'sortBy'),
              ascending: any(named: 'ascending'),
            )).thenAnswer((invocation) {
          final query =
              invocation.namedArguments[const Symbol('searchQuery')] as String?;
          if (query != null && query.toLowerCase().contains('blade')) {
            return Stream.value([items[0], items[2]]);
          }
          return Stream.value(items);
        });

        when(() => loanRepo.watchActiveLoans())
            .thenAnswer((_) => Stream.value([]));
        when(() => loanRepo.watchAll())
            .thenAnswer((_) => Stream.value([]));
        when(() => ripRepo.watchRippedMediaItemIds())
            .thenAnswer((_) => Stream.value(<String>{}));

        await tester.pumpWidget(
          _wrap(
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
          ),
        );
        await tester.pumpAndSettle();

        // All three items initially present.
        expect(find.text('The Matrix'), findsOneWidget);
        expect(find.text('Blade Runner'), findsOneWidget);

        // Type a query into the SearchBar.
        await tester.enterText(find.byType(SearchBar), 'Blade');
        await tester.pumpAndSettle();

        // Only Blade items should be visible; The Matrix should be gone.
        expect(find.text('Blade Runner'), findsOneWidget);
        expect(find.text('Blade II'), findsOneWidget);
        expect(find.text('The Matrix'), findsNothing);
      },
      variant: TargetPlatformVariant.desktop(),
    );
  });
}
