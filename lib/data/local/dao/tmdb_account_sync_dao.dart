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

  /// Insert-or-merge by `(tmdb_id, tmdb_media_type)`. For a new row the
  /// companion is inserted verbatim (with `created_at`/`updated_at` set to
  /// now). For an existing row each nullable column is only overwritten when
  /// the incoming value is non-null; non-nullable integer flag columns
  /// (`watchlist`, `favorite`, `local_dirty`, `remote_dirty`) are only
  /// overwritten when the incoming value is 1 (truthy), so a second upsert
  /// that does not set a flag cannot clear one already set by an earlier
  /// upsert. `id` and `created_at` from the existing row always win;
  /// `updated_at` is bumped to now.
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
      // Merge: build a companion that only overwrites fields that carry
      // meaningful new data from the caller.
      await (update(tmdbAccountSyncItemsTable)
            ..where((t) => t.id.equals(existing.id)))
          .write(_mergeCompanion(existing, companion, now));
    });
  }

  /// Build a companion that merges [incoming] onto [existing].
  ///
  /// Rules:
  /// - Nullable text/real columns: keep existing when incoming is null.
  /// - Integer flag columns (watchlist, favorite, localDirty, remoteDirty):
  ///   keep the higher value (OR semantics — once set to 1, a zero from a
  ///   later upsert does not clear it).
  /// - `id` and `createdAt` are never touched here (where-clause targets id).
  /// - `updatedAt` is always set to [now].
  TmdbAccountSyncItemsTableCompanion _mergeCompanion(
    TmdbAccountSyncItemsTableData existing,
    TmdbAccountSyncItemsTableCompanion incoming,
    int now,
  ) {
    // For a nullable column, prefer the incoming value when it's non-null.
    Value<T?> mergeNullable<T>(Value<T?> inc, T? existingVal) =>
        (inc.present && inc.value != null) ? inc : Value(existingVal);

    // For integer flag columns, keep the higher value.
    Value<int> mergeFlag(Value<int> inc, int existingVal) {
      final incomingVal = inc.present ? inc.value : 0;
      return Value(incomingVal > existingVal ? incomingVal : existingVal);
    }

    return TmdbAccountSyncItemsTableCompanion(
      mediaItemId:
          mergeNullable(incoming.mediaItemId, existing.mediaItemId),
      tmdbId: Value(existing.tmdbId),
      tmdbMediaType: Value(existing.tmdbMediaType),
      barcode: mergeNullable(incoming.barcode, existing.barcode),
      titleSnapshot:
          mergeNullable(incoming.titleSnapshot, existing.titleSnapshot),
      posterPathSnapshot: mergeNullable(
          incoming.posterPathSnapshot, existing.posterPathSnapshot),
      tmdbRating: mergeNullable(incoming.tmdbRating, existing.tmdbRating),
      localRatingSnapshot: mergeNullable(
          incoming.localRatingSnapshot, existing.localRatingSnapshot),
      watchlist: mergeFlag(incoming.watchlist, existing.watchlist),
      favorite: mergeFlag(incoming.favorite, existing.favorite),
      listIdsJson: incoming.listIdsJson.present
          ? incoming.listIdsJson
          : Value(existing.listIdsJson),
      accountStateJson: incoming.accountStateJson.present
          ? incoming.accountStateJson
          : Value(existing.accountStateJson),
      localDirty: mergeFlag(incoming.localDirty, existing.localDirty),
      remoteDirty: mergeFlag(incoming.remoteDirty, existing.remoteDirty),
      lastPulledAt:
          mergeNullable(incoming.lastPulledAt, existing.lastPulledAt),
      lastPushedAt:
          mergeNullable(incoming.lastPushedAt, existing.lastPushedAt),
      lastError: mergeNullable(incoming.lastError, existing.lastError),
      updatedAt: Value(now),
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
        query.where((t) => t.watchlist.equals(1));
      case TmdbBridgeBucket.favourite:
        query.where((t) => t.favorite.equals(1));
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
        query.where((t) => t.watchlist.equals(1));
      case TmdbBridgeBucket.favourite:
        query.where((t) => t.favorite.equals(1));
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
            ..where((t) => t.mediaItemId.isNull() & t.localDirty.equals(0)))
          .go();
    }
    final all = await (select(tmdbAccountSyncItemsTable)
          ..where((t) => t.mediaItemId.isNull() & t.localDirty.equals(0)))
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
