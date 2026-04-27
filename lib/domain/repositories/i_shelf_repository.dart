import 'package:mymediascanner/domain/entities/shelf.dart';

abstract interface class IShelfRepository {
  Stream<List<Shelf>> watchAll();
  Future<Shelf?> getById(String id);
  Future<void> save(Shelf shelf);
  Future<void> softDelete(String id);
  Future<void> addItem(String shelfId, String mediaItemId, int position);
  Future<void> removeItem(String shelfId, String mediaItemId);
  Future<List<String>> getMediaItemIdsForShelf(String shelfId);
  /// Replace the full ordering of items in [shelfId] with
  /// [orderedMediaItemIds]. The implementation rewrites every shelf item's
  /// position atomically — passing a partial list will drop the omitted items
  /// from the shelf, so callers must always supply the complete sequence.
  Future<void> reorderItems(String shelfId, List<String> orderedMediaItemIds);
}
