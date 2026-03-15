import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:uuid/uuid.dart';

class ManageShelvesUseCase {
  const ManageShelvesUseCase({required IShelfRepository repository})
      : _repo = repository;

  final IShelfRepository _repo;
  static const _uuid = Uuid();

  Future<Shelf> createShelf({
    required String name,
    String? description,
  }) async {
    final shelf = Shelf(
      id: _uuid.v7(),
      name: name,
      description: description,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.save(shelf);
    return shelf;
  }

  Future<void> deleteShelf(String id) => _repo.softDelete(id);

  Future<void> addItem({
    required String shelfId,
    required String mediaItemId,
    required int position,
  }) =>
      _repo.addItem(shelfId, mediaItemId, position);

  Future<void> removeItem({
    required String shelfId,
    required String mediaItemId,
  }) =>
      _repo.removeItem(shelfId, mediaItemId);

  Stream<List<Shelf>> watchAll() => _repo.watchAll();

  Future<List<String>> getItemsForShelf(String shelfId) =>
      _repo.getMediaItemIdsForShelf(shelfId);
}
