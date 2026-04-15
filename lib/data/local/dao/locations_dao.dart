import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/locations_table.dart';

part 'locations_dao.g.dart';

@DriftAccessor(tables: [LocationsTable])
class LocationsDao extends DatabaseAccessor<AppDatabase>
    with _$LocationsDaoMixin {
  LocationsDao(super.db);

  /// Watch every non-deleted location, ordered by parent then sort order
  /// then name. Callers build the tree from this flat list.
  Stream<List<LocationsTableData>> watchAll() {
    return (select(locationsTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<LocationsTableData?> getById(String id) {
    return (select(locationsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<LocationsTableData>> getChildren(String? parentId) {
    final query = select(locationsTable)
      ..where((t) => t.deleted.equals(0))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (parentId == null) {
      query.where((t) => t.parentId.isNull());
    } else {
      query.where((t) => t.parentId.equals(parentId));
    }
    return query.get();
  }

  /// Resolve the chain from [id] up to its root, returning the path in
  /// root-first order. Returns an empty list if [id] does not exist.
  Future<List<LocationsTableData>> getAncestors(String id) async {
    final path = <LocationsTableData>[];
    var current = await getById(id);
    while (current != null) {
      path.insert(0, current);
      final parentId = current.parentId;
      if (parentId == null) break;
      current = await getById(parentId);
    }
    return path;
  }

  Future<void> insertLocation(LocationsTableCompanion location) {
    return into(locationsTable).insert(location);
  }

  /// Update a location. If [parentId] is being changed, the caller must
  /// have already verified [wouldCreateCycle] returns false.
  Future<void> updateLocation(LocationsTableCompanion location) {
    return (update(locationsTable)
          ..where((t) => t.id.equals(location.id.value)))
        .write(location);
  }

  /// Detect whether reparenting [movingId] under [newParentId] would
  /// create a cycle (i.e. [newParentId] is [movingId] itself or any of
  /// its descendants).
  Future<bool> wouldCreateCycle(
      String movingId, String? newParentId) async {
    if (newParentId == null) return false;
    if (newParentId == movingId) return true;
    var current = await getById(newParentId);
    while (current != null) {
      if (current.id == movingId) return true;
      final parentId = current.parentId;
      if (parentId == null) return false;
      current = await getById(parentId);
    }
    return false;
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(locationsTable)..where((t) => t.id.equals(id))).write(
      LocationsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}
