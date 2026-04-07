import 'package:mymediascanner/domain/entities/loan.dart';

abstract interface class ILoanRepository {
  Stream<List<Loan>> watchAll();
  Stream<Loan?> watchActiveLoanForItem(String mediaItemId);
  Stream<List<Loan>> watchActiveLoans();
  Stream<List<Loan>> watchLoansForItem(String mediaItemId);
  Stream<List<Loan>> watchLoansForBorrower(String borrowerId);
  Future<void> createLoan(Loan loan);
  Future<void> returnItem(String loanId);
}
