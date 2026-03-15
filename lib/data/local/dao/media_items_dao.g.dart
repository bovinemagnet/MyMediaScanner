// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_items_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
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
}
