import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  TmdbAccountSyncItemsTableCompanion row({
    required String id,
    required int tmdbId,
    String mediaType = 'movie',
    int? watchlist,
    int? favorite,
    double? rating,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return TmdbAccountSyncItemsTableCompanion(
      id: Value(id),
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(mediaType),
      watchlist: Value(watchlist ?? 0),
      favorite: Value(favorite ?? 0),
      tmdbRating: Value(rating),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  test('schemaVersion is 20', () {
    expect(db.schemaVersion, 20);
  });

  test('upsertByTmdbId inserts a new row when none exists', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 550, watchlist: 1),
    );

    final found =
        await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(found, isNotNull);
    expect(found!.watchlist, 1);
  });

  test('upsertByTmdbId merges when row exists', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 550, watchlist: 1),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 550, favorite: 1, rating: 8.0),
    );

    final found =
        await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(found, isNotNull);
    expect(found!.watchlist, 1, reason: 'preserved from first upsert');
    expect(found.favorite, 1, reason: 'set by second upsert');
    expect(found.tmdbRating, 8.0);
  });

  test('listByBucket returns only matching bucket rows', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 1, watchlist: 1),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 2, favorite: 1),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'c', tmdbId: 3, rating: 7.0),
    );

    final watchlist =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.watchlist);
    expect(watchlist.map((r) => r.tmdbId), [1]);

    final favourites =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.favourite);
    expect(favourites.map((r) => r.tmdbId), [2]);

    final rated =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.rated);
    expect(rated.map((r) => r.tmdbId), [3]);
  });

  test('listByBucket excludes rows linked to a media item', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 1, watchlist: 1),
    );
    await db.tmdbAccountSyncDao
        .linkToMediaItem(tmdbId: 1, mediaType: 'movie', mediaItemId: 'item-1');

    final watchlist =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.watchlist);
    expect(watchlist, isEmpty,
        reason: 'rows with media_item_id are excluded from bucket views');
  });

  test('pruneOrphans deletes only unlinked rows missing from keep set',
      () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 1, watchlist: 1),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 2, watchlist: 1),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'c', tmdbId: 3, watchlist: 1),
    );
    await db.tmdbAccountSyncDao
        .linkToMediaItem(tmdbId: 1, mediaType: 'movie', mediaItemId: 'item-1');

    await db.tmdbAccountSyncDao.pruneOrphans(
      keepKeys: {const TmdbBridgeKey(tmdbId: 2, mediaType: 'movie')},
    );

    final remaining =
        await (db.select(db.tmdbAccountSyncItemsTable)).get();
    expect(remaining.map((r) => r.tmdbId), unorderedEquals([1, 2]),
        reason: 'kept (2), and linked (1); orphan (3) pruned');
  });
}
