import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/notification_service.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/presentation/providers/notification_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/borrower_picker_dialog.dart';

class MockBorrowerRepository extends Mock implements IBorrowerRepository {}

class MockLoanRepository extends Mock implements ILoanRepository {}

class MockNotificationService extends Mock implements NotificationService {}

Borrower _borrower({String id = 'b1', String name = 'Alice'}) => Borrower(
      id: id,
      name: name,
      updatedAt: 0,
    );

Borrower _borrowerWithEmail({
  String id = 'b2',
  String name = 'Bob',
  String email = 'bob@example.com',
}) =>
    Borrower(
      id: id,
      name: name,
      email: email,
      updatedAt: 0,
    );

Widget _wrap({
  required IBorrowerRepository borrowerRepo,
  required ILoanRepository loanRepo,
  required NotificationService notificationService,
  String mediaItemId = 'item1',
}) {
  return ProviderScope(
    overrides: [
      borrowerRepositoryProvider.overrideWithValue(borrowerRepo),
      loanRepositoryProvider.overrideWithValue(loanRepo),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) =>
                  BorrowerPickerDialog(mediaItemId: mediaItemId),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late MockBorrowerRepository borrowerRepo;
  late MockLoanRepository loanRepo;
  late MockNotificationService notificationService;

  setUp(() {
    borrowerRepo = MockBorrowerRepository();
    loanRepo = MockLoanRepository();
    notificationService = MockNotificationService();

    when(() => loanRepo.createLoan(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(_borrower());
    registerFallbackValue(
      const Loan(
        id: 'l1',
        mediaItemId: 'item1',
        borrowerId: 'b1',
        lentAt: 0,
        updatedAt: 0,
      ),
    );
  });

  testWidgets(
    'lists all borrowers',
    (tester) async {
      when(() => borrowerRepo.watchAll()).thenAnswer(
        (_) => Stream.value([
          _borrower(id: 'b1', name: 'Alice'),
          _borrowerWithEmail(id: 'b2', name: 'Bob'),
        ]),
      );

      await tester.pumpWidget(_wrap(
        borrowerRepo: borrowerRepo,
        loanRepo: loanRepo,
        notificationService: notificationService,
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a borrower creates a loan and dismisses the dialog',
    (tester) async {
      when(() => borrowerRepo.watchAll()).thenAnswer(
        (_) => Stream.value([_borrower(id: 'borrow1', name: 'Charlie')]),
      );

      await tester.pumpWidget(_wrap(
        borrowerRepo: borrowerRepo,
        loanRepo: loanRepo,
        notificationService: notificationService,
        mediaItemId: 'itemX',
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Charlie'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);

      final captured =
          verify(() => loanRepo.createLoan(captureAny())).captured.single
              as Loan;
      expect(captured.borrowerId, 'borrow1');
      expect(captured.mediaItemId, 'itemX');
    },
  );

  testWidgets(
    'add-new-borrower button opens the form',
    (tester) async {
      when(() => borrowerRepo.watchAll()).thenAnswer(
        (_) => Stream.value([_borrower()]),
      );

      await tester.pumpWidget(_wrap(
        borrowerRepo: borrowerRepo,
        loanRepo: loanRepo,
        notificationService: notificationService,
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add new borrower'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Name *'), findsOneWidget);
      expect(find.text('Create & Lend'), findsOneWidget);
    },
  );
}
