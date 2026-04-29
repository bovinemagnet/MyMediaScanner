// Widget tests for ItemDetailScreen.
//
// Complements the purchase-info and purchase-info-persistence tests that
// already live in this directory.  These tests cover:
//   1. Basic smoke test — title, subtitle and cover area render.
//   2. Star-rating edit writes through the repository.
//   3. Delete button shows a confirmation dialog; confirming calls softDelete.
//   4. Source-API badge renders when sourceApis is populated (provenance feature).
//
// Lending flow (test 4 from the spec) is skipped — the BorrowerPickerDialog
// pulls BorrowerRepositoryImpl through several provider layers that require a
// live Drift DAO; isolating them without refactoring production code is
// disproportionate for a widget test.  The flow is covered by the integration
// tests in integration_test/.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/item_detail_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

class MockLoanRepository extends Mock implements ILoanRepository {}

class MockBorrowerRepository extends Mock implements IBorrowerRepository {}

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockTagRepository extends Mock implements ITagRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kItemId = 'detail-item-1';

const _baseItem = MediaItem(
  id: _kItemId,
  barcode: '5055201813916',
  barcodeType: 'ean13',
  mediaType: MediaType.film,
  title: 'Blade Runner 2049',
  subtitle: 'Director\'s Cut',
  dateAdded: 0,
  dateScanned: 0,
  updatedAt: 0,
);

