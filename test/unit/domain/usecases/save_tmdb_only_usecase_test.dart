import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/tmdb_account_sync_dao.dart';
import 'package:mymediascanner/data/repositories/tmdb_account_sync_repository_impl.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/usecases/save_tmdb_only_usecase.dart';

class _MockApi extends Mock implements TmdbAccountApi {}
class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AppDatabase db;
  late TmdbAccountSyncDao dao;
  late TmdbAccountSyncRepositoryImpl repo;
  late SaveTmdbOnlyUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.tmdbAccountSyncDao;
    repo = TmdbAccountSyncRepositoryImpl(
      api: _MockApi(),
      dao: dao,
      mediaItemsDao: db.mediaItemsDao,
      storage: _MockStorage(),
    );
    useCase = SaveTmdbOnlyUseCase(repo);
  });

  tearDown(() async => db.close());

  test('creates a bridge row with no media_item_id and no flags', () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/poster.jpg',
      barcode: '5051892002172',
    );

    final row = await dao.getByTmdbId(550, 'movie');
    expect(row, isNotNull);
    expect(row!.mediaItemId, isNull);
    expect(row.watchlist, isFalse);
    expect(row.favorite, isFalse);
    expect(row.tmdbRating, isNull);
    expect(row.titleSnapshot, 'Fight Club');
    expect(row.posterPathSnapshot, '/poster.jpg');
    expect(row.barcode, '5051892002172');
    expect(row.localDirty, isFalse);
  });

  test('appears in TmdbBridgeBucket.saved', () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: null,
      barcode: null,
    );
    final saved = await dao.listByBucket(TmdbBridgeBucket.saved);
    expect(saved.length, 1);
    expect(saved.first.tmdbId, 550);
  });

  test('idempotent: re-saving same tmdbId merges into the existing row',
      () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/p1.jpg',
      barcode: null,
    );
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/p2.jpg',
      barcode: null,
    );

    final all = await (db.select(db.tmdbAccountSyncItemsTable)).get();
    expect(all.length, 1);
    expect(all.first.posterPathSnapshot, '/p2.jpg',
        reason: 'second call updates the snapshot');
  });

  test('throws on unsupported media type', () async {
    expect(
      () => useCase(
        tmdbId: 1,
        mediaType: 'music',
        title: 't',
        posterPath: null,
        barcode: null,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
