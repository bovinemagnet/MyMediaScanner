import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/domain/usecases/lend_item_usecase.dart';

class MockLoanRepository extends Mock implements ILoanRepository {}

void main() {
  late LendItemUseCase useCase;
  late MockLoanRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const Loan(
      id: '',
      mediaItemId: '',
      borrowerId: '',
      lentAt: 0,
      updatedAt: 0,
    ));
  });

  setUp(() {
    mockRepo = MockLoanRepository();
    useCase = LendItemUseCase(repository: mockRepo);
  });

  test('creates loan with correct mediaItemId and borrowerId', () async {
    when(() => mockRepo.createLoan(any())).thenAnswer((_) async {});

    final loan = await useCase.execute(
      mediaItemId: 'item-1',
      borrowerId: 'borrower-1',
      notes: 'Be careful with it',
    );

    expect(loan.mediaItemId, 'item-1');
    expect(loan.borrowerId, 'borrower-1');
    expect(loan.notes, 'Be careful with it');
    expect(loan.id, isNotEmpty);
    expect(loan.lentAt, isPositive);
    expect(loan.returnedAt, isNull);
    verify(() => mockRepo.createLoan(any())).called(1);
  });

  test('creates loan with generated UUID v7 id', () async {
    when(() => mockRepo.createLoan(any())).thenAnswer((_) async {});

    final loan1 = await useCase.execute(
      mediaItemId: 'item-1',
      borrowerId: 'borrower-1',
    );
    final loan2 = await useCase.execute(
      mediaItemId: 'item-2',
      borrowerId: 'borrower-2',
    );

    expect(loan1.id, isNot(loan2.id));
  });
}
