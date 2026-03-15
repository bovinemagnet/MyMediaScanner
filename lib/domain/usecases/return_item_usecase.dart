import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';

class ReturnItemUseCase {
  const ReturnItemUseCase({required ILoanRepository repository})
      : _repo = repository;

  final ILoanRepository _repo;

  Future<void> execute(String loanId) async {
    await _repo.returnItem(loanId);
  }
}