/// Creates a router that hosts [ItemDetailScreen] at `/collection/item/:id`
/// with a collection route so that delete can navigate back.
GoRouter _router(String itemId) => GoRouter(
      initialLocation: '/collection/item/$itemId',
      routes: [
        GoRoute(
          path: '/collection',
          builder: (_, _) => const Scaffold(body: Text('collection')),
          routes: [
            GoRoute(
              path: 'item/:id',
              builder: (_, state) =>
                  ItemDetailScreen(itemId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const Scaffold(body: Text('edit')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

Widget _wrap({
  required MediaItem item,
  required IMediaItemRepository mediaRepo,
  required ILoanRepository loanRepo,
  required IBorrowerRepository borrowerRepo,
  required IRipLibraryRepository ripRepo,
  required ITagRepository tagRepo,
}) {
  return ProviderScope(
    overrides: [
      mediaItemRepositoryProvider.overrideWithValue(mediaRepo),
      loanRepositoryProvider.overrideWithValue(loanRepo),
      borrowerRepositoryProvider.overrideWithValue(borrowerRepo),
      ripLibraryRepositoryProvider.overrideWithValue(ripRepo),
      tagRepositoryProvider.overrideWithValue(tagRepo),
      // Seed the item directly so tests do not depend on repository.getById
      // being called at build time.
      mediaItemProvider(item.id).overrideWith((_) async => item),
    ],
    child: MaterialApp.router(routerConfig: _router(item.id)),
  );
}

void _stubLendingProviders(
  MockLoanRepository loanRepo,
  MockBorrowerRepository borrowerRepo,
) {
  when(() => loanRepo.watchActiveLoanForItem(any()))
      .thenAnswer((_) => Stream.value(null));
  when(() => loanRepo.watchLoansForItem(any()))
      .thenAnswer((_) => Stream.value(<Loan>[]));
  when(() => borrowerRepo.watchAll())
      .thenAnswer((_) => Stream.value(<Borrower>[]));
}

void _stubNoRip(MockRipLibraryRepository ripRepo) {
  when(() => ripRepo.watchByMediaItemId(any()))
      .thenAnswer((_) => Stream.value(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_baseItem);
    registerFallbackValue(
      const Loan(
        id: 'l1',
        mediaItemId: _kItemId,
        borrowerId: 'b1',
        lentAt: 0,
        updatedAt: 0,
      ),
    );
    registerFallbackValue(
      const Borrower(id: 'b1', name: 'Alice', updatedAt: 0),
    );
  });

  group('ItemDetailScreen', () {
    late MockMediaItemRepository mediaRepo;
    late MockLoanRepository loanRepo;
    late MockBorrowerRepository borrowerRepo;
    late MockRipLibraryRepository ripRepo;
    late MockTagRepository tagRepo;

    setUp(() {
      mediaRepo = MockMediaItemRepository();
      loanRepo = MockLoanRepository();
      borrowerRepo = MockBorrowerRepository();
      ripRepo = MockRipLibraryRepository();
      tagRepo = MockTagRepository();
      // TagChips watches allTagsProvider and tagIdsForItemProvider; stub
      // both to return empty so the widget renders without hitting the DB.
      when(() => tagRepo.watchAll()).thenAnswer((_) => Stream.value([]));
      when(() => tagRepo.getTagIdsForMediaItem(any()))
          .thenAnswer((_) async => <String>[]);
    });

    // -----------------------------------------------------------------------
    // 1. Smoke test
    // -----------------------------------------------------------------------
    testWidgets(
      'renders title, subtitle and cover area',
      (tester) async {
        _stubLendingProviders(loanRepo, borrowerRepo);
        _stubNoRip(ripRepo);

        await tester.pumpWidget(
          _wrap(
            item: _baseItem,
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
            tagRepo: tagRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Title appears both in the AppBar and in the body.
        expect(find.text('Blade Runner 2049'), findsWidgets);
        // Subtitle appears once in the body.
        expect(find.text("Director's Cut"), findsOneWidget);
        // Cover area — no URL supplied so the placeholder icon renders.
        expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      },
    );

    // -----------------------------------------------------------------------
    // 2. Star-rating edit writes through the repository
    // -----------------------------------------------------------------------
    testWidgets(
      'star rating edit saves through the repository',
      (tester) async {
        _stubLendingProviders(loanRepo, borrowerRepo);
        _stubNoRip(ripRepo);

        // UpdateRatingUseCase calls getById then update.
        when(() => mediaRepo.getById(_kItemId))
            .thenAnswer((_) async => _baseItem);
        when(() => mediaRepo.update(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          _wrap(
            item: _baseItem,
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
            tagRepo: tagRepo,
          ),
        );
        await tester.pumpAndSettle();

        // The star rating widget renders five GestureDetector-wrapped Icons.
        // We locate the star border icons (unrated stars) and tap the third
        // one (index 2) to set a rating of 3.0.
        //
        // The ItemDetailScreen body is a SingleChildScrollView so the widget
        // may be outside the visible area; ensureVisible scrolls it into view.
        //
        // stars_border icons: initial rating is 0 so all five are star_border.
        final allStarBorders = find.byIcon(Icons.star_border);
        await tester.ensureVisible(allStarBorders.at(2));
        await tester.tap(allStarBorders.at(2));
        await tester.pumpAndSettle();

        final captured =
            verify(() => mediaRepo.update(captureAny())).captured.single
                as MediaItem;
        expect(captured.id, _kItemId);
        expect(captured.userRating, 3.0);
      },
    );

    // -----------------------------------------------------------------------
    // 3. Delete button → confirmation dialog → softDelete
    // -----------------------------------------------------------------------
    testWidgets(
      'delete button shows a confirmation dialog and calls softDelete when confirmed',
      (tester) async {
        _stubLendingProviders(loanRepo, borrowerRepo);
        _stubNoRip(ripRepo);
        when(() => mediaRepo.softDelete(_kItemId)).thenAnswer((_) async {});

        await tester.pumpWidget(
          _wrap(
            item: _baseItem,
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
            tagRepo: tagRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Tap the delete icon in the AppBar.
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Dialog should now be visible.
        expect(find.text('Delete item?'), findsOneWidget);

        // Confirm deletion.
        await tester.tap(find.text('Delete').last);
        await tester.pumpAndSettle();

        verify(() => mediaRepo.softDelete(_kItemId)).called(1);
      },
    );

    // -----------------------------------------------------------------------
    // 4. Lend button / loan creation — exercised elsewhere
    //
    // Covered by test/widget/presentation/screens/item_detail/widgets/
    // borrower_picker_dialog_test.dart, which mocks the loan/borrower repos
    // and verifies: listing borrowers, tap-to-create-loan dismissing the
    // dialog and calling loanRepo.createLoan, and the "Add new borrower"
    // button opening the form.  Driving the flow from this screen's Lend
    // button would require live Drift DAOs, so the picker is tested in
    // isolation.
    // -----------------------------------------------------------------------

    // -----------------------------------------------------------------------
    // 5. Source-API badge renders when sourceApis is populated
    // -----------------------------------------------------------------------
    testWidgets(
      'renders source badge when sourceApis is present',
      (tester) async {
        _stubLendingProviders(loanRepo, borrowerRepo);
        _stubNoRip(ripRepo);

        const musicItem = MediaItem(
          id: _kItemId,
          barcode: '0602527522609',
          barcodeType: 'ean13',
          mediaType: MediaType.music,
          title: 'OK Computer',
          dateAdded: 0,
          dateScanned: 0,
          updatedAt: 0,
          sourceApis: ['MusicBrainz'],
        );

        await tester.pumpWidget(
          _wrap(
            item: musicItem,
            mediaRepo: mediaRepo,
            loanRepo: loanRepo,
            borrowerRepo: borrowerRepo,
            ripRepo: ripRepo,
            tagRepo: tagRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('MusicBrainz'), findsOneWidget);
      },
    );
  });
}
