import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/loans_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';

class LoanRepositoryImpl implements ILoanRepository {
  LoanRepositoryImpl({required LoansDao loansDao}) : _loansDao = loansDao;

  final LoansDao _loansDao;

  @override
  Stream<Loan?> watchActiveLoanForItem(String mediaItemId) {
    return _loansDao.watchActiveLoanForItem(mediaItemId).map(
          (row) => row != null ? _fromRow(row) : null,
        );
  }

  @override
  Stream<List<Loan>> watchActiveLoans() {
    return _loansDao.watchActiveLoans().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  @override
  Stream<List<Loan>> watchLoansForItem(String mediaItemId) {
    return _loansDao.watchLoansForItem(mediaItemId).map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  @override
  Stream<List<Loan>> watchLoansForBorrower(String borrowerId) {
    return _loansDao.watchLoansForBorrower(borrowerId).map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  @override
  Future<void> createLoan(Loan loan) async {
    await _loansDao.insertLoan(LoansTableCompanion(
      id: Value(loan.id),
      mediaItemId: Value(loan.mediaItemId),
      borrowerId: Value(loan.borrowerId),
      lentAt: Value(loan.lentAt),
      dueAt: Value(loan.dueAt),
      notes: Value(loan.notes),
      updatedAt: Value(loan.updatedAt),
    ));
  }

  @override
  Future<void> returnItem(String loanId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _loansDao.returnItem(loanId, now, now);
  }

  Loan _fromRow(LoansTableData row) => Loan(
        id: row.id,
        mediaItemId: row.mediaItemId,
        borrowerId: row.borrowerId,
        lentAt: row.lentAt,
        returnedAt: row.returnedAt,
        dueAt: row.dueAt,
        notes: row.notes,
        updatedAt: row.updatedAt,
        deleted: row.deleted == 1,
      );
}
