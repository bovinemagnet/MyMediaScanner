import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';

abstract interface class IMediaItemRepository {
  Stream<List<MediaItem>> watchAll({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  });

  Stream<List<MediaItem>> watchByStatus(OwnershipStatus status);

  /// Items currently being read/watched: started but not yet completed.
  Stream<List<MediaItem>> watchInProgress();

  Future<MediaItem?> getById(String id);
  Future<bool> barcodeExists(String barcode);
  Future<int> countByBarcode(String barcode);
  Future<List<MediaItem>> findByBarcode(String barcode);
  Future<List<MediaItem>> findByTitleYear(String title, int? year);
  Future<void> save(MediaItem item);
  Future<void> update(MediaItem item);
  Future<void> softDelete(String id);

  /// Stream of items previously soft-deleted, surfaced via the Trash UI.
  Stream<List<MediaItem>> watchDeleted();

  /// Restores a soft-deleted item by clearing the `deleted` flag and
  /// bumping `updatedAt` so the change propagates through sync.
  Future<void> restore(String id);

  /// Permanently removes an item from local storage. The caller is
  /// expected to have soft-deleted it first so sync log already carries
  /// the deletion to other devices.
  Future<void> hardDelete(String id);

  Future<List<MediaItem>> getUnsynced();
  Future<void> markSynced(String id, int syncedAt);
}
