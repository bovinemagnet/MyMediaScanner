import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:uuid/uuid.dart';

class ManageTagsUseCase {
  const ManageTagsUseCase({required ITagRepository repository})
      : _repo = repository;

  final ITagRepository _repo;
  static const _uuid = Uuid();

  Future<Tag> createTag({required String name, String? colour}) async {
    final tag = Tag(
      id: _uuid.v7(),
      name: name,
      colour: colour,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.save(tag);
    return tag;
  }

  Future<void> deleteTag(String id) => _repo.softDelete(id);

  Future<void> assignTag({
    required String tagId,
    required String mediaItemId,
  }) =>
      _repo.assignToMediaItem(tagId, mediaItemId);

  Future<void> removeTag({
    required String tagId,
    required String mediaItemId,
  }) =>
      _repo.removeFromMediaItem(tagId, mediaItemId);

  Stream<List<Tag>> watchAll() => _repo.watchAll();

  Future<List<String>> getTagsForItem(String mediaItemId) =>
      _repo.getTagIdsForMediaItem(mediaItemId);
}
