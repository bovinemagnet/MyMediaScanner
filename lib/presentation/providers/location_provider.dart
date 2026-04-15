import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/repositories/location_repository_impl.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/repositories/i_location_repository.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

final locationRepositoryProvider = Provider<ILocationRepository>((ref) {
  return LocationRepositoryImpl(dao: ref.watch(locationsDaoProvider));
});

/// Stream of every non-deleted location, sorted by sortOrder/name.
final allLocationsProvider = StreamProvider<List<Location>>((ref) {
  return ref.watch(locationRepositoryProvider).watchAll();
});

/// Resolves the breadcrumb path (root-first) for [locationId].
final locationAncestorsProvider =
    FutureProvider.family<List<Location>, String>((ref, id) {
  return ref.watch(locationRepositoryProvider).getAncestors(id);
});

/// Mutating actions on the location tree.
final locationActionsProvider = Provider<LocationActions>((ref) {
  return LocationActions(repo: ref.watch(locationRepositoryProvider));
});

class LocationActions {
  LocationActions({required ILocationRepository repo}) : _repo = repo;

  final ILocationRepository _repo;
  static const _uuid = Uuid();

  Future<String> create({
    required String name,
    String? parentId,
    int sortOrder = 0,
  }) async {
    final id = _uuid.v7();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _repo.create(Location(
      id: id,
      parentId: parentId,
      name: name,
      sortOrder: sortOrder,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> rename(Location location, String newName) {
    return _repo.update(location.copyWith(
      name: newName,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> reparent(Location location, String? newParentId) {
    return _repo.update(location.copyWith(
      parentId: newParentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> delete(String id) => _repo.softDelete(id);
}
