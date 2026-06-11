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

  Future<void> assignToMediaItem(String tagId, String mediaItemId) {
    return into(mediaItemTagsTable).insert(
      MediaItemTagsTableCompanion(
        tagId: Value(tagId),
        mediaItemId: Value(mediaItemId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeFromMediaItem(String tagId, String mediaItemId) {
    return (delete(mediaItemTagsTable)
          ..where(
              (t) => t.tagId.equals(tagId) & t.mediaItemId.equals(mediaItemId)))
        .go();
  }

  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) async {
    final rows = await (select(mediaItemTagsTable)
          ..where((t) => t.mediaItemId.equals(mediaItemId)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }
}
