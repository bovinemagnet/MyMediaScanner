import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
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
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
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
    googleBooksApi: GoogleBooksApi(
        DioFactory.create(baseUrl: ApiConstants.googleBooksBaseUrl)),
    openLibraryApi: OpenLibraryApi(),
    upcitemdbApi: upcKey != null
        ? UpcitemdbApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.upcItemDbBaseUrl,
            apiKeyParam: 'user_key',
            apiKey: upcKey,
          ))
        : null,
  );
});

final syncRepositoryProvider = Provider<ISyncRepository?>((ref) {
  final config = ref.watch(postgresConfigProvider).valueOrNull;
  if (config == null) return null;

  return SyncRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
    syncClient: PostgresSyncClient(config: config),
  );
});
