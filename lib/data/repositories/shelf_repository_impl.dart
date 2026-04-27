import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:uuid/uuid.dart';

class ShelfRepositoryImpl implements IShelfRepository {
  ShelfRepositoryImpl({
    required ShelvesDao shelvesDao,
    required SyncLogDao syncLogDao,
  })  : _shelvesDao = shelvesDao,
        _syncLogDao = syncLogDao;

  final ShelvesDao _shelvesDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

  @override
  Stream<List<Shelf>> watchAll() {
    return _shelvesDao.watchAll().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Future<Shelf?> getById(String id) async {
    final row = await _shelvesDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<void> save(Shelf shelf) async {
    final companion = ShelvesTableCompanion(
      id: Value(shelf.id),
      name: Value(shelf.name),
      description: Value(shelf.description),
      sortOrder: Value(shelf.sortOrder),
      updatedAt: Value(shelf.updatedAt),
    );
    final existing = await _shelvesDao.getById(shelf.id);
    if (existing != null) {
      await _shelvesDao.updateShelf(companion);
    } else {
      await _shelvesDao.insertShelf(companion);
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _shelvesDao.softDelete(id, now);
    await _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('shelf'),
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

  @override
  Future<void> addItem(String shelfId, String mediaItemId, int position) =>
      _shelvesDao.addItem(shelfId, mediaItemId, position);

  @override
  Future<void> removeItem(String shelfId, String mediaItemId) =>
      _shelvesDao.removeItem(shelfId, mediaItemId);

  @override
  Future<List<String>> getMediaItemIdsForShelf(String shelfId) =>
      _shelvesDao.getMediaItemIdsForShelf(shelfId);

  @override
  Future<void> reorderItems(String shelfId, List<String> orderedMediaItemIds) =>
      _shelvesDao.reorderItems(shelfId, orderedMediaItemIds);

  Shelf _fromRow(ShelvesTableData row) => Shelf(
        id: row.id,
        name: row.name,
        description: row.description,
        sortOrder: row.sortOrder,
        updatedAt: row.updatedAt,
      );
}
