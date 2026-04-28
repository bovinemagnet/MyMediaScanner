import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tmdb_account_sync_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/mappers/tmdb_account_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_push_action.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class TmdbAccountSyncRepositoryImpl implements ITmdbAccountSyncRepository {
  TmdbAccountSyncRepositoryImpl({
    required this.api,
    required this.dao,
    required this.mediaItemsDao,
    required this.storage,
  });

  final TmdbAccountApi api;
  final TmdbAccountSyncDao dao;
  final MediaItemsDao mediaItemsDao;
  final FlutterSecureStorage storage;

  static const _kSession = 'tmdb.session_id';
  static const _kAccountId = 'tmdb.account_id';
  static const _kUsername = 'tmdb.account_username';
  static const _kListId = 'tmdb.mymediascanner_list_id';

  // ── Connection state ──────────────────────────────────────────

  @override
  Future<TmdbConnectionState> currentState() async {
    final session = await storage.read(key: _kSession);
    if (session == null) return const TmdbDisconnected();
    final id = int.tryParse(await storage.read(key: _kAccountId) ?? '');
    final username = await storage.read(key: _kUsername);
    if (id == null || username == null) return const TmdbDisconnected();
    return TmdbConnected(accountId: id, username: username);
  }

  // ── Auth ──────────────────────────────────────────────────────

  @override
  Future<({String requestToken, Uri approvalUrl})> startConnect() async {
    final dto = await api.createRequestToken();
    if (!dto.success) {
      throw const TmdbConnectException('TMDB rejected the token request');
    }
    final url = Uri.parse(
        'https://www.themoviedb.org/authenticate/${dto.requestToken}');
    return (requestToken: dto.requestToken, approvalUrl: url);
  }

  @override
  Future<TmdbConnectionState> finishConnect(String requestToken) async {
    try {
      final session =
          await api.createSession({'request_token': requestToken});
      if (!session.success) {
        throw const TmdbConnectException(
            'TMDB rejected the session exchange');
      }
      final account = await api.getAccount(session.sessionId);
      await storage.write(key: _kSession, value: session.sessionId);
      await storage.write(key: _kAccountId, value: account.id.toString());
      await storage.write(key: _kUsername, value: account.username);
      return TmdbConnected(
          accountId: account.id, username: account.username);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const TmdbConnectionError(
            'Approval not detected. Re-open the approval page and try again.');
      }
      return TmdbConnectionError(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> disconnect() async {
    final session = await storage.read(key: _kSession);
    if (session != null) {
      try {
        await api.deleteSession({'session_id': session});
      } on DioException {
        // best-effort — clear local creds even if the remote delete fails.
      }
    }
    await storage.delete(key: _kSession);
    await storage.delete(key: _kAccountId);
    await storage.delete(key: _kUsername);
    await storage.delete(key: _kListId);
  }

  // ── Bridge data ───────────────────────────────────────────────

  @override
  Stream<List<TmdbBridgeItem>> watchBucket(TmdbBridgeBucket bucket) {
    return dao
        .watchByBucket(bucket)
        .map((rows) => rows.map(TmdbAccountMapper.rowToBridgeItem).toList());
  }

  @override
  Future<TmdbBridgeItem?> getByTmdbId(int tmdbId, String mediaType) async {
    final row = await dao.getByTmdbId(tmdbId, mediaType);
    return row == null ? null : TmdbAccountMapper.rowToBridgeItem(row);
  }

  @override
  Future<void> enrichOne(
      {required int tmdbId, required String mediaType}) async {
    final session = await storage.read(key: _kSession);
    if (session == null) return;
    final dto = mediaType == 'tv'
        ? await api.getTvAccountState(tmdbId, session)
        : await api.getMovieAccountState(tmdbId, session);
    final existing = await dao.getByTmdbId(tmdbId, mediaType);
    final companion = TmdbAccountMapper.accountStateCompanion(
      dto,
      mediaType: mediaType,
      existingId: existing?.id,
    );
    await dao.upsertByTmdbId(companion);
  }

  // ── Sync ──────────────────────────────────────────────────────

  @override
  Future<TmdbSyncSummary> importAll({
    required Set<TmdbBucketSelection> selectedBuckets,
    void Function(int pulled, int failed)? progress,
  }) async {
    final state = await currentState();
    if (state is! TmdbConnected) {
      return const TmdbSyncSummary(
          pulled: 0, failed: 0, lastError: 'Not connected to TMDB');
    }
    final session = (await storage.read(key: _kSession))!;
    int pulled = 0;
    int failed = 0;
    String? lastError;

    for (final selection in selectedBuckets) {
      try {
        var page = 1;
        var totalPages = 1;
        do {
          final pageDto = await _fetchBucketPage(
            api: api,
            accountId: state.accountId,
            sessionId: session,
            selection: selection,
            page: page,
          );
          totalPages = pageDto.totalPages;
          for (final item in pageDto.results) {
            final existing = await dao.getByTmdbId(
                item.id, selection.mediaType);
            await dao.upsertByTmdbId(
              TmdbAccountMapper.bucketCompanion(
                item,
                bucket: selection.bucket,
                mediaType: selection.mediaType,
                existingId: existing?.id,
              ),
            );
            pulled++;
          }
          progress?.call(pulled, failed);
          page++;
        } while (page <= totalPages);
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _handle401();
          return TmdbSyncSummary(
              pulled: pulled, failed: failed, lastError: 'Session expired');
        }
        failed++;
        lastError = e.message;
      } catch (e) {
        failed++;
        lastError = e.toString();
      }
    }
    return TmdbSyncSummary(
        pulled: pulled, failed: failed, lastError: lastError);
  }

  @override
  Future<TmdbSyncSummary> syncNow() async {
    final allBuckets = <TmdbBucketSelection>{
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.watchlist, mediaType: 'movie'),
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.watchlist, mediaType: 'tv'),
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.rated, mediaType: 'movie'),
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.rated, mediaType: 'tv'),
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.favourite, mediaType: 'movie'),
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.favourite, mediaType: 'tv'),
    };

    final summary = await importAll(selectedBuckets: allBuckets);
    if (summary.lastError == 'Session expired') return summary;

    // Build the keep-set from all rows still present in any bucket.
    final keep = <TmdbBridgeKey>{};
    for (final b in TmdbBridgeBucket.values) {
      final rows = await dao.listByBucket(b);
      for (final r in rows) {
        keep.add(TmdbBridgeKey(tmdbId: r.tmdbId, mediaType: r.tmdbMediaType));
      }
    }
    await dao.pruneOrphans(keepKeys: keep);
    return summary;
  }

  Future<TmdbAccountListPageDto> _fetchBucketPage({
    required TmdbAccountApi api,
    required int accountId,
    required String sessionId,
    required TmdbBucketSelection selection,
    required int page,
  }) {
    switch ((selection.bucket, selection.mediaType)) {
      case (TmdbBridgeBucket.rated, 'movie'):
        return api.getRatedMovies(accountId, sessionId, page: page);
      case (TmdbBridgeBucket.rated, 'tv'):
        return api.getRatedTv(accountId, sessionId, page: page);
      case (TmdbBridgeBucket.watchlist, 'movie'):
        return api.getWatchlistMovies(accountId, sessionId, page: page);
      case (TmdbBridgeBucket.watchlist, 'tv'):
        return api.getWatchlistTv(accountId, sessionId, page: page);
      case (TmdbBridgeBucket.favourite, 'movie'):
        return api.getFavoriteMovies(accountId, sessionId, page: page);
      case (TmdbBridgeBucket.favourite, 'tv'):
        return api.getFavoriteTv(accountId, sessionId, page: page);
      default:
        throw ArgumentError('Unsupported bucket/media-type: $selection');
    }
  }

  Future<void> _handle401() async {
    await storage.delete(key: _kSession);
    // account_id and username are kept so the UI can show the
    // "Reconnect required — was @paul" message.
  }

  // ── Convert ───────────────────────────────────────────────────

  @override
  Future<String> convertBridgeToLocalItem(String bridgeId) async {
    final row = await (dao.select(dao.tmdbAccountSyncItemsTable)
          ..where((t) => t.id.equals(bridgeId)))
        .getSingleOrNull();
    if (row == null) {
      throw ArgumentError('No bridge row with id=$bridgeId');
    }

    final mediaItemId = 'mi-${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final mediaType = row.tmdbMediaType == 'tv' ? 'tv' : 'film';
    final coverUrl = row.posterPathSnapshot == null
        ? null
        : 'https://image.tmdb.org/t/p/w500${row.posterPathSnapshot}';
    final userRating =
        row.tmdbRating == null ? null : row.tmdbRating! / 2;

    await mediaItemsDao.insertItem(MediaItemsTableCompanion(
      id: Value(mediaItemId),
      barcode: const Value(''),
      barcodeType: const Value(''),
      mediaType: Value(mediaType),
      title: Value(row.titleSnapshot ?? 'Unknown'),
      coverUrl: Value(coverUrl),
      userRating: Value(userRating),
      ownershipStatus: Value(OwnershipStatus.owned.dbValue),
      extraMetadata: Value(jsonEncode({'tmdb_id': row.tmdbId})),
      dateAdded: Value(now),
      dateScanned: Value(now),
      updatedAt: Value(now),
    ));

    await dao.linkToMediaItem(
      tmdbId: row.tmdbId,
      mediaType: row.tmdbMediaType,
      mediaItemId: mediaItemId,
    );

    return mediaItemId;
  }

  // ── Slice 2 — push pipeline ────────────────────────────────────

  @override
  Future<int> countDirtyRows() => dao.countDirtyRows();

  @override
  Stream<int> watchDirtyCount() => dao.watchDirtyCount();

  @override
  Stream<List<TmdbBridgeItem>> watchConflicts() {
    return dao.watchConflicts().map(
        (rows) => rows.map(TmdbAccountMapper.rowToBridgeItem).toList());
  }

  @override
  Future<TmdbPushResult> pushOne({
    required int tmdbId,
    required String mediaType,
  }) async {
    final state = await currentState();
    if (state is! TmdbConnected) {
      return const TmdbPushResult(
          success: false, error: 'Not connected to TMDB');
    }
    final session = (await storage.read(key: _kSession))!;

    final row = await dao.getByTmdbId(tmdbId, mediaType);
    if (row == null) {
      return const TmdbPushResult(
          success: false, error: 'No bridge row');
    }

    final actions = <TmdbPushAction>[];
    final desiredRating = row.tmdbRating;
    final lastPushedRating = row.localRatingSnapshot;
    if (desiredRating != lastPushedRating) {
      if (desiredRating == null) {
        actions.add(const RemoveRating());
      } else {
        actions.add(PushRating(desiredRating));
      }
    }

    // Slice 2 simplification: when row is dirty, also push current
    // watchlist + favourite state. TMDB POSTs are idempotent for these.
    if (row.localDirty) {
      actions.add(PushWatchlist(row.watchlist));
      actions.add(PushFavorite(row.favorite));
    }

    if (actions.isEmpty) {
      // No-op fast path: only touch the DB if there's actually a dirty
      // flag to clear. Avoids spurious `lastPushedAt` / `updatedAt` writes.
      if (row.localDirty) {
        await dao.clearDirty(
          tmdbId: tmdbId,
          mediaType: mediaType,
          pushedRating: desiredRating,
        );
      }
      return const TmdbPushResult(success: true);
    }

    for (final action in actions) {
      try {
        await _executeAction(
          action: action,
          accountId: state.accountId,
          sessionId: session,
          tmdbId: tmdbId,
          mediaType: mediaType,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _handle401();
          await dao.recordPushError(
            tmdbId: tmdbId,
            mediaType: mediaType,
            error: 'Session expired',
          );
          return const TmdbPushResult(
              success: false, error: 'Session expired');
        }
        final msg = e.message ?? 'Network error';
        await dao.recordPushError(
            tmdbId: tmdbId, mediaType: mediaType, error: msg);
        return TmdbPushResult(success: false, error: msg);
      } catch (e) {
        await dao.recordPushError(
            tmdbId: tmdbId, mediaType: mediaType, error: e.toString());
        return TmdbPushResult(success: false, error: e.toString());
      }
    }

    await dao.clearDirty(
      tmdbId: tmdbId,
      mediaType: mediaType,
      pushedRating: desiredRating,
    );
    return const TmdbPushResult(success: true);
  }

  Future<void> _executeAction({
    required TmdbPushAction action,
    required int accountId,
    required String sessionId,
    required int tmdbId,
    required String mediaType,
  }) async {
    switch (action) {
      case PushRating(value: final v):
        if (mediaType == 'tv') {
          await api.addTvRating(tmdbId, sessionId, {'value': v});
        } else {
          await api.addMovieRating(tmdbId, sessionId, {'value': v});
        }
      case RemoveRating():
        if (mediaType == 'tv') {
          await api.removeTvRating(tmdbId, sessionId);
        } else {
          await api.removeMovieRating(tmdbId, sessionId);
        }
      case PushWatchlist(value: final v):
        await api.setWatchlist(accountId, sessionId, {
          'media_type': mediaType,
          'media_id': tmdbId,
          'watchlist': v,
        });
      case PushFavorite(value: final v):
        await api.setFavorite(accountId, sessionId, {
          'media_type': mediaType,
          'media_id': tmdbId,
          'favorite': v,
        });
      case PushOwnership():
        throw StateError('PushOwnership not handled in pushOne');
    }
  }

  @override
  Future<TmdbPushResult> toggleWatchlist({
    required int tmdbId,
    required String mediaType,
    required bool value,
  }) async {
    await dao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(tmdbId),
        tmdbMediaType: Value(mediaType),
        watchlist: Value(value),
        localDirty: const Value(true),
      ),
    );
    return pushOne(tmdbId: tmdbId, mediaType: mediaType);
  }

  @override
  Future<TmdbPushResult> toggleFavorite({
    required int tmdbId,
    required String mediaType,
    required bool value,
  }) async {
    await dao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(tmdbId),
        tmdbMediaType: Value(mediaType),
        favorite: Value(value),
        localDirty: const Value(true),
      ),
    );
    return pushOne(tmdbId: tmdbId, mediaType: mediaType);
  }

  @override
  Future<TmdbPushResult> updateRating({
    required int tmdbId,
    required String mediaType,
    required double? localRating,
  }) async {
    // Convert local 0–5 to TMDB 0.5–10. Null clears.
    final tmdb = localRating == null
        ? null
        : TmdbAccountMapper.localToTmdbRating(localRating);

    await dao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(tmdbId),
        tmdbMediaType: Value(mediaType),
        tmdbRating: Value(tmdb),
        localDirty: const Value(true),
      ),
    );
    return pushOne(tmdbId: tmdbId, mediaType: mediaType);
  }

  @override
  Future<TmdbPushSummary> pushAllDirty() async {
    final dirty = await dao.listDirty();
    int succeeded = 0;
    int failed = 0;
    String? lastError;
    for (final r in dirty) {
      final result = await pushOne(
          tmdbId: r.tmdbId, mediaType: r.tmdbMediaType);
      if (result.success) {
        succeeded++;
      } else {
        failed++;
        lastError = result.error;
      }
    }
    return TmdbPushSummary(
      attempted: dirty.length,
      succeeded: succeeded,
      failed: failed,
      lastError: lastError,
    );
  }

  // ── Slice 2 — list mirror ──────────────────────────────────────

  @override
  Future<int> ensureMyMediaScannerListId() async {
    final cached = await storage.read(key: _kListId);
    if (cached != null) {
      final parsed = int.tryParse(cached);
      if (parsed != null) return parsed;
    }
    final state = await currentState();
    if (state is! TmdbConnected) {
      throw StateError('Not connected — cannot resolve TMDB list');
    }
    final session = (await storage.read(key: _kSession))!;

    // Look up by name across pages.
    var page = 1;
    while (true) {
      final pageDto = await api.getAccountLists(
          state.accountId, session, page: page);
      for (final list in pageDto.results) {
        if (list.name == 'MyMediaScanner') {
          await storage.write(key: _kListId, value: list.id.toString());
          return list.id;
        }
      }
      if (page >= pageDto.totalPages) break;
      page++;
    }

    // Not found → create.
    final created = await api.createList(session, {
      'name': 'MyMediaScanner',
      'description':
          'Mirrored from MyMediaScanner — owned items in your collection.',
      'language': 'en',
    });
    if (!created.success) {
      throw const TmdbConnectException(
          'TMDB rejected the MyMediaScanner list creation');
    }
    await storage.write(
        key: _kListId, value: created.listId.toString());
    return created.listId;
  }

  @override
  Future<TmdbPushResult> mirrorAddOwnership({required int tmdbId}) {
    return _mirrorMutate(tmdbId: tmdbId, add: true);
  }

  @override
  Future<TmdbPushResult> mirrorRemoveOwnership({required int tmdbId}) {
    return _mirrorMutate(tmdbId: tmdbId, add: false);
  }

  Future<TmdbPushResult> _mirrorMutate({
    required int tmdbId,
    required bool add,
  }) async {
    try {
      final state = await currentState();
      if (state is! TmdbConnected) {
        return const TmdbPushResult(
            success: false, error: 'Not connected to TMDB');
      }
      final session = (await storage.read(key: _kSession))!;
      final listId = await ensureMyMediaScannerListId();
      final body = {'media_id': tmdbId};
      if (add) {
        await api.addItemToList(listId, session, body);
      } else {
        await api.removeItemFromList(listId, session, body);
      }
      return const TmdbPushResult(success: true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handle401();
        return const TmdbPushResult(
            success: false, error: 'Session expired');
      }
      return TmdbPushResult(
          success: false, error: e.message ?? 'Network error');
    } catch (e) {
      return TmdbPushResult(success: false, error: e.toString());
    }
  }
}

class TmdbConnectException implements Exception {
  const TmdbConnectException(this.message);
  final String message;

  @override
  String toString() => 'TmdbConnectException: $message';
}
