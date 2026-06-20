import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';

class MediaItemTagsTable extends Table {
  @override
  String get tableName => 'media_item_tags';

  TextColumn get mediaItemId =>
      text().references(MediaItemsTable, #id)();
  TextColumn get tagId =>
      text().references(TagsTable, #id)();

  /// Last-write-wins basis for sync (epoch millis).
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// Soft-delete tombstone so removals replicate; readers filter on 0.
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {mediaItemId, tagId};
}
