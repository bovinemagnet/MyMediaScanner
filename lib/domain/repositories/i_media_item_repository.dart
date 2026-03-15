import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

abstract interface class IMediaItemRepository {
  Stream<List<MediaItem>> watchAll({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  });

  Future<MediaItem?> getById(String id);
  Future<bool> barcodeExists(String barcode);
  Future<void> save(MediaItem item);
  Future<void> update(MediaItem item);
  Future<void> softDelete(String id);
  Future<List<MediaItem>> getUnsynced();
  Future<void> markSynced(String id, int syncedAt);
}
