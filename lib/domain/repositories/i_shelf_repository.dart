import 'package:mymediascanner/domain/entities/shelf.dart';

abstract interface class IShelfRepository {
  Stream<List<Shelf>> watchAll();
  Future<Shelf?> getById(String id);
  Future<void> save(Shelf shelf);
  Future<void> softDelete(String id);
  Future<void> addItem(String shelfId, String mediaItemId, int position);
  Future<void> removeItem(String shelfId, String mediaItemId);
  Future<List<String>> getMediaItemIdsForShelf(String shelfId);
  Future<void> reorderItem(String shelfId, String mediaItemId, int newPosition);
}
