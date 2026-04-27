import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/json_key_case.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
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

      // Track which entity IDs were successfully pushed this cycle so we
      // can stamp `synced_at` on only those local rows afterwards. The
      // prior implementation stamped every unsynced row regardless of
      // whether its sync_log entry was actually processed, which caused
      // silent data loss for rows whose log entry was purged or missed.
      final pushedIds = <String>{};
      Object? firstFailure;

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
          stopwatch.stop();
          // Network IO sits outside the transaction so the SQLite write
          // lock isn't held for the round-trip. Once the upsert is
          // confirmed, atomically mark the log entry synced and stamp its
          // result metadata so a crash between can't leave the row pushed
          // remotely while the local log says pending.
          await _syncLogDao.transaction(() async {
            await _syncLogDao.markSynced(log.id);
            await _syncLogDao.updateLogResult(
              log.id,
              durationMs: stopwatch.elapsedMilliseconds,
              direction: 'push',
              resolvedBy: 'auto',
            );
          });
          pushedIds.add(log.entityId);
        } on Exception catch (e) {
          stopwatch.stop();
          await _syncLogDao.updateLogResult(
            log.id,
            durationMs: stopwatch.elapsedMilliseconds,
            direction: 'push',
            errorMessage: e.toString(),
          );
          // Keep the first error but continue pushing the remaining log
          // entries — otherwise a single transient failure silently leaves
          // the rest invisible to `getFailedEntries`.
          firstFailure ??= e;
        }
      }

      // Stamp `synced_at` only on the local rows we actually pushed.
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in pushedIds) {
        await _mediaItemsDao.markSynced(id, now);
      }

      _progressController.add(SyncProgress.idle);
      await _emitStatus(isSyncing: false);
      if (firstFailure != null) {
        // Surface the failure to the caller while the status stream
        // already reflects per-entry errorMessages.
        throw firstFailure;
      }
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
      // Pull only remote rows modified since our last successful sync.
      // Without this the pull grows linearly with the remote table size
      // and eventually times out on mobile networks.
      final lastSyncedAt = await _getLastSyncedAt();
      final remoteItems = await _syncClient.pullRecords(
        'media_items',
        afterTimestamp: lastSyncedAt,
      );
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
          // Insert new remote item locally. Do NOT trust the remote's
          // `synced_at` — stamp it ourselves so `getUnsynced()` doesn't
          // immediately re-flag this row as pending push.
          final insertData = Map<String, dynamic>.of(remote)
            ..['synced_at'] = DateTime.now().millisecondsSinceEpoch;
          await _mediaItemsDao.insertItem(_mapToCompanion(insertData));
          continue;
        }

        // Drift's toJson() emits camelCase keys; Postgres sends snake_case.
        // Normalise to snake_case so merge/conflict detection compares
        // apples to apples and _mapToCompanion (snake-case reader) sees
        // every merged field.
        final localJson = JsonKeyCase.toSnakeCase(localRow.toJson());

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
        // Stamp synced_at on the merged row so the pulled state isn't
        // re-flagged as dirty on the next push.
        merged['synced_at'] = DateTime.now().millisecondsSinceEpoch;

        // Atomic: write the merged row AND refresh any pending push payload
        // together. If we updated the local row but crashed before
        // refreshing the pending payload, the next push would replay the
        // pre-pull snapshot and silently clobber whichever fields remote
        // just contributed.
        await _mediaItemsDao.transaction(() async {
          await _mediaItemsDao.updateItem(_mapToCompanion(merged));
          await _syncLogDao.updatePendingPayload(
            'media_item',
            remoteId,
            jsonEncode(merged),
          );
        });
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

    // Pull the remote table ONCE for the whole resolution batch. Prior
    // versions called pullRecords() inside the per-entity loop, turning an
    // O(n) operation into O(n·m) — a full table download per conflicted
    // row — which hung the UI for any realistic conflict list.
    final remoteItems = await _syncClient.pullRecords('media_items');

    for (final entry in byEntity.entries) {
      final entityId = entry.key;
      final entityResolutions = entry.value;

      final localRow = await _mediaItemsDao.getById(entityId);
      if (localRow == null) continue;

      final remote = remoteItems.firstWhere(
        (r) => r['id'] == entityId,
        orElse: () => <String, dynamic>{},
      );
      if (remote.isEmpty) continue;

      final merged = SyncStrategy.mergeWithResolutions(
        JsonKeyCase.toSnakeCase(localRow.toJson()),
        remote,
        entityResolutions,
      );
      merged['synced_at'] = DateTime.now().millisecondsSinceEpoch;

      // Atomic: persist the user-resolved merge, refresh the pending
      // push payload, AND record the resolution audit log together. A
      // crash between any pair would leave a half-resolved conflict —
      // e.g. row updated but pending payload still showing the pre-merge
      // snapshot, or audit log claiming a resolution that the row never
      // received.
      await _mediaItemsDao.transaction(() async {
        await _mediaItemsDao.updateItem(_mapToCompanion(merged));

        await _syncLogDao.updatePendingPayload(
          'media_item',
          entityId,
          jsonEncode(merged),
        );

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
      });
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

  /// Closes the status/progress broadcast controllers so a subsequent
  /// repository rebuild (e.g. via Riverpod invalidation) doesn't leak
  /// listeners on the old instance.
  Future<void> dispose() async {
    if (!_statusController.isClosed) await _statusController.close();
    if (!_progressController.isClosed) await _progressController.close();
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

  /// Resolve an ownership_status value received from the remote, logging a
  /// warning and defaulting to `owned` when the value is unrecognised
  /// (e.g. a typo or an enum variant from a newer client).
  String _resolveOwnershipStatus(Object? raw) {
    final value = raw as String?;
    final parsed = OwnershipStatus.fromString(value);
    if (parsed != null) return parsed.name;
    if (value != null) {
      debugPrint(
          'Unknown ownership_status "$value" from sync - defaulting to owned');
    }
    return OwnershipStatus.owned.name;
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
      ownershipStatus: Value(_resolveOwnershipStatus(data['ownership_status'])),
      condition: Value(data['condition'] as String?),
      pricePaid: Value(data['price_paid'] as double?),
      acquiredAt: Value(data['acquired_at'] as int?),
      retailer: Value(data['retailer'] as String?),
      locationId: Value(data['location_id'] as String?),
      seriesId: Value(data['series_id'] as String?),
      seriesPosition: Value(data['series_position'] as int?),
      progressCurrent: Value(data['progress_current'] as int?),
      progressTotal: Value(data['progress_total'] as int?),
      progressUnit: Value(data['progress_unit'] as String?),
      startedAt: Value(data['started_at'] as int?),
      completedAt: Value(data['completed_at'] as int?),
      consumed: Value(_resolveConsumed(data['consumed'])),
      dateAdded: Value(data['date_added'] as int? ?? 0),
      dateScanned: Value(data['date_scanned'] as int? ?? 0),
      updatedAt: Value(data['updated_at'] as int? ?? 0),
      syncedAt: Value(data['synced_at'] as int?),
      deleted: Value(data['deleted'] as int? ?? 0),
    );
  }

  int _resolveConsumed(Object? raw) {
    if (raw is int) return raw == 0 ? 0 : 1;
    if (raw is bool) return raw ? 1 : 0;
    return 0;
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

