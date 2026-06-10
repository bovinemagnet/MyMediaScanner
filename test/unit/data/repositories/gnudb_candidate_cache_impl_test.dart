import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/gnudb_candidate_cache_impl.dart';
import 'package:mymediascanner/domain/entities/gnudb_disc.dart';

void main() {
  late AppDatabase db;
  late BarcodeCacheDao dao;
  late GnudbCandidateCacheImpl cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = BarcodeCacheDao(db);
    cache = GnudbCandidateCacheImpl(dao);
  });

  tearDown(() async {
    await db.close();
  });

  const candidate = GnudbCandidate(
    discId: '08025603',
    category: 'rock',
    disc: GnudbDisc(
      discId: '08025603',
      artist: 'Example Artist',
      albumTitle: 'Example Album',
      year: 2023,
      genre: 'Rock',
      trackTitles: ['One', 'Two', 'Three'],
      extendedAlbum: 'Notes',
    ),
  );

  test('read returns null when there is no entry', () async {
    expect(await cache.read('0c025803'), isNull);
  });

  test('write/read round-trips candidates under a gnudb-prefixed key',
      () async {
    await cache.write('0c025803', const [candidate]);

    final raw = await dao.getByBarcode('gnudb:0c025803');
    expect(raw, isNotNull);
    expect(raw!.sourceApi, 'gnudb');

    final restored = await cache.read('0c025803');
    expect(restored, isNotNull);
    expect(restored, hasLength(1));
    final c = restored!.single;
    expect(c.discId, '08025603');
    expect(c.category, 'rock');
    expect(c.disc.artist, 'Example Artist');
    expect(c.disc.albumTitle, 'Example Album');
    expect(c.disc.year, 2023);
    expect(c.disc.genre, 'Rock');
    expect(c.disc.trackTitles, ['One', 'Two', 'Three']);
    expect(c.disc.extendedAlbum, 'Notes');
  });

  test('read returns null for a stale entry', () async {
    await dao.upsert(BarcodeCacheTableCompanion(
      barcode: const Value('gnudb:0c025803'),
      mediaTypeHint: const Value('music'),
      responseJson: const Value('{"candidates":[]}'),
      sourceApi: const Value('gnudb'),
      // 30 days old — well past the cache duration.
      cachedAt: Value(DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch),
    ));

    expect(await cache.read('0c025803'), isNull);
  });

  test('read returns null for an undecodable entry', () async {
    await dao.upsert(BarcodeCacheTableCompanion(
      barcode: const Value('gnudb:0c025803'),
      mediaTypeHint: const Value('music'),
      responseJson: const Value('not json'),
      sourceApi: const Value('gnudb'),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    expect(await cache.read('0c025803'), isNull);
  });
}
