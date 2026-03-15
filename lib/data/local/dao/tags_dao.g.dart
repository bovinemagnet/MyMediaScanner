// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_dao.dart';

// ignore_for_file: type=lint
mixin _$TagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTableTable get tagsTable => attachedDatabase.tagsTable;
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $MediaItemTagsTableTable get mediaItemTagsTable =>
      attachedDatabase.mediaItemTagsTable;
  TagsDaoManager get managers => TagsDaoManager(this);
}

class TagsDaoManager {
  final _$TagsDaoMixin _db;
  TagsDaoManager(this._db);
  $$TagsTableTableTableManager get tagsTable =>
      $$TagsTableTableTableManager(_db.attachedDatabase, _db.tagsTable);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
  $$MediaItemTagsTableTableTableManager get mediaItemTagsTable =>
      $$MediaItemTagsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemTagsTable,
      );
}
