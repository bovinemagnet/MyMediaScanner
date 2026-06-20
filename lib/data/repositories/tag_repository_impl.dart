import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:uuid/uuid.dart';

class TagRepositoryImpl implements ITagRepository {
  TagRepositoryImpl({
    required TagsDao tagsDao,
    required SyncLogDao syncLogDao,
  })  : _tagsDao = tagsDao,
        _syncLogDao = syncLogDao;

  final TagsDao _tagsDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

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
    // Atomic write + sync_log: see MediaItemRepositoryImpl.save.
    await _tagsDao.transaction(() async {
      final existing = await _tagsDao.getById(tag.id);
      await _tagsDao.insertTag(TagsTableCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        colour: Value(tag.colour),
        updatedAt: Value(tag.updatedAt),
      ));
      await _logSync(tag, existing == null ? 'insert' : 'update');
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _tagsDao.transaction(() async {
      await _tagsDao.softDelete(id, now);
      // Full row snapshot, not just {id, deleted}: push derives the
      // upsert column list from the payload keys, so a partial delete
      // payload reaching Postgres before (or without) the insert would
      // create a remote row with every other column NULL.
      final row = await _tagsDao.getById(id);
      if (row == null) return;
      await _syncLogDao.insertLog(SyncLogTableCompanion(
        id: Value(_uuid.v7()),
        entityType: const Value('tag'),
        entityId: Value(id),
        operation: const Value('delete'),
        payloadJson: Value(jsonEncode({
          'id': row.id,
          'name': row.name,
          'colour': row.colour,
          'updated_at': now,
          'deleted': 1,
        })),
        createdAt: Value(now),
      ));
    });
  }

  @override
  Future<void> assignToMediaItem(String tagId, String mediaItemId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Atomic write + sync_log: see MediaItemRepositoryImpl.save.
    await _tagsDao.transaction(() async {
      await _tagsDao.assignToMediaItem(tagId, mediaItemId, updatedAt: now);
      await _logAssignmentSync(
        tagId: tagId,
        mediaItemId: mediaItemId,
        operation: 'insert',
        updatedAt: now,
        deleted: 0,
      );
    });
  }

  @override
  Future<void> removeFromMediaItem(String tagId, String mediaItemId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _tagsDao.transaction(() async {
      await _tagsDao.removeFromMediaItem(tagId, mediaItemId, updatedAt: now);
      await _logAssignmentSync(
        tagId: tagId,
        mediaItemId: mediaItemId,
        operation: 'delete',
        updatedAt: now,
        deleted: 1,
      );
    });
  }

  @override
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) =>
      _tagsDao.getTagIdsForMediaItem(mediaItemId);

  /// Enqueue a `sync_log` row carrying a full snake_case snapshot of
  /// [tag]. Push uses the payload keys to derive the upsert column list.
  Future<void> _logSync(Tag tag, String operation) {
    return _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('tag'),
      entityId: Value(tag.id),
      operation: Value(operation),
      payloadJson: Value(jsonEncode({
        'id': tag.id,
        'name': tag.name,
        'colour': tag.colour,
        'updated_at': tag.updatedAt,
        'deleted': 0,
      })),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Enqueue a `sync_log` row for a tag assignment. The composite
  /// entity id ('mediaItemId|tagId') mirrors the remote composite PK;
  /// push never parses it — the payload carries the real key columns.
  Future<void> _logAssignmentSync({
    required String tagId,
    required String mediaItemId,
    required String operation,
    required int updatedAt,
    required int deleted,
  }) {
    return _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('media_item_tag'),
      entityId: Value('$mediaItemId|$tagId'),
      operation: Value(operation),
      payloadJson: Value(jsonEncode({
        'media_item_id': mediaItemId,
        'tag_id': tagId,
        'updated_at': updatedAt,
        'deleted': deleted,
      })),
      createdAt: Value(updatedAt),
    ));
  }

  Tag _fromRow(TagsTableData row) => Tag(
        id: row.id,
        name: row.name,
        colour: row.colour,
        updatedAt: row.updatedAt,
      );
}
