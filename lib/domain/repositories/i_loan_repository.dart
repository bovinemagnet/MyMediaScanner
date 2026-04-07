import 'package:mymediascanner/domain/entities/loan.dart';

abstract interface class ILoanRepository {
  Stream<Loan?> watchActiveLoanForItem(String mediaItemId);
  Stream<List<Loan>> watchActiveLoans();
  Stream<List<Loan>> watchOverdueLoans();
  Stream<List<Loan>> watchLoansForItem(String mediaItemId);
  Stream<List<Loan>> watchLoansForBorrower(String borrowerId);
  Future<void> createLoan(Loan loan);
  Future<void> updateLoan(Loan loan);
  Future<void> updateDueDate(String loanId, int? dueAt);
  Future<void> returnItem(String loanId);
}
