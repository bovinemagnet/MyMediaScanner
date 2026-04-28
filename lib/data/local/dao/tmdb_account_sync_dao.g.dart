// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_account_sync_dao.dart';

// ignore_for_file: type=lint
mixin _$TmdbAccountSyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $TmdbAccountSyncItemsTableTable get tmdbAccountSyncItemsTable =>
      attachedDatabase.tmdbAccountSyncItemsTable;
  TmdbAccountSyncDaoManager get managers => TmdbAccountSyncDaoManager(this);
}

class TmdbAccountSyncDaoManager {
  final _$TmdbAccountSyncDaoMixin _db;
  TmdbAccountSyncDaoManager(this._db);
  $$TmdbAccountSyncItemsTableTableTableManager get tmdbAccountSyncItemsTable =>
      $$TmdbAccountSyncItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.tmdbAccountSyncItemsTable,
      );
}
