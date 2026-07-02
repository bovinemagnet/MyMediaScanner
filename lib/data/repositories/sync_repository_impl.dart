import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/core/utils/debug_log.dart';
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

      // Track which media-item IDs were successfully pushed this cycle so
      // we can stamp `synced_at` on only those local rows afterwards.
      // Only `media_items` carries a `synced_at` column, so log entries
      // for other entity types must not feed this set — a tag/shelf/etc.
      // id that happened to collide with a media item id would otherwise
      // stamp an unpushed media item as synced.
      final pushedMediaItemIds = <String>{};
      Object? firstFailure;

      // Entities with unresolved conflicts must not be pushed — the
      // unconditional upsert would overwrite the other device's edit
      // before the user has chosen a resolution. They stay pending and
      // push after resolveConflicts refreshes their payload.
      final conflictedIds = {
        for (final c in _pendingConflicts)
          if (c.entityType == 'media_item') c.entityId,
      };

      for (var i = 0; i < pending.length; i++) {
        final log = pending[i];
        if (log.entityType == 'media_item' &&
            conflictedIds.contains(log.entityId)) {
          continue;
        }
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
          // Resolve table from a maintained map — naive `+s` pluralisation
          // mangles `shelf`/`series` and previously caused those pushes
          // to fail the allow-list check before they ever reached the
          // server.
          final table =
              PostgresSyncClient.tableForEntityType(log.entityType);
          await _syncClient.upsertRecords(table, [decoded]);
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
          if (log.entityType == 'media_item') {
            pushedMediaItemIds.add(log.entityId);
          }
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

      // Stamp `synced_at` only on the media-item rows we actually pushed,
      // in a single bulk UPDATE rather than one statement per row.
      await _mediaItemsDao.markSyncedAll(
        pushedMediaItemIds.toList(),
        DateTime.now().millisecondsSinceEpoch,
      );

      _progressController.add(SyncProgress.idle);
      // Push runs after pull in a sync cycle, so this is the cycle's
      // final status emission — it must carry the still-pending
      // conflict count rather than resetting it to zero.
      await _emitStatus(
        isSyncing: false,
        conflictCount: _pendingConflicts.length,
      );
      if (firstFailure != null) {
        // Surface the failure to the caller while the status stream
        // already reflects per-entry errorMessages.
        throw firstFailure;
      }
    } on Exception catch (e) {
      _progressController.add(SyncProgress.idle);
      await _emitStatus(
        isSyncing: false,
        error: e.toString(),
        conflictCount: _pendingConflicts.length,
      );
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

      for (var i = 0; i < remoteItems.length; i++) {
        final remote = remoteItems[i];
        final remoteId = remote['id'];
        if (remoteId is! String) continue;

        // Refresh this row's conflict entries from the fresh remote
        // state; conflicts for rows outside this delta are retained —
        // clearing them here silently discarded unresolved conflicts
        // once the watermark advanced past their `updated_at`.
        _pendingConflicts.removeWhere((c) => c.entityId == remoteId);

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

        // Remote rows come from SELECT *, so they carry server-managed
        // columns the local schema doesn't have — `created_at`
        // (TIMESTAMPTZ, decoded as a Dart DateTime) and `device_id`.
        // Restrict the remote map to the local column set so the merge
        // can't feed un-encodable values into jsonEncode below, or echo
        // server-managed columns back to the server on the next push.
        final remoteFiltered = _restrictToColumns(remote, localJson);

        // Detect conflicts for close-in-time edits
        final conflicts = SyncStrategy.detectConflicts(
          localJson,
          remoteFiltered,
          entityType: 'media_item',
          entityId: remoteId,
        );

        if (conflicts.isNotEmpty) {
          _pendingConflicts.addAll(conflicts);
          // Skip this item — user must resolve conflicts first
          continue;
        }

        // No conflicts — apply standard merge and persist
        final merged = SyncStrategy.mergeFields(localJson, remoteFiltered);
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

      // Pull non-media-item tables that this client also pushes. The
      // previous implementation only pulled `media_items`, so a remote
      // edit to a tag / shelf / borrower / loan / location / series
      // would never round-trip back to other clients. These entities
      // don't need the timestamp-window conflict detection that
      // `media_items` does (no per-field merge UI exists for them yet),
      // so we apply a simple last-write-wins by `updated_at`.
      await _pullLastWriteWins(
        tableName: 'tags',
        entityType: 'tag',
        afterTimestamp: lastSyncedAt,
      );
      await _pullLastWriteWins(
        tableName: 'shelves',
        entityType: 'shelf',
        afterTimestamp: lastSyncedAt,
      );
      await _pullLastWriteWins(
        tableName: 'borrowers',
        entityType: 'borrower',
        afterTimestamp: lastSyncedAt,
      );
      await _pullLastWriteWins(
        tableName: 'loans',
        entityType: 'loan',
        afterTimestamp: lastSyncedAt,
      );
      await _pullLastWriteWins(
        tableName: 'locations',
        entityType: 'location',
        afterTimestamp: lastSyncedAt,
      );
      await _pullLastWriteWins(
        tableName: 'series',
        entityType: 'series',
        afterTimestamp: lastSyncedAt,
      );

      // Join tables last, so their parent rows (media items, tags,
      // shelves) have already been pulled in this same pass.
      await _pullJoinTable(
        tableName: 'media_item_tags',
        afterTimestamp: lastSyncedAt,
      );
      await _pullJoinTable(
        tableName: 'shelf_items',
        afterTimestamp: lastSyncedAt,
      );

      // Auto-purge old sync log entries (30 days)
      final purgeThreshold =
          DateTime.now().millisecondsSinceEpoch - _purgeThresholdMs;
      await _syncLogDao.purgeOlderThan(purgeThreshold);

      // Advance the watermark even when conflicts are pending: resolution
      // re-fetches the conflicted rows by id (pullRecordsByIds), so it
      // does not depend on a later pull re-downloading them. Holding the
      // watermark back only forced every subsequent pull to re-download
      // everything since the last clean sync.
      await _storeLastSyncedAt(DateTime.now().millisecondsSinceEpoch);

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

  /// Pull rows from a remote table and upsert them locally using a
  /// last-write-wins policy on `updated_at`. Used for the simple
  /// entities (tag, shelf, borrower, loan, location, series) that don't
  /// have the per-field conflict UI that `media_items` carries.
  ///
  /// A row is applied locally if either:
  ///   - no local row exists with the same `id`, OR
  ///   - the remote `updated_at` is strictly greater than the local
  ///     `updated_at`.
  ///
  /// The local upsert is dispatched per [entityType] because each table
  /// has a distinct companion shape; the `_applyRemoteRow` switch keeps
  /// the dispatch in one place rather than scattered across a wider
  /// callback API.
  Future<void> _pullLastWriteWins({
    required String tableName,
    required String entityType,
    required int? afterTimestamp,
  }) async {
    final rows = await _syncClient.pullRecords(
      tableName,
      afterTimestamp: afterTimestamp,
    );
    // Preload every affected local `updated_at` in ONE query rather than
    // a `getById` per remote row (the N+1 this replaces).
    final ids = rows
        .map((r) => r['id'])
        .whereType<String>()
        .toList();
    final localUpdatedAtById = await _localUpdatedAtByIds(entityType, ids);
    final total = rows.length;
    for (var i = 0; i < rows.length; i++) {
      final remote = rows[i];
      final id = remote['id'];
      if (id is! String) continue;
      _progressController.add(SyncProgress(
        phase: SyncPhase.pull,
        current: i + 1,
        total: total,
        currentEntityType: entityType,
      ));
      final remoteUpdatedAt = (remote['updated_at'] as num?)?.toInt() ?? 0;
      final localUpdatedAt = localUpdatedAtById[id];
      if (localUpdatedAt != null && remoteUpdatedAt <= localUpdatedAt) {
        continue;
      }
      await _applyRemoteRow(entityType, remote);
    }
  }

  /// Pull a composite-key join table (`media_item_tags` / `shelf_items`)
  /// with last-write-wins on `updated_at`. Tombstones (`deleted = 1`)
  /// are applied as-is, soft-deleting the local row.
  ///
  /// Unlike [_pullLastWriteWins] this reads the local `updated_at` one
  /// row at a time — the join tables have no single id column to bulk
  /// key on, and incremental pulls only carry rows changed since the
  /// watermark, so the per-row read stays small.
  Future<void> _pullJoinTable({
    required String tableName,
    required int? afterTimestamp,
  }) async {
    final rows = await _syncClient.pullRecords(
      tableName,
      afterTimestamp: afterTimestamp,
    );
    final db = _mediaItemsDao.attachedDatabase;
    final entityType =
        tableName == 'media_item_tags' ? 'media_item_tag' : 'shelf_item';
    final total = rows.length;
    for (var i = 0; i < rows.length; i++) {
      final remote = rows[i];
      _progressController.add(SyncProgress(
        phase: SyncPhase.pull,
        current: i + 1,
        total: total,
        currentEntityType: entityType,
      ));
      final remoteUpdatedAt = (remote['updated_at'] as num?)?.toInt() ?? 0;
      final deleted = (remote['deleted'] as num?)?.toInt() ?? 0;

      switch (tableName) {
        case 'media_item_tags':
          final mediaItemId = remote['media_item_id'];
          final tagId = remote['tag_id'];
          if (mediaItemId is! String || tagId is! String) continue;
          final localUpdatedAt =
              await db.tagsDao.assignmentUpdatedAt(mediaItemId, tagId);
          if (localUpdatedAt != null && remoteUpdatedAt <= localUpdatedAt) {
            continue;
          }
          await db.tagsDao.upsertAssignmentRow(MediaItemTagsTableCompanion(
            mediaItemId: Value(mediaItemId),
            tagId: Value(tagId),
            updatedAt: Value(remoteUpdatedAt),
            deleted: Value(deleted),
          ));
        case 'shelf_items':
          final shelfId = remote['shelf_id'];
          final mediaItemId = remote['media_item_id'];
          if (shelfId is! String || mediaItemId is! String) continue;
          final localUpdatedAt =
              await db.shelvesDao.itemUpdatedAt(shelfId, mediaItemId);
          if (localUpdatedAt != null && remoteUpdatedAt <= localUpdatedAt) {
            continue;
          }
          await db.shelvesDao.upsertItemRow(ShelfItemsTableCompanion(
            shelfId: Value(shelfId),
            mediaItemId: Value(mediaItemId),
            position: Value((remote['position'] as num?)?.toInt() ?? 0),
            updatedAt: Value(remoteUpdatedAt),
            deleted: Value(deleted),
          ));
        default:
          throw StateError('Unsupported join table for pull: $tableName');
      }
    }
  }

  Future<Map<String, int>> _localUpdatedAtByIds(
      String entityType, List<String> ids) {
    final db = _mediaItemsDao.attachedDatabase;
    switch (entityType) {
      case 'tag':
        return db.tagsDao.updatedAtByIds(ids);
      case 'shelf':
        return db.shelvesDao.updatedAtByIds(ids);
      case 'borrower':
        return db.borrowersDao.updatedAtByIds(ids);
      case 'loan':
        return db.loansDao.updatedAtByIds(ids);
      case 'location':
        return db.locationsDao.updatedAtByIds(ids);
      case 'series':
        return db.seriesDao.updatedAtByIds(ids);
      default:
        throw StateError('Unsupported entity type for pull: $entityType');
    }
  }

  Future<void> _applyRemoteRow(
      String entityType, Map<String, dynamic> remote) async {
    final db = _mediaItemsDao.attachedDatabase;
    switch (entityType) {
      case 'tag':
        await db.into(db.tagsTable).insertOnConflictUpdate(
              TagsTableCompanion.insert(
                id: remote['id'] as String,
                name: remote['name'] as String? ?? '',
                colour: Value(remote['colour'] as String?),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      case 'shelf':
        await db.into(db.shelvesTable).insertOnConflictUpdate(
              ShelvesTableCompanion.insert(
                id: remote['id'] as String,
                name: remote['name'] as String? ?? '',
                description: Value(remote['description'] as String?),
                sortOrder:
                    Value((remote['sort_order'] as num?)?.toInt() ?? 0),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      case 'borrower':
        await db.into(db.borrowersTable).insertOnConflictUpdate(
              BorrowersTableCompanion.insert(
                id: remote['id'] as String,
                name: remote['name'] as String? ?? '',
                email: Value(remote['email'] as String?),
                phone: Value(remote['phone'] as String?),
                notes: Value(remote['notes'] as String?),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      case 'loan':
        await db.into(db.loansTable).insertOnConflictUpdate(
              LoansTableCompanion.insert(
                id: remote['id'] as String,
                mediaItemId: remote['media_item_id'] as String,
                borrowerId: remote['borrower_id'] as String,
                lentAt: (remote['lent_at'] as num?)?.toInt() ?? 0,
                returnedAt:
                    Value((remote['returned_at'] as num?)?.toInt()),
                dueAt: Value((remote['due_at'] as num?)?.toInt()),
                notes: Value(remote['notes'] as String?),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      case 'location':
        await db.into(db.locationsTable).insertOnConflictUpdate(
              LocationsTableCompanion.insert(
                id: remote['id'] as String,
                parentId: Value(remote['parent_id'] as String?),
                name: remote['name'] as String? ?? '',
                sortOrder:
                    Value((remote['sort_order'] as num?)?.toInt() ?? 0),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      case 'series':
        await db.into(db.seriesTable).insertOnConflictUpdate(
              SeriesTableCompanion.insert(
                id: remote['id'] as String,
                externalId: remote['external_id'] as String? ?? '',
                name: remote['name'] as String? ?? '',
                mediaType: remote['media_type'] as String? ?? '',
                source: remote['source'] as String? ?? '',
                totalCount: Value((remote['total_count'] as num?)?.toInt()),
                updatedAt: (remote['updated_at'] as num?)?.toInt() ?? 0,
                deleted: Value((remote['deleted'] as num?)?.toInt() ?? 0),
              ),
            );
      default:
        throw StateError('Unsupported entity type for pull: $entityType');
    }
  }

  @override
  Future<bool> testConnection() => _syncClient.testConnection();

  @override
  Future<void> resetLocalDatabase() async {
    await _emitStatus(isSyncing: true);
    try {
      // Honour the dialog promise: "replace all local data with data
      // from your PostgreSQL server". The previous implementation only
      // wiped `media_items` and `sync_log`, leaving shelves, tags,
      // tag/shelf joins, borrowers, loans, locations, and series behind
      // — orphaned local data that the next pull couldn't reconcile.
      // `wipeSyncedUserData` clears every synced table in one atomic
      // transaction; non-synced tables (rip library, batch sessions,
      // barcode cache) are left alone since the server has nothing to
      // repopulate them with.
      await _mediaItemsDao.attachedDatabase.wipeSyncedUserData();
      _pendingConflicts.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncedAtKey);

      await pullChanges();
      await _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      await _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Stream<SyncStatus> watchSyncStatus() async* {
    // Emit a current snapshot first so subscribers (most commonly the
    // syncStatusProvider StreamProvider) leave the loading state
    // immediately. The underlying controller is a non-replaying broadcast
    // stream — without this seed, the UI sat on "Checking sync
    // status..." until the first push/pull event, which on a fresh
    // launch with no pending work would never arrive.
    yield await _computeStatus(
      conflictCount: _pendingConflicts.length,
    );
    yield* _statusController.stream;
  }

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

    // Fetch ONLY the conflicted rows, in one targeted query. Prior
    // versions downloaded the entire remote table (originally once per
    // conflicted row), which hung the UI for any realistic collection.
    final remoteItems = await _syncClient.pullRecordsByIds(
      'media_items',
      byEntity.keys.toList(),
    );

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

      // Strip server-managed columns (see pullChanges) before merging so
      // the pending payload below stays JSON-encodable.
      final localJson = JsonKeyCase.toSnakeCase(localRow.toJson());
      final merged = SyncStrategy.mergeWithResolutions(
        localJson,
        _restrictToColumns(remote, localJson),
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

  @override
  Future<void> clearSyncHistory() async {
    await _syncLogDao.deleteAll();
    await _emitStatus();
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
    _statusController.add(await _computeStatus(
      isSyncing: isSyncing,
      error: error,
      conflictCount: conflictCount,
    ));
  }

  Future<SyncStatus> _computeStatus({
    bool isSyncing = false,
    String? error,
    int conflictCount = 0,
  }) async {
    final pendingLogs = await _syncLogDao.getPending();
    final lastSyncedAt = await _getLastSyncedAt();
    return SyncStatus(
      pendingCount: pendingLogs.length,
      lastSyncedAt: lastSyncedAt,
      isSyncing: isSyncing,
      error: error,
      conflictCount: conflictCount,
    );
  }

  /// Restrict a remote row to the columns present on the local row.
  ///
  /// Remote rows are fetched with SELECT *, so they include columns the
  /// local schema doesn't carry (`created_at`, `device_id`). Those must
  /// not survive into merged payloads: `created_at` arrives as a Dart
  /// [DateTime] (not JSON-encodable) and `device_id` would be pushed
  /// back, clobbering the server's attribution of the original writer.
  static Map<String, dynamic> _restrictToColumns(
    Map<String, dynamic> remote,
    Map<String, dynamic> localJson,
  ) {
    return {
      for (final entry in remote.entries)
        if (localJson.containsKey(entry.key)) entry.key: entry.value,
    };
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
      debugLog(
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
      currentValue: Value(data['current_value'] as double?),
      currentValueAsOf: Value(data['current_value_as_of'] as int?),
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

