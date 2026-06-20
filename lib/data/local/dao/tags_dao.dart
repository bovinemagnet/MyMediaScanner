import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_item_tags_table.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [TagsTable, MediaItemTagsTable])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Stream<List<TagsTableData>> watchAll() {
    return (select(tagsTable)..where((t) => t.deleted.equals(0))).watch();
  }

  Future<TagsTableData?> getById(String id) {
    return (select(tagsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Bulk fetch of `updated_at` keyed by id — one query for a whole pull
  /// batch instead of one [getById] per remote row.
  Future<Map<String, int>> updatedAtByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final rows = await (selectOnly(tagsTable)
          ..addColumns([tagsTable.id, tagsTable.updatedAt])
          ..where(tagsTable.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.read(tagsTable.id)!: r.read(tagsTable.updatedAt)!,
    };
  }

  Future<void> insertTag(TagsTableCompanion tag) {
    return into(tagsTable).insert(tag);
  }

  Future<void> updateTag(TagsTableCompanion tag) {
    return (update(tagsTable)..where((t) => t.id.equals(tag.id.value)))
        .write(tag);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(tagsTable)..where((t) => t.id.equals(id))).write(
      TagsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Upsert (not insert-or-ignore): re-assigning a previously removed
  /// tag must resurrect the soft-deleted row, clearing its tombstone.
  Future<void> assignToMediaItem(
    String tagId,
    String mediaItemId, {
    int? updatedAt,
  }) {
    return into(mediaItemTagsTable).insertOnConflictUpdate(
      MediaItemTagsTableCompanion(
        tagId: Value(tagId),
        mediaItemId: Value(mediaItemId),
        updatedAt:
            Value(updatedAt ?? DateTime.now().millisecondsSinceEpoch),
        deleted: const Value(0),
      ),
    );
  }

  /// Soft delete: the tombstone row (deleted = 1) is what replicates the
  /// removal to other devices via sync.
  Future<void> removeFromMediaItem(
    String tagId,
    String mediaItemId, {
    int? updatedAt,
  }) {
    return (update(mediaItemTagsTable)
          ..where(
              (t) => t.tagId.equals(tagId) & t.mediaItemId.equals(mediaItemId)))
        .write(MediaItemTagsTableCompanion(
      deleted: const Value(1),
      updatedAt: Value(updatedAt ?? DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) async {
    final rows = await (select(mediaItemTagsTable)
          ..where((t) =>
              t.mediaItemId.equals(mediaItemId) & t.deleted.equals(0)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }

  /// Local `updated_at` for an assignment, or null when no row exists.
  /// Used by pull's last-write-wins comparison.
  Future<int?> assignmentUpdatedAt(String mediaItemId, String tagId) async {
    final row = await (select(mediaItemTagsTable)
          ..where((t) =>
              t.mediaItemId.equals(mediaItemId) & t.tagId.equals(tagId)))
        .getSingleOrNull();
    return row?.updatedAt;
  }

  /// Raw upsert used by sync pull — writes whatever the remote row says,
  /// including tombstones.
  Future<void> upsertAssignmentRow(MediaItemTagsTableCompanion row) {
    return into(mediaItemTagsTable).insertOnConflictUpdate(row);
  }
}
