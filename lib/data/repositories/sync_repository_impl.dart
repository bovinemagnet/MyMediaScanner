import 'dart:async';
import 'dart:convert';

import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';

class SyncRepositoryImpl implements ISyncRepository {
  SyncRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
    required PostgresSyncClient syncClient,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao,
        _syncClient = syncClient;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  final PostgresSyncClient _syncClient;
  final _statusController = StreamController<SyncStatus>.broadcast();

  @override
  Future<void> pushChanges() async {
    await _emitStatus(isSyncing: true);
    try {
      final pending = await _syncLogDao.getPending();
      for (final log in pending) {
        final decoded = jsonDecode(log.payloadJson);
        if (decoded is! Map<String, dynamic>) continue;
        await _syncClient.upsertRecords('${log.entityType}s', [decoded]);
        await _syncLogDao.markSynced(log.id);
      }

      // Mark all items as synced
      final unsynced = await _mediaItemsDao.getUnsynced();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final item in unsynced) {
        await _mediaItemsDao.markSynced(item.id, now);
      }

      await _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      await _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<void> pullChanges() async {
    await _emitStatus(isSyncing: true);
    try {
      // Pull remote media items and merge
      final remoteItems = await _syncClient.pullRecords('media_items');

      for (final remote in remoteItems) {
        final remoteId = remote['id'];
        if (remoteId is! String) continue;
        final localRow = await _mediaItemsDao.getById(remoteId);
        if (localRow == null) {
          // TODO: insert new remote items locally once companion
          // factory is available.
          continue;
        }
        // TODO: persist the merged result once DAO update method is
        // available.
        SyncStrategy.mergeFields(
          localRow.toJson(),
          remote,
        );
      }

      await _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      await _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> testConnection() => _syncClient.testConnection();

  @override
  Future<void> resetLocalDatabase() async {
    // Pull all remote data and replace local
    await _emitStatus(isSyncing: true);
    try {
      await pullChanges();
      await _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      await _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _statusController.stream;

  Future<void> _emitStatus({
    bool isSyncing = false,
    String? error,
  }) async {
    final pendingLogs = await _syncLogDao.getPending();
    _statusController.add(SyncStatus(
      pendingCount: pendingLogs.length,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      isSyncing: isSyncing,
      error: error,
    ));
  }
}
