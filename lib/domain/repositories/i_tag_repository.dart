import 'package:mymediascanner/domain/entities/tag.dart';

abstract interface class ITagRepository {
  Stream<List<Tag>> watchAll();
  Future<Tag?> getById(String id);
  Future<void> save(Tag tag);
  Future<void> softDelete(String id);
  Future<void> assignToMediaItem(String tagId, String mediaItemId);
  Future<void> removeFromMediaItem(String tagId, String mediaItemId);
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId);
}
