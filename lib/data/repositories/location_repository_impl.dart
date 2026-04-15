import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/locations_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/repositories/i_location_repository.dart';

class LocationRepositoryImpl implements ILocationRepository {
  LocationRepositoryImpl({required LocationsDao dao}) : _dao = dao;

  final LocationsDao _dao;

  @override
  Stream<List<Location>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<Location?> getById(String id) async {
    final row = await _dao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<List<Location>> getChildren(String? parentId) async {
    final rows = await _dao.getChildren(parentId);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Location>> getAncestors(String id) async {
    final rows = await _dao.getAncestors(id);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> create(Location location) {
    return _dao.insertLocation(_toCompanion(location));
  }

  @override
  Future<void> update(Location location) async {
    final existing = await _dao.getById(location.id);
    if (existing != null && existing.parentId != location.parentId) {
      if (await _dao.wouldCreateCycle(location.id, location.parentId)) {
        throw StateError(
            'Cannot reparent location ${location.id} under '
            '${location.parentId}: would create a cycle.');
      }
    }
    await _dao.updateLocation(_toCompanion(location));
  }

  @override
  Future<void> softDelete(String id) {
    return _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> wouldCreateCycle(String movingId, String? newParentId) {
    return _dao.wouldCreateCycle(movingId, newParentId);
  }

  Location _fromRow(LocationsTableData row) => Location(
        id: row.id,
        parentId: row.parentId,
        name: row.name,
        sortOrder: row.sortOrder,
        updatedAt: row.updatedAt,
        deleted: row.deleted == 1,
      );

  LocationsTableCompanion _toCompanion(Location l) => LocationsTableCompanion(
        id: Value(l.id),
        parentId: Value(l.parentId),
        name: Value(l.name),
        sortOrder: Value(l.sortOrder),
        updatedAt: Value(l.updatedAt),
        deleted: Value(l.deleted ? 1 : 0),
      );
}
