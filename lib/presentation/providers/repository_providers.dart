import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/theaudiodb_api.dart';
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
  );
});

final metadataRepositoryProvider = Provider<IMetadataRepository>((ref) {
  final apiKeys = ref.watch(apiKeysProvider).value ?? {};

  final tmdbKey = apiKeys['tmdb'];
  final discogsKey = apiKeys['discogs'];
  final upcKey = apiKeys['upcitemdb'];
  final googleBooksKey = apiKeys['google_books'];
  final tvdbKey = apiKeys['tvdb'];
  final fanartKey = apiKeys['fanart'];

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
  );
});

final borrowerRepositoryProvider = Provider<IBorrowerRepository>((ref) {
  return BorrowerRepositoryImpl(
    borrowersDao: ref.watch(borrowersDaoProvider),
  );
});

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  return LoanRepositoryImpl(
    loansDao: ref.watch(loansDaoProvider),
  );
});

final ripLibraryRepositoryProvider = Provider<IRipLibraryRepository>((ref) {
  return RipLibraryRepositoryImpl(
    ripLibraryDao: ref.watch(ripLibraryDaoProvider),
  );
});

final syncRepositoryProvider = Provider<ISyncRepository?>((ref) {
  final config = ref.watch(postgresConfigProvider).value;
  if (config == null) return null;

  return SyncRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
    syncClient: PostgresSyncClient(config: config),
  );
});
