// Widget tests for BorrowersScreen.
//
// Covers:
//   1. Empty state is shown when no borrowers exist.
//   2. A tile per borrower is rendered with the name and active-loan count.
//   3. Tapping "Add Borrower" opens the dialog and saves via the repository.
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
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/borrowers/borrowers_screen.dart';

class _MockBorrowerRepository extends Mock implements IBorrowerRepository {}

class _MockLoanRepository extends Mock implements ILoanRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Borrower _borrower({
  String id = 'b1',
  String name = 'Alice Smith',
  String? email = 'alice@example.com',
}) =>
    Borrower(
      id: id,
      name: name,
      email: email,
      updatedAt: 1_000_000,
    );

Loan _activeLoan({String borrowerId = 'b1', String itemId = 'item1'}) => Loan(
      id: 'loan1',
      mediaItemId: itemId,
      borrowerId: borrowerId,
      lentAt: DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

Widget _wrap({
  required IBorrowerRepository borrowerRepo,
  required ILoanRepository loanRepo,
}) {
  final router = GoRouter(
    initialLocation: '/borrowers',
    routes: [
      GoRoute(
        path: '/borrowers',
        builder: (_, _) => const BorrowersScreen(),
      ),
      GoRoute(
        path: '/borrowers/:id',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      borrowerRepositoryProvider.overrideWithValue(borrowerRepo),
      loanRepositoryProvider.overrideWithValue(loanRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockBorrowerRepository borrowerRepo;
  late _MockLoanRepository loanRepo;

  setUpAll(() {
    registerFallbackValue(_borrower());
    registerFallbackValue(_activeLoan());
  });

  setUp(() {
    borrowerRepo = _MockBorrowerRepository();
    loanRepo = _MockLoanRepository();

    // Default: no loans
    when(() => loanRepo.watchActiveLoans())
        .thenAnswer((_) => Stream.value(<Loan>[]));
    when(() => loanRepo.watchOverdueLoans())
        .thenAnswer((_) => Stream.value(<Loan>[]));
  });

  // --------------------------------------------------------------------------
  // Test 1: empty state
  // --------------------------------------------------------------------------
  testWidgets('renders empty state when no borrowers exist', (tester) async {
    when(() => borrowerRepo.watchAll())
        .thenAnswer((_) => Stream.value(<Borrower>[]));

    await tester.pumpWidget(_wrap(borrowerRepo: borrowerRepo, loanRepo: loanRepo));
    await tester.pumpAndSettle();

    expect(find.text('No borrowers yet'), findsOneWidget);
  });

  // --------------------------------------------------------------------------
  // Test 2: tile per borrower with active-loan count
  // --------------------------------------------------------------------------
  testWidgets('renders a tile per borrower with name and active-loan count',
      (tester) async {
    final borrowerA = _borrower(id: 'b1', name: 'Alice Smith');
    final borrowerB = _borrower(id: 'b2', name: 'Bob Jones', email: null);
    final loan = _activeLoan(borrowerId: 'b1', itemId: 'item1');

    when(() => borrowerRepo.watchAll())
        .thenAnswer((_) => Stream.value([borrowerA, borrowerB]));
    when(() => loanRepo.watchActiveLoans())
        .thenAnswer((_) => Stream.value([loan]));

    await tester.pumpWidget(_wrap(borrowerRepo: borrowerRepo, loanRepo: loanRepo));
    await tester.pumpAndSettle();

    // Both names are shown.
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);

    // Alice has one active loan; the badge "1 active" must be visible.
    expect(find.text('1 active'), findsOneWidget);
  });

  // --------------------------------------------------------------------------
  // Test 3: add-borrower dialog saves via the repository
  // --------------------------------------------------------------------------
  testWidgets(
      'tapping add borrower opens a dialog and saves through the repository',
      (tester) async {
    when(() => borrowerRepo.watchAll())
        .thenAnswer((_) => Stream.value(<Borrower>[]));
    when(() => borrowerRepo.save(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(borrowerRepo: borrowerRepo, loanRepo: loanRepo));
    await tester.pumpAndSettle();

    // On mobile (test environment) the AppBar action button is shown.
    await tester.tap(find.byIcon(Icons.person_add).first);
    await tester.pumpAndSettle();

    // Dialog is open.
    expect(find.text('Add Borrower'), findsOneWidget);

    // Fill in the name field.
    await tester.enterText(
        find.widgetWithText(TextField, 'Name *'), 'Carol White');
    await tester.pumpAndSettle();

    // Tap the Add button in the dialog.
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify the repository received a save call with the correct name.
    final captured =
        verify(() => borrowerRepo.save(captureAny())).captured.single
            as Borrower;
    expect(captured.name, 'Carol White');
  });
}
