// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaylistDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlaylistsTableTable get playlistsTable => attachedDatabase.playlistsTable;
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $RipAlbumsTableTable get ripAlbumsTable => attachedDatabase.ripAlbumsTable;
  $RipTracksTableTable get ripTracksTable => attachedDatabase.ripTracksTable;
  $PlaylistTracksTableTable get playlistTracksTable =>
      attachedDatabase.playlistTracksTable;
  PlaylistDaoManager get managers => PlaylistDaoManager(this);
}

class PlaylistDaoManager {
  final _$PlaylistDaoMixin _db;
  PlaylistDaoManager(this._db);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(
        _db.attachedDatabase,
        _db.playlistsTable,
      );
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
  $$PlaylistTracksTableTableTableManager get playlistTracksTable =>
      $$PlaylistTracksTableTableTableManager(
        _db.attachedDatabase,
        _db.playlistTracksTable,
      );
}
