import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/borrowers_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:uuid/uuid.dart';

class BorrowerRepositoryImpl implements IBorrowerRepository {
  BorrowerRepositoryImpl({
    required BorrowersDao borrowersDao,
    required SyncLogDao syncLogDao,
  })  : _borrowersDao = borrowersDao,
        _syncLogDao = syncLogDao;

  final BorrowersDao _borrowersDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

  @override
  Stream<List<Borrower>> watchAll() {
    return _borrowersDao.watchAll().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  @override
  Future<Borrower?> getById(String id) async {
    final row = await _borrowersDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<void> save(Borrower borrower) async {
    final existing = await _borrowersDao.getById(borrower.id);
    final companion = BorrowersTableCompanion(
      id: Value(borrower.id),
      name: Value(borrower.name),
      email: Value(borrower.email),
      phone: Value(borrower.phone),
      notes: Value(borrower.notes),
      updatedAt: Value(borrower.updatedAt),
    );
    if (existing != null) {
      await _borrowersDao.updateBorrower(companion);
    } else {
      await _borrowersDao.insertBorrower(companion);
    }
  }

  @override
  Future<void> update(Borrower borrower) async {
    final companion = BorrowersTableCompanion(
      id: Value(borrower.id),
      name: Value(borrower.name),
      email: Value(borrower.email),
      phone: Value(borrower.phone),
      notes: Value(borrower.notes),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    await _borrowersDao.updateBorrower(companion);
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _borrowersDao.softDelete(id, now);
    // Mirror the media-item soft-delete pattern: enqueue a sync_log row so a
    // remote pull (or a future cross-entity pull) can replicate the deletion.
    // Without this the row stays at deleted=1 locally forever and the remote
    // copy never learns it was retired.
    await _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('borrower'),
      entityId: Value(id),
      operation: const Value('delete'),
      payloadJson: Value(jsonEncode({
        'id': id,
        'deleted': 1,
        'updated_at': now,
      })),
      createdAt: Value(now),
    ));
  }

  Borrower _fromRow(BorrowersTableData row) => Borrower(
        id: row.id,
        name: row.name,
        email: row.email,
        phone: row.phone,
        notes: row.notes,
        updatedAt: row.updatedAt,
        deleted: row.deleted == 1,
      );
}
