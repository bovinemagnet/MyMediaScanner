import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _progressController = StreamController<SyncProgress>.broadcast();
  final List<SyncConflict> _pendingConflicts = [];

  static const _lastSyncedAtKey = 'sync_last_synced_at';

  /// 30 days in milliseconds for automatic purge.
  static const _purgeThresholdMs = 30 * 24 * 60 * 60 * 1000;

  @override
  Future<void> pushChanges() async {
    await _emitStatus(isSyncing: true);
    try {
      final pending = await _syncLogDao.getPending();
      final total = pending.length;

      for (var i = 0; i < pending.length; i++) {
        final log = pending[i];
        _progressController.add(SyncProgress(
          phase: SyncPhase.push,
          current: i + 1,
          total: total,
          currentEntityType: log.entityType,
        ));

        final stopwatch = Stopwatch()..start();
        try {
          final decoded = jsonDecode(log.payloadJson);
          if (decoded is! Map<String, dynamic>) continue;
          await _syncClient.upsertRecords('${log.entityType}s', [decoded]);
          await _syncLogDao.markSynced(log.id);
          stopwatch.stop();
          await _syncLogDao.updateLogResult(
            log.id,
            durationMs: stopwatch.elapsedMilliseconds,
            direction: 'push',
            resolvedBy: 'auto',
          );
        } on Exception catch (e) {
          stopwatch.stop();
          await _syncLogDao.updateLogResult(
            log.id,
            durationMs: stopwatch.elapsedMilliseconds,
            direction: 'push',
            errorMessage: e.toString(),
          );
          rethrow;
        }
      }

      // Mark all items as synced
      final unsynced = await _mediaItemsDao.getUnsynced();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final item in unsynced) {
        await _mediaItemsDao.markSynced(item.id, now);
      }

      _progressController.add(SyncProgress.idle);
      await _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      _progressController.add(SyncProgress.idle);
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
      final total = remoteItems.length;
      _pendingConflicts.clear();

      for (var i = 0; i < remoteItems.length; i++) {
        final remote = remoteItems[i];
        final remoteId = remote['id'];
        if (remoteId is! String) continue;

        _progressController.add(SyncProgress(
          phase: SyncPhase.pull,
          current: i + 1,
          total: total,
          currentEntityType: 'media_item',
        ));

        final localRow = await _mediaItemsDao.getById(remoteId);
        if (localRow == null) {
          // Insert new remote item locally
          await _mediaItemsDao.insertItem(
            _mapToCompanion(remote),
          );
          continue;
        }

        final localJson = localRow.toJson();

        // Detect conflicts for close-in-time edits
        final conflicts = SyncStrategy.detectConflicts(
          localJson,
          remote,
          entityType: 'media_item',
          entityId: remoteId,
        );

        if (conflicts.isNotEmpty) {
          _pendingConflicts.addAll(conflicts);
          // Skip this item — user must resolve conflicts first
          continue;
        }

        // No conflicts — apply standard merge and persist
        final merged = SyncStrategy.mergeFields(localJson, remote);
        await _mediaItemsDao.updateItem(_mapToCompanion(merged));
      }

      // Auto-purge old sync log entries (30 days)
      final purgeThreshold =
          DateTime.now().millisecondsSinceEpoch - _purgeThresholdMs;
      await _syncLogDao.purgeOlderThan(purgeThreshold);

      // Store last synced time only on success (no pending conflicts)
      if (_pendingConflicts.isEmpty) {
        await _storeLastSyncedAt(DateTime.now().millisecondsSinceEpoch);
      }

      _progressController.add(SyncProgress.idle);
      await _emitStatus(
        isSyncing: false,
        conflictCount: _pendingConflicts.length,
      );
    } on Exception catch (e) {
      _progressController.add(SyncProgress.idle);
      await _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> testConnection() => _syncClient.testConnection();

  @override
  Future<void> resetLocalDatabase() async {
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

  @override
  Stream<SyncProgress> watchSyncProgress() => _progressController.stream;

  @override
  Future<List<SyncConflict>> getConflicts() async {
    return List.unmodifiable(_pendingConflicts);
  }

  @override
  Future<void> resolveConflicts(List<SyncConflict> resolutions) async {
    // Group resolutions by entity
    final byEntity = <String, List<SyncConflict>>{};
    for (final resolution in resolutions) {
      byEntity.putIfAbsent(resolution.entityId, () => []).add(resolution);
    }

    for (final entry in byEntity.entries) {
      final entityId = entry.key;
      final entityResolutions = entry.value;

      final localRow = await _mediaItemsDao.getById(entityId);
      if (localRow == null) continue;

      final remoteItems = await _syncClient.pullRecords('media_items');
      final remote = remoteItems.firstWhere(
        (r) => r['id'] == entityId,
        orElse: () => <String, dynamic>{},
      );
      if (remote.isEmpty) continue;

      final merged = SyncStrategy.mergeWithResolutions(
        localRow.toJson(),
        remote,
        entityResolutions,
      );

      await _mediaItemsDao.updateItem(_mapToCompanion(merged));

      // Log the resolution
      for (final res in entityResolutions) {
        final logId =
            '${res.entityId}_${res.fieldName}_${DateTime.now().millisecondsSinceEpoch}';
        await _syncLogDao.insertLog(
          SyncLogTableCompanion.insert(
            id: logId,
            entityType: res.entityType,
            entityId: res.entityId,
            operation: 'conflict_resolution',
            payloadJson: jsonEncode({
              'fieldName': res.fieldName,
              'resolution': res.resolution.name,
            }),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            synced: const Value(1),
            direction: const Value('pull'),
            resolvedBy: const Value('user'),
          ),
        );
      }
    }

    // Clear resolved conflicts
    _pendingConflicts.removeWhere((c) =>
        resolutions.any((r) =>
            r.entityId == c.entityId && r.fieldName == c.fieldName));

    await _storeLastSyncedAt(DateTime.now().millisecondsSinceEpoch);
    await _emitStatus(
      isSyncing: false,
      conflictCount: _pendingConflicts.length,
    );
  }

  @override
  Future<List<SyncLogEntry>> getSyncHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _syncLogDao.getHistory(limit: limit, offset: offset);
    return rows.map(_toSyncLogEntry).toList();
  }

  @override
  Future<void> purgeSyncHistory(int olderThanEpochMs) async {
    await _syncLogDao.purgeOlderThan(olderThanEpochMs);
  }

  Future<void> _emitStatus({
    bool isSyncing = false,
    String? error,
    int conflictCount = 0,
  }) async {
    final pendingLogs = await _syncLogDao.getPending();
    final lastSyncedAt = await _getLastSyncedAt();
    _statusController.add(SyncStatus(
      pendingCount: pendingLogs.length,
      lastSyncedAt: lastSyncedAt,
      isSyncing: isSyncing,
      error: error,
      conflictCount: conflictCount,
    ));
  }

  Future<int?> _getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSyncedAtKey);
  }

  Future<void> _storeLastSyncedAt(int epochMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncedAtKey, epochMs);
  }

  /// Convert a JSON map to a MediaItemsTableCompanion for insertion/update.
  MediaItemsTableCompanion _mapToCompanion(Map<String, dynamic> data) {
    return MediaItemsTableCompanion(
      id: Value(data['id'] as String),
      barcode: Value(data['barcode'] as String? ?? ''),
      barcodeType: Value(data['barcode_type'] as String? ?? ''),
      mediaType: Value(data['media_type'] as String? ?? ''),
      title: Value(data['title'] as String? ?? ''),
      subtitle: Value(data['subtitle'] as String?),
      description: Value(data['description'] as String?),
      coverUrl: Value(data['cover_url'] as String?),
      year: Value(data['year'] as int?),
      publisher: Value(data['publisher'] as String?),
      format: Value(data['format'] as String?),
      genres: Value(data['genres'] as String? ?? '[]'),
      extraMetadata: Value(data['extra_metadata'] as String? ?? '{}'),
      sourceApis: Value(data['source_apis'] as String? ?? '[]'),
      userRating: Value(data['user_rating'] as double?),
      userReview: Value(data['user_review'] as String?),
      criticScore: Value(data['critic_score'] as double?),
      criticSource: Value(data['critic_source'] as String?),
      ownershipStatus:
          Value(data['ownership_status'] as String? ?? 'owned'),
      condition: Value(data['condition'] as String?),
      pricePaid: Value(data['price_paid'] as double?),
      acquiredAt: Value(data['acquired_at'] as int?),
      retailer: Value(data['retailer'] as String?),
      dateAdded: Value(data['date_added'] as int? ?? 0),
      dateScanned: Value(data['date_scanned'] as int? ?? 0),
      updatedAt: Value(data['updated_at'] as int? ?? 0),
      syncedAt: Value(data['synced_at'] as int?),
      deleted: Value(data['deleted'] as int? ?? 0),
    );
  }

  SyncLogEntry _toSyncLogEntry(SyncLogTableData row) {
    return SyncLogEntry(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      operation: row.operation,
      createdAt: row.createdAt,
      attemptedAt: row.attemptedAt,
      synced: row.synced == 1,
      errorMessage: row.errorMessage,
      durationMs: row.durationMs,
      direction: row.direction,
      resolvedBy: row.resolvedBy,
    );
  }
}

