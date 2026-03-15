// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rip_library_dao.dart';

// ignore_for_file: type=lint
mixin _$RipLibraryDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $RipAlbumsTableTable get ripAlbumsTable => attachedDatabase.ripAlbumsTable;
  $RipTracksTableTable get ripTracksTable => attachedDatabase.ripTracksTable;
  RipLibraryDaoManager get managers => RipLibraryDaoManager(this);
}

class RipLibraryDaoManager {
  final _$RipLibraryDaoMixin _db;
  RipLibraryDaoManager(this._db);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
  $$RipAlbumsTableTableTableManager get ripAlbumsTable =>
      $$RipAlbumsTableTableTableManager(
        _db.attachedDatabase,
        _db.ripAlbumsTable,
      );
  $$RipTracksTableTableTableManager get ripTracksTable =>
      $$RipTracksTableTableTableManager(
        _db.attachedDatabase,
        _db.ripTracksTable,
      );
}
