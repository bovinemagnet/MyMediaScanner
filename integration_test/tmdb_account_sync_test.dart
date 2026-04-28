// Integration test for TMDB account-sync connect → import flow.
//
// Exercises the full auth + bucket-import path against a mocked
// TmdbAccountApi and a real in-memory Drift database, verifying that bridge
// rows land correctly.  The test takes the API-driven path (no UI taps) to
// remain stable as the settings widget tree evolves.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_request_token_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_session_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_status_response_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/data/repositories/tmdb_account_sync_repository_impl.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class _MockApi extends Mock implements TmdbAccountApi {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  testWidgets('connect → import populates bridge buckets', (tester) async {
    final api = _MockApi();
    final storage = _MockStorage();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    // In-memory store so storage.write / storage.read / storage.delete
    // all reflect the same state within the test.
    final stored = <String, String>{};
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((inv) async {
      stored[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((inv) async => stored[inv.namedArguments[#key] as String]);
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((inv) async => stored.remove(inv.namedArguments[#key]));
    when(() => storage.readAll()).thenAnswer((_) async => {});

    // ── Connect-flow mocks ─────────────────────────────────────────────
    when(() => api.createRequestToken()).thenAnswer((_) async =>
        const TmdbRequestTokenDto(success: true, requestToken: 'rqt-1'));

    when(() => api.createSession(any())).thenAnswer((_) async =>
        const TmdbSessionDto(success: true, sessionId: 'sess-1'));

    when(() => api.getAccount('sess-1')).thenAnswer((_) async =>
        const TmdbAccountDto(id: 1, username: 'paul'));

    // ── Bucket-pull mocks ──────────────────────────────────────────────
    // Watchlist movies: one result — used to assert the bridge row lands.
    when(() => api.getWatchlistMovies(1, 'sess-1', page: any(named: 'page')))
        .thenAnswer((_) async => const TmdbAccountListPageDto(
              page: 1,
              totalPages: 1,
              totalResults: 1,
              results: [
                TmdbAccountListItemDto(
                  id: 42,
                  title: 'Hitchhikers',
                  posterPath: '/p.jpg',
                ),
              ],
            ));

    // All other buckets return empty pages.
    const emptyPage = TmdbAccountListPageDto(
        page: 1, totalPages: 1, totalResults: 0, results: []);
    when(() => api.getWatchlistTv(any(), any(), page: any(named: 'page')))
        .thenAnswer((_) async => emptyPage);
    when(() => api.getRatedMovies(any(), any(), page: any(named: 'page')))
        .thenAnswer((_) async => emptyPage);
    when(() => api.getRatedTv(any(), any(), page: any(named: 'page')))
        .thenAnswer((_) async => emptyPage);
    when(() => api.getFavoriteMovies(any(), any(), page: any(named: 'page')))
        .thenAnswer((_) async => emptyPage);
    when(() => api.getFavoriteTv(any(), any(), page: any(named: 'page')))
        .thenAnswer((_) async => emptyPage);

    // ── Repository under test ──────────────────────────────────────────
    final repo = TmdbAccountSyncRepositoryImpl(
      api: api,
      dao: db.tmdbAccountSyncDao,
      mediaItemsDao: db.mediaItemsDao,
      storage: storage,
    );

    // Step 1 — start the OAuth-style connect flow.
    final start = await repo.startConnect();
    expect(start.requestToken, 'rqt-1');
    expect(start.approvalUrl.host, 'www.themoviedb.org');

    // Step 2 — finish connect: exchange token → session, fetch account.
    final connectState = await repo.finishConnect(start.requestToken);
    expect(connectState, isA<TmdbConnected>());
    final connected = connectState as TmdbConnected;
    expect(connected.username, 'paul');
    expect(connected.accountId, 1);

    // Credentials should now be persisted in secure storage.
    expect(stored['tmdb.session_id'], 'sess-1');
    expect(stored['tmdb.account_id'], '1');
    expect(stored['tmdb.account_username'], 'paul');

    // Step 3 — import all six buckets.
    final summary = await repo.importAll(
      selectedBuckets: {
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
      },
    );
    expect(summary.pulled, 1);
    expect(summary.failed, 0);
    expect(summary.lastError, isNull);

    // Step 4 — verify the watchlist bridge row was persisted correctly.
    final watchlistRows =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.watchlist);
    expect(watchlistRows.length, 1);
    expect(watchlistRows.first.tmdbId, 42);
    expect(watchlistRows.first.titleSnapshot, 'Hitchhikers');
    expect(watchlistRows.first.watchlist, isTrue);
    expect(watchlistRows.first.posterPathSnapshot, '/p.jpg');

    // No rated or favourite rows should exist.
    final ratedRows =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.rated);
    expect(ratedRows, isEmpty);
    final favouriteRows =
        await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.favourite);
    expect(favouriteRows, isEmpty);
  });

  testWidgets('currentState reflects connected creds from storage',
      (tester) async {
    final api = _MockApi();
    final storage = _MockStorage();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    // Pre-seed storage with valid creds.
    when(() => storage.read(key: 'tmdb.session_id'))
        .thenAnswer((_) async => 'sess-existing');
    when(() => storage.read(key: 'tmdb.account_id'))
        .thenAnswer((_) async => '7');
    when(() => storage.read(key: 'tmdb.account_username'))
        .thenAnswer((_) async => 'jane');

    final repo = TmdbAccountSyncRepositoryImpl(
      api: api,
      dao: db.tmdbAccountSyncDao,
      mediaItemsDao: db.mediaItemsDao,
      storage: storage,
    );

    final state = await repo.currentState();
    expect(state, isA<TmdbConnected>());
    final connected = state as TmdbConnected;
    expect(connected.accountId, 7);
    expect(connected.username, 'jane');
  });

  testWidgets('currentState returns disconnected when no creds stored',
      (tester) async {
    final api = _MockApi();
    final storage = _MockStorage();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);

    final repo = TmdbAccountSyncRepositoryImpl(
      api: api,
      dao: db.tmdbAccountSyncDao,
      mediaItemsDao: db.mediaItemsDao,
      storage: storage,
    );

    final state = await repo.currentState();
    expect(state, isA<TmdbDisconnected>());
  });

  testWidgets('push rating end-to-end', (tester) async {
    final api = _MockApi();
    final storage = _MockStorage();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    // Seed connected state.
    final stored = <String, String>{};
    stored['tmdb.session_id'] = 'sess-1';
    stored['tmdb.account_id'] = '1';
    stored['tmdb.account_username'] = 'paul';
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((inv) async => stored[inv.namedArguments[#key]]);
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((inv) async {
      stored[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((inv) async {
      stored.remove(inv.namedArguments[#key]);
    });

    // Mock the rating push and watchlist/favourite re-push endpoints.
    when(() => api.addMovieRating(550, 'sess-1', any())).thenAnswer((_) async =>
        const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setWatchlist(1, 'sess-1', any())).thenAnswer((_) async =>
        const TmdbStatusResponseDto(statusCode: 1, success: true));
    when(() => api.setFavorite(1, 'sess-1', any())).thenAnswer((_) async =>
        const TmdbStatusResponseDto(statusCode: 1, success: true));

    final repo = TmdbAccountSyncRepositoryImpl(
      api: api,
      dao: db.tmdbAccountSyncDao,
      mediaItemsDao: db.mediaItemsDao,
      storage: storage,
    );

    // Update local rating to 4.0 (= TMDB 8.0). Expect a push to fire.
    final result = await repo.updateRating(
        tmdbId: 550, mediaType: 'movie', localRating: 4.0);

    expect(result.success, isTrue);
    verify(() => api.addMovieRating(550, 'sess-1', {'value': 8.0})).called(1);

    final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
    expect(after?.localDirty, isFalse);
    expect(after?.localRatingSnapshot, 8.0);
  });
}
