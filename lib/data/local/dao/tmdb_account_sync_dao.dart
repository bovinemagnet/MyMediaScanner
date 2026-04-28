import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/tmdb_account_sync_items_table.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';

part 'tmdb_account_sync_dao.g.dart';

@DriftAccessor(tables: [TmdbAccountSyncItemsTable])
class TmdbAccountSyncDao extends DatabaseAccessor<AppDatabase>
    with _$TmdbAccountSyncDaoMixin {
  TmdbAccountSyncDao(super.db);

  Future<TmdbAccountSyncItemsTableData?> getByTmdbId(
      int tmdbId, String mediaType) {
    return (select(tmdbAccountSyncItemsTable)
          ..where((t) =>
              t.tmdbId.equals(tmdbId) & t.tmdbMediaType.equals(mediaType)))
        .getSingleOrNull();
  }

  /// Insert-or-update by `(tmdb_id, tmdb_media_type)`. For a new row the
  /// companion is inserted verbatim (with `created_at`/`updated_at` set to
  /// now). For an existing row, only the fields present in [companion] are
  /// written; absent fields preserve the existing database values via Drift's
  /// `Value.absent()` semantics. `id` and `created_at` from the existing row
  /// always win; `updated_at` is bumped to now.
  Future<void> upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      final existing = await getByTmdbId(
        companion.tmdbId.value,
        companion.tmdbMediaType.value,
      );
      if (existing == null) {
        await into(tmdbAccountSyncItemsTable).insert(
          companion.copyWith(
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        return;
      }
      // Pass-through: only fields present in the companion are written;
      // absent fields preserve existing values automatically.
      await (update(tmdbAccountSyncItemsTable)
            ..where((t) => t.id.equals(existing.id)))
          .write(_dropPresent(companion).copyWith(updatedAt: Value(now)));
    });
  }

  /// Strip absent columns so `update().write` only touches present ones.
  TmdbAccountSyncItemsTableCompanion _dropPresent(
      TmdbAccountSyncItemsTableCompanion c) {
    return TmdbAccountSyncItemsTableCompanion(
      mediaItemId: c.mediaItemId,
      tmdbId: c.tmdbId,
      tmdbMediaType: c.tmdbMediaType,
      barcode: c.barcode,
      titleSnapshot: c.titleSnapshot,
      posterPathSnapshot: c.posterPathSnapshot,
      tmdbRating: c.tmdbRating,
      localRatingSnapshot: c.localRatingSnapshot,
      watchlist: c.watchlist,
      favorite: c.favorite,
      listIdsJson: c.listIdsJson,
      accountStateJson: c.accountStateJson,
      localDirty: c.localDirty,
      remoteDirty: c.remoteDirty,
      lastPulledAt: c.lastPulledAt,
      lastPushedAt: c.lastPushedAt,
      lastError: c.lastError,
    );
  }

  Future<void> linkToMediaItem({
    required int tmdbId,
    required String mediaType,
    required String mediaItemId,
  }) {
    return (update(tmdbAccountSyncItemsTable)
          ..where((t) =>
              t.tmdbId.equals(tmdbId) & t.tmdbMediaType.equals(mediaType)))
        .write(TmdbAccountSyncItemsTableCompanion(
      mediaItemId: Value(mediaItemId),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Returns rows for [bucket] that are **not** linked to a local
  /// `media_items` row. Used by the three TMDB-only bucket screens.
  Future<List<TmdbAccountSyncItemsTableData>> listByBucket(
      TmdbBridgeBucket bucket) {
    final query = select(tmdbAccountSyncItemsTable)
      ..where((t) => t.mediaItemId.isNull());
    switch (bucket) {
      case TmdbBridgeBucket.watchlist:
        query.where((t) => t.watchlist.equals(true));
      case TmdbBridgeBucket.favourite:
        query.where((t) => t.favorite.equals(true));
      case TmdbBridgeBucket.rated:
        query.where((t) => t.tmdbRating.isNotNull());
    }
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.get();
  }

  Stream<List<TmdbAccountSyncItemsTableData>> watchByBucket(
      TmdbBridgeBucket bucket) {
    final query = select(tmdbAccountSyncItemsTable)
      ..where((t) => t.mediaItemId.isNull());
    switch (bucket) {
      case TmdbBridgeBucket.watchlist:
        query.where((t) => t.watchlist.equals(true));
      case TmdbBridgeBucket.favourite:
        query.where((t) => t.favorite.equals(true));
      case TmdbBridgeBucket.rated:
        query.where((t) => t.tmdbRating.isNotNull());
    }
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch();
  }

  /// Delete bridge rows whose `(tmdb_id, media_type)` is **not** in
  /// [keepKeys] AND that are not linked to a local item AND that have
  /// no pending local-dirty flags. Slice A always passes
  /// `local_dirty == 0` rows; the dirty check protects future slice 2
  /// behaviour.
  Future<int> pruneOrphans({required Set<TmdbBridgeKey> keepKeys}) async {
    if (keepKeys.isEmpty) {
      return (delete(tmdbAccountSyncItemsTable)
            ..where((t) => t.mediaItemId.isNull() & t.localDirty.equals(false)))
          .go();
    }
    final all = await (select(tmdbAccountSyncItemsTable)
          ..where((t) => t.mediaItemId.isNull() & t.localDirty.equals(false)))
        .get();
    final orphanIds = all
        .where((r) => !keepKeys.contains(
            TmdbBridgeKey(tmdbId: r.tmdbId, mediaType: r.tmdbMediaType)))
        .map((r) => r.id)
        .toList();
    if (orphanIds.isEmpty) return 0;
    return (delete(tmdbAccountSyncItemsTable)
          ..where((t) => t.id.isIn(orphanIds)))
        .go();
  }

  Future<void> deleteAll() {
    return delete(tmdbAccountSyncItemsTable).go();
  }
}
