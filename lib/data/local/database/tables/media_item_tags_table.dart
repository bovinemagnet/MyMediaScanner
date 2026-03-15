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

  @override
  Set<Column> get primaryKey => {mediaItemId, tagId};
}
