// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_log_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncLogTableTable get syncLogTable => attachedDatabase.syncLogTable;
  SyncLogDaoManager get managers => SyncLogDaoManager(this);
}

class SyncLogDaoManager {
  final _$SyncLogDaoMixin _db;
  SyncLogDaoManager(this._db);
  $$SyncLogTableTableTableManager get syncLogTable =>
      $$SyncLogTableTableTableManager(_db.attachedDatabase, _db.syncLogTable);
}
