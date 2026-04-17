// Widget tests for BorrowerDetailScreen.
//
// Covers:
//   1. Renders borrower name and contact info.
//   2. Lists active loans for the borrower.
//   3. returnLoan — the "Return" flow triggers loanRepository.returnItem.
//
// Note: BorrowerDetailScreen does not expose a "Return" button directly;
// it renders read-only _LoanCard widgets.  Returning a loan is handled via
// ItemDetailScreen / LoanSection.  Test 3 is therefore skipped with a TODO
// explaining the tight coupling.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/borrowers/borrower_detail_screen.dart';

class _MockBorrowerRepository extends Mock implements IBorrowerRepository {}

class _MockLoanRepository extends Mock implements ILoanRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kBorrowerId = 'b99';

Borrower _borrower({
  String id = _kBorrowerId,
  String name = 'Diana Prince',
  String? email = 'diana@example.com',
  String? phone = '+44 7700 900000',
}) =>
    Borrower(
      id: id,
      name: name,
      email: email,
      phone: phone,
      updatedAt: 1_000_000,
    );

Loan _loan({
  String id = 'loan1',
  String borrowerId = _kBorrowerId,
  String itemId = 'item-abc-1234567',
  int? returnedAt,
}) =>
    Loan(
      id: id,
      mediaItemId: itemId,
      borrowerId: borrowerId,
      lentAt: DateTime(2025, 1, 10).millisecondsSinceEpoch,
      returnedAt: returnedAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

Widget _wrap({
  required IBorrowerRepository borrowerRepo,
  required ILoanRepository loanRepo,
  String borrowerId = _kBorrowerId,
}) {
  return ProviderScope(
    overrides: [
      borrowerRepositoryProvider.overrideWithValue(borrowerRepo),
      loanRepositoryProvider.overrideWithValue(loanRepo),
    ],
    child: MaterialApp(
      home: BorrowerDetailScreen(borrowerId: borrowerId),
    ),
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
    registerFallbackValue(_loan());
  });

  setUp(() {
    borrowerRepo = _MockBorrowerRepository();
    loanRepo = _MockLoanRepository();
  });

  // --------------------------------------------------------------------------
  // Test 1: renders borrower name and contact info
  // --------------------------------------------------------------------------
  testWidgets('renders borrower name and contact info', (tester) async {
    when(() => borrowerRepo.watchAll())
        .thenAnswer((_) => Stream.value([_borrower()]));
    when(() => loanRepo.watchLoansForBorrower(_kBorrowerId))
        .thenAnswer((_) => Stream.value(<Loan>[]));

    await tester.pumpWidget(
        _wrap(borrowerRepo: borrowerRepo, loanRepo: loanRepo));
    await tester.pumpAndSettle();

    // Borrower name appears in the AppBar title (mobile layout).
    expect(find.text('Diana Prince'), findsOneWidget);

    // Contact details are visible.
    expect(find.text('diana@example.com'), findsOneWidget);
    expect(find.text('+44 7700 900000'), findsOneWidget);
  });

  // --------------------------------------------------------------------------
  // Test 2: lists active loans
  // --------------------------------------------------------------------------
  testWidgets('lists active loans', (tester) async {
    final activeLoan = _loan(id: 'loanA', itemId: 'item-abc-1234567');

    when(() => borrowerRepo.watchAll())
        .thenAnswer((_) => Stream.value([_borrower()]));
    when(() => loanRepo.watchLoansForBorrower(_kBorrowerId))
        .thenAnswer((_) => Stream.value([activeLoan]));

    await tester.pumpWidget(
        _wrap(borrowerRepo: borrowerRepo, loanRepo: loanRepo));
    await tester.pumpAndSettle();

    // The "ACTIVE LOANS" section header should appear.
    expect(find.text('ACTIVE LOANS'), findsOneWidget);

    // The loan card shows a truncated item ID preview
    // (screen renders "Item: item-abc…").
    expect(find.textContaining('item-abc'), findsOneWidget);

    // The stat chip shows "1" active.
    expect(find.text('1'), findsWidgets);
  });

  // --------------------------------------------------------------------------
  // Test 3: return loan — skipped due to tight coupling
  // --------------------------------------------------------------------------
  // TODO: BorrowerDetailScreen renders read-only _LoanCard widgets with no
  // "Return" action button.  The return-loan interaction is handled inside
  // ItemDetailScreen / LoanSection and cannot be triggered from this screen
  // without navigating there.  A dedicated LoanSection widget test covers
  // that behaviour instead.
}
