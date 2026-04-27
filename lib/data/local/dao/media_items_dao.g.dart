// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_items_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $TagsTableTable get tagsTable => attachedDatabase.tagsTable;
  $MediaItemTagsTableTable get mediaItemTagsTable =>
      attachedDatabase.mediaItemTagsTable;
  MediaItemsDaoManager get managers => MediaItemsDaoManager(this);
}

class MediaItemsDaoManager {
  final _$MediaItemsDaoMixin _db;
  MediaItemsDaoManager(this._db);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
  $$TagsTableTableTableManager get tagsTable =>
      $$TagsTableTableTableManager(_db.attachedDatabase, _db.tagsTable);
  $$MediaItemTagsTableTableTableManager get mediaItemTagsTable =>
      $$MediaItemTagsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemTagsTable,
      );
}
