import 'package:mymediascanner/domain/entities/location.dart';

/// Repository for the physical-location hierarchy.
///
/// Locations form a tree rooted at one or more parentless nodes (typically
/// "rooms"). The implementation enforces a soft-delete contract (rows with
/// `deleted = 1` remain in the table for sync) and prevents reparenting
/// that would create a cycle.
abstract interface class ILocationRepository {
  /// Stream every non-deleted location in display order.
  Stream<List<Location>> watchAll();

  Future<Location?> getById(String id);

  /// Direct children of [parentId]; pass `null` to fetch root locations.
  Future<List<Location>> getChildren(String? parentId);

  /// Path from the root to [id] inclusive, root-first.
  Future<List<Location>> getAncestors(String id);

  /// Persist a new location. Caller supplies the id (UUID v7).
  Future<void> create(Location location);

  /// Update a location. If [parentId] changed, validates with
  /// [wouldCreateCycle] before writing — throws [StateError] on cycle.
  Future<void> update(Location location);

  /// Soft-delete a location. Children are NOT deleted automatically;
  /// callers may opt to reparent them first.
  Future<void> softDelete(String id);

  /// `true` if reparenting [movingId] under [newParentId] would produce a
  /// cycle.
  Future<bool> wouldCreateCycle(String movingId, String? newParentId);
}
