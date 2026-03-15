import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/domain/usecases/return_item_usecase.dart';

class MockLoanRepository extends Mock implements ILoanRepository {}

void main() {
  late ReturnItemUseCase useCase;
  late MockLoanRepository mockRepo;

  setUp(() {
    mockRepo = MockLoanRepository();
    useCase = ReturnItemUseCase(repository: mockRepo);
  });

  test('calls returnItem on repository with correct loanId', () async {
    when(() => mockRepo.returnItem('loan-42')).thenAnswer((_) async {});

    await useCase.execute('loan-42');

    verify(() => mockRepo.returnItem('loan-42')).called(1);
  });
}
