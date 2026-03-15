import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';

class TagRepositoryImpl implements ITagRepository {
  TagRepositoryImpl({
    required TagsDao tagsDao,
    required SyncLogDao syncLogDao,
  })  : _tagsDao = tagsDao,
        _syncLogDao = syncLogDao;

  final TagsDao _tagsDao;
  // Retained for sync support in Slice 5.
  // ignore: unused_field
  final SyncLogDao _syncLogDao;

  @override
  Stream<List<Tag>> watchAll() {
    return _tagsDao.watchAll().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Future<Tag?> getById(String id) async {
    final row = await _tagsDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<void> save(Tag tag) async {
    await _tagsDao.insertTag(TagsTableCompanion(
      id: Value(tag.id),
      name: Value(tag.name),
      colour: Value(tag.colour),
      updatedAt: Value(tag.updatedAt),
    ));
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _tagsDao.softDelete(id, now);
  }

  @override
  Future<void> assignToMediaItem(String tagId, String mediaItemId) =>
      _tagsDao.assignToMediaItem(tagId, mediaItemId);

  @override
  Future<void> removeFromMediaItem(String tagId, String mediaItemId) =>
      _tagsDao.removeFromMediaItem(tagId, mediaItemId);

  @override
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) =>
      _tagsDao.getTagIdsForMediaItem(mediaItemId);

  Tag _fromRow(TagsTableData row) => Tag(
        id: row.id,
        name: row.name,
        colour: row.colour,
        updatedAt: row.updatedAt,
      );
}
