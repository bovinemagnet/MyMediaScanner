import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/loans_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:uuid/uuid.dart';

class LoanRepositoryImpl implements ILoanRepository {
  LoanRepositoryImpl({
    required LoansDao loansDao,
    required SyncLogDao syncLogDao,
  })  : _loansDao = loansDao,
        _syncLogDao = syncLogDao;

  final LoansDao _loansDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

  @override
  Stream<List<Loan>> watchAll() {
    return _loansDao.watchAll().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

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
  Stream<List<Loan>> watchOverdueLoans() {
    return _loansDao.watchOverdueLoans().map(
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
    await _logSync(loan, 'insert');
  }

  @override
  Future<void> updateLoan(Loan loan) async {
    await _loansDao.updateLoan(LoansTableCompanion(
      id: Value(loan.id),
      mediaItemId: Value(loan.mediaItemId),
      borrowerId: Value(loan.borrowerId),
      lentAt: Value(loan.lentAt),
      dueAt: Value(loan.dueAt),
      notes: Value(loan.notes),
      updatedAt: Value(loan.updatedAt),
    ));
    await _logSync(loan, 'update');
  }

  @override
  Future<void> updateDueDate(String loanId, int? dueAt) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _loansDao.updateDueDate(loanId, dueAt, now);
    final updated = await _loansDao.getById(loanId);
    if (updated != null) await _logSync(_fromRow(updated), 'update');
  }

  @override
  Future<void> returnItem(String loanId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _loansDao.returnItem(loanId, now, now);
    final updated = await _loansDao.getById(loanId);
    if (updated != null) await _logSync(_fromRow(updated), 'update');
  }

  /// Enqueue a `sync_log` row carrying a full snake_case snapshot of
  /// [loan]. Push uses the payload keys to derive the upsert column
  /// list, so the snapshot must include every sync-relevant field.
  Future<void> _logSync(Loan loan, String operation) {
    return _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('loan'),
      entityId: Value(loan.id),
      operation: Value(operation),
      payloadJson: Value(jsonEncode({
        'id': loan.id,
        'media_item_id': loan.mediaItemId,
        'borrower_id': loan.borrowerId,
        'lent_at': loan.lentAt,
        'returned_at': loan.returnedAt,
        'due_at': loan.dueAt,
        'notes': loan.notes,
        'updated_at': loan.updatedAt,
        'deleted': loan.deleted ? 1 : 0,
      })),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
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
