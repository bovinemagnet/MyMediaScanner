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
    bool? watchlist,
    bool? favorite,
    double? rating,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return TmdbAccountSyncItemsTableCompanion(
      id: Value(id),
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(mediaType),
      watchlist: watchlist == null ? const Value.absent() : Value(watchlist),
      favorite: favorite == null ? const Value.absent() : Value(favorite),
      tmdbRating: rating == null ? const Value.absent() : Value(rating),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  test('schemaVersion is 20', () {
    expect(db.schemaVersion, 20);
  });

  test('upsertByTmdbId inserts a new row when none exists', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 550, watchlist: true),
    );

    final found =
        await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(found, isNotNull);
    expect(found!.watchlist, isTrue);
  });

  test('upsertByTmdbId merges when row exists', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 550, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 550, favorite: true, rating: 8.0),
    );

    final found =
        await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(found, isNotNull);
    expect(found!.watchlist, isTrue, reason: 'preserved from first upsert');
    expect(found.favorite, isTrue, reason: 'set by second upsert');
    expect(found.tmdbRating, 8.0);
  });

  test('listByBucket returns only matching bucket rows', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 1, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 2, favorite: true),
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
      row(id: 'a', tmdbId: 1, watchlist: true),
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
      row(id: 'a', tmdbId: 1, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 2, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'c', tmdbId: 3, watchlist: true),
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

  test('pruneOrphans preserves rows with localDirty == true', () async {
    // Three orphan rows; one is dirty.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'a', tmdbId: 1, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      row(id: 'b', tmdbId: 2, watchlist: true),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('c'),
        tmdbId: const Value(3),
        tmdbMediaType: const Value('movie'),
        watchlist: const Value(true),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Empty keepKeys → would normally delete every orphan, but localDirty guard
    // protects row 'c'.
    await db.tmdbAccountSyncDao.pruneOrphans(keepKeys: const {});

    final remaining = await (db.select(db.tmdbAccountSyncItemsTable)).get();
    expect(remaining.map((r) => r.tmdbId), [3],
        reason: 'localDirty=true row survives a full prune');
  });

  test('countDirtyRows counts only localDirty rows', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 1));
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('b'),
        tmdbId: const Value(2),
        tmdbMediaType: const Value('movie'),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('c'),
        tmdbId: const Value(3),
        tmdbMediaType: const Value('movie'),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    expect(await db.tmdbAccountSyncDao.countDirtyRows(), 2);
  });

  test('listDirty returns only localDirty rows', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 1));
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('b'),
        tmdbId: const Value(2),
        tmdbMediaType: const Value('movie'),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final dirty = await db.tmdbAccountSyncDao.listDirty();
    expect(dirty.map((r) => r.tmdbId), [2]);
  });

  test('markDirty sets localDirty=true and bumps updatedAt', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 5));
    final before = (await db.tmdbAccountSyncDao.getByTmdbId(5, 'movie'))!;
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await db.tmdbAccountSyncDao.markDirty(tmdbId: 5, mediaType: 'movie');
    final after = (await db.tmdbAccountSyncDao.getByTmdbId(5, 'movie'))!;
    expect(after.localDirty, isTrue);
    expect(after.updatedAt, greaterThan(before.updatedAt));
  });

  test('clearDirty sets localDirty=false, lastPushedAt=now, lastError=null',
      () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('a'),
        tmdbId: const Value(7),
        tmdbMediaType: const Value('movie'),
        localDirty: const Value(true),
        lastError: const Value('previous error'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    await db.tmdbAccountSyncDao.clearDirty(
      tmdbId: 7,
      mediaType: 'movie',
      pushedRating: 4.0,
    );

    final r = (await db.tmdbAccountSyncDao.getByTmdbId(7, 'movie'))!;
    expect(r.localDirty, isFalse);
    expect(r.lastError, isNull);
    expect(r.lastPushedAt, isNotNull);
    expect(r.localRatingSnapshot, 4.0);
  });

  test('listByBucket(saved) returns orphan bridge rows only', () async {
    // Orphan: no flags, no rating, no media-item link.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('orphan'),
        tmdbId: const Value(1),
        tmdbMediaType: const Value('movie'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    // Watchlisted — should NOT appear in saved bucket.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('wl'),
        tmdbId: const Value(2),
        tmdbMediaType: const Value('movie'),
        watchlist: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    // Rated — should NOT appear in saved bucket.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('rt'),
        tmdbId: const Value(3),
        tmdbMediaType: const Value('movie'),
        tmdbRating: const Value(8.0),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    // Favourited — should NOT appear in saved bucket.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('fv'),
        tmdbId: const Value(4),
        tmdbMediaType: const Value('movie'),
        favorite: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    // Linked to local item — should NOT appear in any bucket view.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('linked'),
        tmdbId: const Value(5),
        tmdbMediaType: const Value('movie'),
        mediaItemId: const Value('mi-1'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final saved = await db.tmdbAccountSyncDao
        .listByBucket(TmdbBridgeBucket.saved);
    expect(saved.map((r) => r.tmdbId), [1]);
  });

  test('listByBucket(saved) excludes a row that gains a flag', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('a'),
        tmdbId: const Value(1),
        tmdbMediaType: const Value('movie'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    expect(
        (await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.saved))
            .length,
        1);

    // Flip watchlist on.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      const TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(1),
        tmdbMediaType: Value('movie'),
        watchlist: Value(true),
      ),
    );
    expect(
        (await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.saved)),
        isEmpty);
    expect(
        (await db.tmdbAccountSyncDao
                .listByBucket(TmdbBridgeBucket.watchlist))
            .length,
        1);
  });
}
