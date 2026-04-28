import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/repositories/tmdb_account_sync_repository_impl.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class _MockApi extends Mock implements TmdbAccountApi {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AppDatabase db;
  late _MockApi api;
  late _MockStorage storage;
  late TmdbAccountSyncRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = _MockApi();
    storage = _MockStorage();
    when(() => storage.read(key: 'tmdb.session_id'))
        .thenAnswer((_) async => 'sess-123');
    when(() => storage.read(key: 'tmdb.account_id'))
        .thenAnswer((_) async => '42');
    when(() => storage.read(key: 'tmdb.account_username'))
        .thenAnswer((_) async => 'paul');
    repo = TmdbAccountSyncRepositoryImpl(
      api: api,
      dao: db.tmdbAccountSyncDao,
      mediaItemsDao: db.mediaItemsDao,
      storage: storage,
    );
  });

  tearDown(() async => db.close());

  test('importAll pulls each selected bucket and upserts bridge rows',
      () async {
    when(() => api.getWatchlistMovies(42, 'sess-123', page: any(named: 'page')))
        .thenAnswer((_) async => const TmdbAccountListPageDto(
              page: 1,
              totalPages: 1,
              totalResults: 1,
              results: [
                TmdbAccountListItemDto(
                    id: 100, title: 'Watchlisted', posterPath: '/p.jpg'),
              ],
            ));

    final summary = await repo.importAll(
      selectedBuckets: {
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.watchlist, mediaType: 'movie'),
      },
    );

    expect(summary.pulled, 1);
    expect(summary.failed, 0);

    final stored = await db.tmdbAccountSyncDao.getByTmdbId(100, 'movie');
    expect(stored?.watchlist, isTrue);
    expect(stored?.titleSnapshot, 'Watchlisted');
  });

  test('importAll on 401 clears session and reports lastError', () async {
    when(() => api.getWatchlistMovies(any(), any(), page: any(named: 'page')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 401,
      ),
    ));
    when(() => storage.delete(key: 'tmdb.session_id'))
        .thenAnswer((_) async {});

    final summary = await repo.importAll(selectedBuckets: {
      const TmdbBucketSelection(
          bucket: TmdbBridgeBucket.watchlist, mediaType: 'movie'),
    });

    expect(summary.lastError, 'Session expired');
    verify(() => storage.delete(key: 'tmdb.session_id')).called(1);
  });

  test('convertBridgeToLocalItem creates a media_items row and links bridge',
      () async {
    // Seed a bridge row.
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('bridge-1'),
        tmdbId: const Value(550),
        tmdbMediaType: const Value('movie'),
        titleSnapshot: const Value('Fight Club'),
        posterPathSnapshot: const Value('/poster.jpg'),
        tmdbRating: const Value(8.0),
        watchlist: const Value(false),
        favorite: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final mediaItemId = await repo.convertBridgeToLocalItem('bridge-1');

    expect(mediaItemId, isNotEmpty);

    final row = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(row?.mediaItemId, mediaItemId);

    final mediaItem = await db.mediaItemsDao.getById(mediaItemId);
    expect(mediaItem, isNotNull);
    expect(mediaItem!.title, 'Fight Club');
    expect(mediaItem.userRating, 4.0,
        reason: 'TMDB 8.0 → local 4.0 (halved)');
  });
}
