import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_status_response_dto.dart';
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

  test('pushOne with new rating posts to TMDB then clears dirty', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('br-1'),
        tmdbId: const Value(550),
        tmdbMediaType: const Value('movie'),
        tmdbRating: const Value(9.0), // new desired rating
        localRatingSnapshot: const Value(8.0), // last pushed
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    when(() => api.addMovieRating(550, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setWatchlist(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setFavorite(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));

    final result = await repo.pushOne(tmdbId: 550, mediaType: 'movie');
    expect(result.success, isTrue);

    final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(after?.localDirty, isFalse);
    expect(after?.lastPushedAt, isNotNull);
    expect(after?.localRatingSnapshot, 9.0);
    verify(() => api.addMovieRating(550, 'sess-123', {'value': 9.0})).called(1);
  });

  test('pushOne dirty with no rating change still pushes watchlist and favourite',
      () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('br-2'),
        tmdbId: const Value(99),
        tmdbMediaType: const Value('movie'),
        tmdbRating: const Value(7.0),
        localRatingSnapshot: const Value(7.0), // same — no rating delta
        watchlist: const Value(true),
        favorite: const Value(false),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    when(() => api.setWatchlist(42, 'sess-123', any())).thenAnswer((_) async =>
        const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setFavorite(42, 'sess-123', any())).thenAnswer((_) async =>
        const TmdbStatusResponseDto(statusCode: 1, success: true));

    final result = await repo.pushOne(tmdbId: 99, mediaType: 'movie');
    expect(result.success, isTrue);
    verifyNever(() => api.addMovieRating(any(), any(), any()));
    verify(() => api.setWatchlist(42, 'sess-123', {
          'media_type': 'movie',
          'media_id': 99,
          'watchlist': true,
        })).called(1);
  });

  test('pushOne with API error keeps row dirty and stores last_error',
      () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('br-1'),
        tmdbId: const Value(550),
        tmdbMediaType: const Value('movie'),
        tmdbRating: const Value(7.0),
        localRatingSnapshot: const Value(8.0),
        localDirty: const Value(true),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    when(() => api.addMovieRating(550, 'sess-123', any()))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
      ),
    ));

    final result = await repo.pushOne(tmdbId: 550, mediaType: 'movie');
    expect(result.success, isFalse);
    expect(result.error, isNotNull);

    final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(after?.localDirty, isTrue, reason: 'stays dirty for retry');
    expect(after?.lastError, isNotNull);
  });

  test('toggleWatchlist updates bridge + pushes', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('br-1'),
        tmdbId: const Value(100),
        tmdbMediaType: const Value('movie'),
        watchlist: const Value(false),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    when(() => api.setWatchlist(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setFavorite(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));

    final result =
        await repo.toggleWatchlist(tmdbId: 100, mediaType: 'movie', value: true);
    expect(result.success, isTrue);

    final after = await db.tmdbAccountSyncDao.getByTmdbId(100, 'movie');
    expect(after?.watchlist, isTrue);
    expect(after?.localDirty, isFalse);
  });

  test('updateRating with null clears the TMDB rating', () async {
    await db.tmdbAccountSyncDao.upsertByTmdbId(
      TmdbAccountSyncItemsTableCompanion(
        id: const Value('br-1'),
        tmdbId: const Value(100),
        tmdbMediaType: const Value('movie'),
        tmdbRating: const Value(8.0),
        localRatingSnapshot: const Value(8.0),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    when(() => api.removeMovieRating(100, 'sess-123'))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 13, success: true));
    when(() => api.setWatchlist(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setFavorite(42, 'sess-123', any()))
        .thenAnswer((_) async =>
            const TmdbStatusResponseDto(statusCode: 1, success: true));

    final result = await repo.updateRating(
        tmdbId: 100, mediaType: 'movie', localRating: null);
    expect(result.success, isTrue);
    verify(() => api.removeMovieRating(100, 'sess-123')).called(1);
  });

  test('ensureMyMediaScannerListId reuses existing list found by name',
      () async {
    // No cached list ID.
    when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
        .thenAnswer((_) async => null);
    when(() => storage.write(
            key: 'tmdb.mymediascanner_list_id', value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => api.getAccountLists(42, 'sess-123', page: any(named: 'page')))
        .thenAnswer((_) async => const TmdbAccountListsPageDto(
              page: 1,
              totalPages: 1,
              totalResults: 1,
              results: [
                TmdbAccountListSummaryDto(id: 999, name: 'MyMediaScanner'),
              ],
            ));

    final id = await repo.ensureMyMediaScannerListId();
    expect(id, 999);
    verifyNever(() => api.createList(any(), any()));
  });

  test('ensureMyMediaScannerListId creates list when none exists', () async {
    when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
        .thenAnswer((_) async => null);
    when(() => storage.write(
            key: 'tmdb.mymediascanner_list_id', value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => api.getAccountLists(42, 'sess-123', page: any(named: 'page')))
        .thenAnswer((_) async => const TmdbAccountListsPageDto(
              page: 1, totalPages: 1, totalResults: 0, results: [],
            ));
    when(() => api.createList('sess-123', any())).thenAnswer((_) async =>
        const TmdbListCreateResponseDto(success: true, listId: 1234));

    final id = await repo.ensureMyMediaScannerListId();
    expect(id, 1234);
    verify(() => api.createList('sess-123', any())).called(1);
  });

  test('ensureMyMediaScannerListId returns cached id without API calls',
      () async {
    when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
        .thenAnswer((_) async => '777');

    final id = await repo.ensureMyMediaScannerListId();
    expect(id, 777);
    verifyNever(() => api.getAccountLists(any(), any(), page: any(named: 'page')));
    verifyNever(() => api.createList(any(), any()));
  });
}
