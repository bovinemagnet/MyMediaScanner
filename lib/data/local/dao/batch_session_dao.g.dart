// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_session_dao.dart';

// ignore_for_file: type=lint
mixin _$BatchSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $BatchSessionsTableTable get batchSessionsTable =>
      attachedDatabase.batchSessionsTable;
  $BatchQueueItemsTableTable get batchQueueItemsTable =>
      attachedDatabase.batchQueueItemsTable;
  BatchSessionDaoManager get managers => BatchSessionDaoManager(this);
}

class BatchSessionDaoManager {
  final _$BatchSessionDaoMixin _db;
  BatchSessionDaoManager(this._db);
  $$BatchSessionsTableTableTableManager get batchSessionsTable =>
      $$BatchSessionsTableTableTableManager(
        _db.attachedDatabase,
        _db.batchSessionsTable,
      );
  $$BatchQueueItemsTableTableTableManager get batchQueueItemsTable =>
      $$BatchQueueItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.batchQueueItemsTable,
      );
}
