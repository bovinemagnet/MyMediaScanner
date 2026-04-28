import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/local/dao/tmdb_account_sync_dao.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_rate_limit_interceptor.dart';
import 'package:mymediascanner/data/repositories/tmdb_account_sync_repository_impl.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';
import 'package:mymediascanner/domain/usecases/convert_bridge_to_local_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/disconnect_tmdb_account_usecase.dart';
import 'package:mymediascanner/domain/usecases/enrich_scan_with_tmdb_account_usecase.dart';
import 'package:mymediascanner/domain/usecases/import_tmdb_account_usecase.dart';
import 'package:mymediascanner/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/push_tmdb_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/resolve_tmdb_conflict_usecase.dart';
import 'package:mymediascanner/domain/usecases/sync_tmdb_account_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_favorite_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_watchlist_usecase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_token_manager.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/theaudiodb_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/musicbrainz_api.dart';
import 'package:mymediascanner/data/remote/api/tvdb/tvdb_api.dart';
import 'package:mymediascanner/data/remote/api/tvdb/tvdb_token_manager.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/borrower_repository_impl.dart';
import 'package:mymediascanner/data/repositories/loan_repository_impl.dart';
import 'package:mymediascanner/data/repositories/rip_library_repository_impl.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

final mediaItemRepositoryProvider = Provider<IMediaItemRepository>((ref) {
  return MediaItemRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final tagRepositoryProvider = Provider<ITagRepository>((ref) {
  return TagRepositoryImpl(
    tagsDao: ref.watch(tagsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final shelfRepositoryProvider = Provider<IShelfRepository>((ref) {
  return ShelfRepositoryImpl(
    shelvesDao: ref.watch(shelvesDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final metadataRepositoryProvider = Provider<IMetadataRepository>((ref) {
  final apiKeys = ref.watch(apiKeysProvider).value ?? {};

  // Normalise so that an empty/whitespace key is treated as unconfigured —
  // otherwise a cleared field stored as '' would still spin up an
  // authenticated client with empty credentials and trigger 401 storms.
  String? key(String name) {
    final value = apiKeys[name]?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  final tmdbKey = key('tmdb');
  final discogsKey = key('discogs');
  final upcKey = key('upcitemdb');
  final googleBooksKey = key('google_books');
  final tvdbKey = key('tvdb');
  final fanartKey = key('fanart');
  final twitchClientId = key('twitch_client_id');
  final twitchClientSecret = key('twitch_client_secret');

  final igdbApi = (twitchClientId != null && twitchClientSecret != null)
      ? IgdbApi(
          tokenManager: IgdbTokenManager(
            clientId: twitchClientId,
            clientSecret: twitchClientSecret,
          ),
        )
      : null;

  return MetadataRepositoryImpl(
    cacheDao: ref.watch(barcodeCacheDaoProvider),
    tmdbApi: tmdbKey != null
        ? TmdbApi(DioFactory.createWithBearerToken(
            baseUrl: ApiConstants.tmdbBaseUrl,
            token: tmdbKey,
          ))
        : null,
    discogsApi: discogsKey != null
        ? DiscogsApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.discogsBaseUrl,
            apiKeyParam: 'token',
            apiKey: discogsKey,
            defaultHeaders: {'User-Agent': 'MyMediaScanner/1.0'},
          ))
        : null,
    // MusicBrainz is always available (free, no API key needed)
    musicBrainzApi: MusicBrainzApi(),
    // Cover Art Archive is a sibling of MusicBrainz, also free.
    coverArtArchiveApi: CoverArtArchiveApi(),
    tvdbApi: tvdbKey != null
        ? TvdbApi(DioFactory.createWithDynamicBearerToken(
            baseUrl: ApiConstants.tvdbBaseUrl,
            tokenProvider:
                TvdbTokenManager(apiKey: tvdbKey).getToken,
          ))
        : null,
    googleBooksApi: GoogleBooksApi(googleBooksKey != null
        ? DioFactory.createWithApiKey(
            baseUrl: ApiConstants.googleBooksBaseUrl,
            apiKeyParam: 'key',
            apiKey: googleBooksKey,
          )
        : DioFactory.create(baseUrl: ApiConstants.googleBooksBaseUrl)),
    openLibraryApi: OpenLibraryApi(),
    upcitemdbApi: upcKey != null
        ? UpcitemdbApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.upcItemDbBaseUrl,
            apiKeyParam: 'user_key',
            apiKey: upcKey,
          ))
        : null,
    // TheAudioDB free tier is always available (key = "2")
    theAudioDbApi: TheAudioDbApi(),
    fanartApi: fanartKey != null
        ? FanartApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.fanartBaseUrl,
            apiKeyParam: 'api_key',
            apiKey: fanartKey,
          ))
        : null,
    igdbApi: igdbApi,
  );
});

final borrowerRepositoryProvider = Provider<IBorrowerRepository>((ref) {
  return BorrowerRepositoryImpl(
    borrowersDao: ref.watch(borrowersDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  return LoanRepositoryImpl(
    loansDao: ref.watch(loansDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});

final ripLibraryRepositoryProvider = Provider<IRipLibraryRepository>((ref) {
  return RipLibraryRepositoryImpl(
    ripLibraryDao: ref.watch(ripLibraryDaoProvider),
  );
});

/// Single long-lived [PostgresSyncClient] per Postgres configuration.
///
/// Both [syncRepositoryProvider] and connection-health pings read this
/// provider so they share one cached connection. Previously the health
/// notifier minted a fresh client per ping and `await close()`d it
/// immediately — defeating the connection cache and paying a TLS
/// handshake every minute.
final postgresSyncClientProvider =
    Provider<PostgresSyncClient?>((ref) {
  final config = ref.watch(postgresConfigProvider).value;
  if (config == null) return null;
  final client = PostgresSyncClient(config: config);
  ref.onDispose(() async => client.close());
  return client;
});

final syncRepositoryProvider = Provider<ISyncRepository?>((ref) {
  final client = ref.watch(postgresSyncClientProvider);
  if (client == null) return null;

  final repo = SyncRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
    syncClient: client,
  );

  ref.onDispose(() async => repo.dispose());

  return repo;
});

// ── TMDB account sync ────────────────────────────────────────────────────────

final tmdbAccountSyncDaoProvider = Provider<TmdbAccountSyncDao>((ref) {
  return ref.watch(databaseProvider).tmdbAccountSyncDao;
});

final tmdbAccountApiProvider = Provider<TmdbAccountApi?>((ref) {
  final apiKeys = ref.watch(apiKeysProvider).value ?? {};
  final tmdbKey = apiKeys['tmdb']?.trim();
  if (tmdbKey == null || tmdbKey.isEmpty) return null;

  final dio = DioFactory.create(
    baseUrl: ApiConstants.tmdbBaseUrl,
    defaultHeaders: {
      'Authorization': 'Bearer $tmdbKey',
      'Content-Type': 'application/json',
    },
  );
  final interceptor = TmdbAccountRateLimitInterceptor();
  dio.interceptors.add(interceptor);
  // Wire the interceptor's retry path back to this Dio so retries
  // share the same adapter (matches the attachDio hook added in Task 6).
  interceptor.attachDio(dio);
  return TmdbAccountApi(dio);
});

final tmdbAccountSyncRepositoryProvider =
    Provider<ITmdbAccountSyncRepository>((ref) {
  final api = ref.watch(tmdbAccountApiProvider);
  if (api == null) {
    throw StateError(
        'TMDB API key not configured — account sync unavailable');
  }
  return TmdbAccountSyncRepositoryImpl(
    api: api,
    dao: ref.watch(tmdbAccountSyncDaoProvider),
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final connectTmdbAccountUseCaseProvider =
    Provider<ConnectTmdbAccountUseCase>((ref) {
  return ConnectTmdbAccountUseCase(
    repo: ref.watch(tmdbAccountSyncRepositoryProvider),
    launchUrl: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
  );
});

final disconnectTmdbAccountUseCaseProvider =
    Provider<DisconnectTmdbAccountUseCase>((ref) {
  return DisconnectTmdbAccountUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final importTmdbAccountUseCaseProvider =
    Provider<ImportTmdbAccountUseCase>((ref) {
  return ImportTmdbAccountUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final syncTmdbAccountUseCaseProvider =
    Provider<SyncTmdbAccountUseCase>((ref) {
  return SyncTmdbAccountUseCase(ref.watch(tmdbAccountSyncRepositoryProvider));
});

final enrichScanWithTmdbAccountUseCaseProvider =
    Provider<EnrichScanWithTmdbAccountUseCase>((ref) {
  return EnrichScanWithTmdbAccountUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final convertBridgeToLocalItemUseCaseProvider =
    Provider<ConvertBridgeToLocalItemUseCase>((ref) {
  return ConvertBridgeToLocalItemUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final markTmdbWatchlistOwnedUseCaseProvider =
    Provider<MarkTmdbWatchlistOwnedUseCase>((ref) {
  return MarkTmdbWatchlistOwnedUseCase(
    convert: ref.watch(convertBridgeToLocalItemUseCaseProvider),
    toggleWatchlist: ref.watch(toggleTmdbWatchlistUseCaseProvider),
    mirror: ref.watch(mirrorOwnershipChangeUseCaseProvider),
  );
});

final mirrorOwnershipChangeUseCaseProvider =
    Provider<MirrorOwnershipChangeUseCase>((ref) {
  return MirrorOwnershipChangeUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final pushTmdbChangeUseCaseProvider =
    Provider<PushTmdbChangeUseCase>((ref) {
  return PushTmdbChangeUseCase(ref.watch(tmdbAccountSyncRepositoryProvider));
});

final resolveTmdbConflictUseCaseProvider =
    Provider<ResolveTmdbConflictUseCase>((ref) {
  return ResolveTmdbConflictUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final toggleTmdbFavoriteUseCaseProvider =
    Provider<ToggleTmdbFavoriteUseCase>((ref) {
  return ToggleTmdbFavoriteUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final toggleTmdbWatchlistUseCaseProvider =
    Provider<ToggleTmdbWatchlistUseCase>((ref) {
  return ToggleTmdbWatchlistUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});
