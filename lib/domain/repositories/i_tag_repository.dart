import 'package:mymediascanner/domain/entities/tag.dart';

abstract interface class ITagRepository {
  Stream<List<Tag>> watchAll();
  Future<Tag?> getById(String id);
  Future<void> save(Tag tag);
  Future<void> softDelete(String id);
  Future<void> assignToMediaItem(String tagId, String mediaItemId);
  Future<void> removeFromMediaItem(String tagId, String mediaItemId);
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId);

  /// Names of the live tags assigned to each media item, keyed by media
  /// item id. Items with no live assignments are absent.
  Future<Map<String, List<String>>> getTagNamesByMediaItemId();
}
