import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:uuid/uuid.dart';

class LendItemUseCase {
  const LendItemUseCase({required ILoanRepository repository})
      : _repo = repository;

  final ILoanRepository _repo;
  static const _uuid = Uuid();

  Future<Loan> execute({
    required String mediaItemId,
    required String borrowerId,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final loan = Loan(
      id: _uuid.v7(),
      mediaItemId: mediaItemId,
      borrowerId: borrowerId,
      lentAt: now,
      notes: notes,
      updatedAt: now,
    );
    await _repo.createLoan(loan);
    return loan;
  }
}
