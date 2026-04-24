import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/api_circuit_breaker.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/models/fanart_images_dto.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/models/theaudiodb_album_dto.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/theaudiodb_api.dart';
import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';
import 'package:mymediascanner/data/remote/api/tvdb/tvdb_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/musicbrainz_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_search_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

class MockBarcodeCacheDao extends Mock implements BarcodeCacheDao {}

class MockDiscogsApi extends Mock implements DiscogsApi {}

class MockTmdbApi extends Mock implements TmdbApi {}

class MockGoogleBooksApi extends Mock implements GoogleBooksApi {}

class MockOpenLibraryApi extends Mock implements OpenLibraryApi {}

class MockUpcitemdbApi extends Mock implements UpcitemdbApi {}

class MockMusicBrainzApi extends Mock implements MusicBrainzApi {}

class MockTvdbApi extends Mock implements TvdbApi {}

class MockTheAudioDbApi extends Mock implements TheAudioDbApi {}

class MockFanartApi extends Mock implements FanartApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      BarcodeCacheTableCompanion(
        barcode: const Value(''),
        mediaTypeHint: const Value(null),
        responseJson: const Value('{}'),
        sourceApi: const Value(''),
        cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  });

  late MetadataRepositoryImpl repo;
  late MockBarcodeCacheDao mockCacheDao;
  late MockDiscogsApi mockDiscogsApi;

  setUp(() {
    mockCacheDao = MockBarcodeCacheDao();
    mockDiscogsApi = MockDiscogsApi();
    repo = MetadataRepositoryImpl(
      cacheDao: mockCacheDao,
      discogsApi: mockDiscogsApi,
    );
  });

  group('lookupBarcode — music with disambiguation', () {
    const barcode = '5099902894225';

    setUp(() {
      when(
        () => mockCacheDao.getByBarcode(barcode),
      ).thenAnswer((_) async => null);
    });

    test('returns multiMatch when Discogs returns 2+ results', () async {
      when(() => mockDiscogsApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const DiscogsSearchResponseDto(
          results: [
            DiscogsSearchResultDto(id: 1, title: 'Album A', year: '2000'),
            DiscogsSearchResultDto(id: 2, title: 'Album B', year: '2005'),
            DiscogsSearchResultDto(id: 3, title: 'Album C', year: '2010'),
          ],
        ),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, 3);
      expect(multi.candidates[0].sourceId, '1');
      expect(multi.candidates[1].sourceId, '2');
    });

    test('returns single when Discogs returns exactly 1 result', () async {
      const release = DiscogsReleaseDto(id: 1, title: 'The Album', year: 2000);

      when(() => mockDiscogsApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const DiscogsSearchResponseDto(
          results: [DiscogsSearchResultDto(id: 1, title: 'The Album')],
        ),
      );
      when(() => mockDiscogsApi.getRelease(1)).thenAnswer((_) async => release);
      when(() => mockCacheDao.upsert(any())).thenAnswer((_) async {});

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<SingleScanResult>());
    });

    test('limits candidates to maxCandidates', () async {
      final results = List.generate(
        10,
        (i) => DiscogsSearchResultDto(id: i, title: 'Album $i'),
      );

      when(
        () => mockDiscogsApi.searchByBarcode(barcode),
      ).thenAnswer((_) async => DiscogsSearchResponseDto(results: results));

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, AppConstants.maxCandidates);
    });
  });

  group('fetchCandidateDetail', () {
    test('fetches Discogs release detail for discogs candidate', () async {
      const release = DiscogsReleaseDto(
        id: 12345,
        title: 'Dark Side of the Moon',
        year: 1973,
        genres: ['Rock'],
      );

      when(
        () => mockDiscogsApi.getRelease(12345),
      ).thenAnswer((_) async => release);
      when(() => mockCacheDao.upsert(any())).thenAnswer((_) async {});

      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'discogs',
          sourceId: '12345',
          title: 'Dark Side of the Moon',
        ),
        '5099902894225',
        'ean13',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Dark Side of the Moon');
      expect(result.mediaType, MediaType.music);
    });

    test('fetches TMDB detail for tmdb candidate', () async {
      final mockTmdbApi = MockTmdbApi();
      final tmdbRepo = MetadataRepositoryImpl(
        cacheDao: mockCacheDao,
        tmdbApi: mockTmdbApi,
      );

      when(() => mockTmdbApi.searchMulti('Fight Club')).thenAnswer(
        (_) async => const TmdbSearchResponseDto(
          results: [
            TmdbSearchResultDto(
              id: 550,
              title: 'Fight Club',
              releaseDate: '1999-10-15',
              mediaType: 'movie',
              voteAverage: 8.4,
            ),
          ],
        ),
      );
      when(() => mockCacheDao.upsert(any())).thenAnswer((_) async {});

      final result = await tmdbRepo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'tmdb',
          sourceId: '550',
          title: 'Fight Club',
        ),
        '0123456789012',
        'ean13',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Fight Club');
      expect(result.mediaType, MediaType.film);
    });

    test('fetches Google Books detail for google_books candidate', () async {
      final mockGoogleBooksApi = MockGoogleBooksApi();
      final booksRepo = MetadataRepositoryImpl(
        cacheDao: mockCacheDao,
        googleBooksApi: mockGoogleBooksApi,
      );

      when(
        () => mockGoogleBooksApi.searchByIsbn('isbn:9780141036144'),
      ).thenAnswer(
        (_) async => const GoogleBooksSearchResponseDto(
          totalItems: 1,
          items: [
            GoogleBooksVolumeDto(
              id: 'abc123',
              volumeInfo: GoogleBooksVolumeInfoDto(
                title: '1984',
                authors: ['George Orwell'],
                publishedDate: '1949-06-08',
              ),
            ),
          ],
        ),
      );
      when(() => mockCacheDao.upsert(any())).thenAnswer((_) async {});

      final result = await booksRepo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'google_books',
          sourceId: 'abc123',
          title: '1984',
        ),
        '9780141036144',
        'isbn13',
      );

      expect(result, isNotNull);
      expect(result!.title, '1984');
      expect(result.mediaType, MediaType.book);
    });

    test('fetches UPC detail for upcitemdb candidate', () async {
      final mockUpcApi = MockUpcitemdbApi();
      final upcRepo = MetadataRepositoryImpl(
        cacheDao: mockCacheDao,
        upcitemdbApi: mockUpcApi,
      );

      when(() => mockUpcApi.lookup('0123456789012')).thenAnswer(
        (_) async => const UpcSearchResponseDto(
          code: 'OK',
          total: 1,
          items: [
            UpcItemDto(
              ean: '0123456789012',
              title: 'Some DVD',
              category: 'DVD',
            ),
          ],
        ),
      );
      when(() => mockCacheDao.upsert(any())).thenAnswer((_) async {});

      final result = await upcRepo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'upcitemdb',
          sourceId: '0123456789012',
          title: 'Some DVD',
        ),
        '0123456789012',
        'ean13',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Some DVD');
    });

    test('returns null for unknown sourceApi', () async {
      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'unknown_api',
          sourceId: '1',
          title: 'Something',
        ),
        '0000000000000',
        'ean13',
      );

      expect(result, equals(null));
    });
  });

  group('Google Books 429 handling', () {
    const isbn = '9780141036144';
    late MockGoogleBooksApi mockGoogleBooksApi;
    late MockOpenLibraryApi mockOpenLibraryApi;
    late MockBarcodeCacheDao mockCache;
    late ApiCircuitBreaker breaker;

    setUp(() {
      mockGoogleBooksApi = MockGoogleBooksApi();
      mockOpenLibraryApi = MockOpenLibraryApi();
      mockCache = MockBarcodeCacheDao();
      breaker = ApiCircuitBreaker(cooldownDuration: const Duration(hours: 1));

      when(() => mockCache.getByBarcode(isbn)).thenAnswer((_) async => null);
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    DioException make429() {
      return DioException(
        requestOptions: RequestOptions(path: '/volumes'),
        response: Response(
          requestOptions: RequestOptions(path: '/volumes'),
          statusCode: 429,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    test('falls back to Open Library on 429', () async {
      final booksRepo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        googleBooksApi: mockGoogleBooksApi,
        openLibraryApi: mockOpenLibraryApi,
        googleBooksBreaker: breaker,
      );

      when(
        () => mockGoogleBooksApi.searchByIsbn('isbn:$isbn'),
      ).thenThrow(make429());
      when(() => mockOpenLibraryApi.getByIsbn(isbn)).thenAnswer(
        (_) async => const OpenLibraryBookDto(
          title: '1984',
          publishers: [OpenLibraryPublisherDto(name: 'Penguin')],
        ),
      );

      final result = await booksRepo.lookupBarcode(isbn);

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, '1984');
      expect(single.metadata.sourceApis, contains('open_library'));
    });

    test('trips circuit breaker on 429', () async {
      final booksRepo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        googleBooksApi: mockGoogleBooksApi,
        openLibraryApi: mockOpenLibraryApi,
        googleBooksBreaker: breaker,
      );

      when(
        () => mockGoogleBooksApi.searchByIsbn('isbn:$isbn'),
      ).thenThrow(make429());
      when(
        () => mockOpenLibraryApi.getByIsbn(isbn),
      ).thenAnswer((_) async => null);

      await booksRepo.lookupBarcode(isbn);

      expect(breaker.isOpen, isFalse);
    });

    test('skips Google Books when circuit breaker is tripped', () async {
      breaker.trip(); // Pre-trip the breaker

      final booksRepo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        googleBooksApi: mockGoogleBooksApi,
        openLibraryApi: mockOpenLibraryApi,
        googleBooksBreaker: breaker,
      );

      when(() => mockOpenLibraryApi.getByIsbn(isbn)).thenAnswer(
        (_) async => const OpenLibraryBookDto(
          title: '1984',
          publishers: [OpenLibraryPublisherDto(name: 'Penguin')],
        ),
      );

      final result = await booksRepo.lookupBarcode(isbn);

      // Google Books should NOT have been called
      verifyNever(() => mockGoogleBooksApi.searchByIsbn(any()));
      expect(result, isA<SingleScanResult>());
    });

    test(
      'resets circuit breaker on successful Google Books response',
      () async {
        breaker.trip();
        // Use zero cooldown so the breaker allows a probe
        final probableBreaker = ApiCircuitBreaker(
          cooldownDuration: Duration.zero,
        );
        probableBreaker.trip();

        final booksRepo = MetadataRepositoryImpl(
          cacheDao: mockCache,
          googleBooksApi: mockGoogleBooksApi,
          googleBooksBreaker: probableBreaker,
        );

        when(() => mockGoogleBooksApi.searchByIsbn('isbn:$isbn')).thenAnswer(
          (_) async => const GoogleBooksSearchResponseDto(
            totalItems: 1,
            items: [
              GoogleBooksVolumeDto(
                id: 'abc123',
                volumeInfo: GoogleBooksVolumeInfoDto(
                  title: '1984',
                  authors: ['George Orwell'],
                ),
              ),
            ],
          ),
        );

        await booksRepo.lookupBarcode(isbn);

        expect(probableBreaker.isOpen, isTrue);
      },
    );
  });

  group('lookupBarcode — music with MusicBrainz', () {
    const barcode = '602498746400';
    late MockMusicBrainzApi mockMbApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockMbApi = MockMusicBrainzApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.getByBarcode(barcode)).thenAnswer((_) async => null);
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    test('returns single when MusicBrainz finds 1 release', () async {
      final mbRepo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [
            MusicBrainzReleaseDto(
              id: 'mb-1',
              title: 'Vertigo 2005',
              date: '2005-11-11',
              artistCredit: [MusicBrainzArtistCreditDto(name: 'U2')],
            ),
          ],
        ),
      );

      final result = await mbRepo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Vertigo 2005');
      expect(single.metadata.sourceApis, ['musicbrainz']);
    });

    test('falls through to Discogs when MusicBrainz returns empty', () async {
      final mockDiscogs = MockDiscogsApi();
      final mbRepo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
        discogsApi: mockDiscogs,
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(count: 0, releases: []),
      );
      when(() => mockDiscogs.searchByBarcode(barcode)).thenAnswer(
        (_) async => const DiscogsSearchResponseDto(
          results: [DiscogsSearchResultDto(id: 1, title: 'Vertigo 2005')],
        ),
      );
      when(() => mockDiscogs.getRelease(1)).thenAnswer(
        (_) async => const DiscogsReleaseDto(id: 1, title: 'Vertigo 2005'),
      );

      final result = await mbRepo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.sourceApis, ['discogs']);
    });
  });

  group('searchByTitle', () {
    late MockTmdbApi mockTmdbApi;
    late MockMusicBrainzApi mockMbApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockTmdbApi = MockTmdbApi();
      mockMbApi = MockMusicBrainzApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    test('searches TMDB when typeHint is film', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tmdbApi: mockTmdbApi,
      );

      when(() => mockTmdbApi.searchMulti('Harry Potter')).thenAnswer(
        (_) async => const TmdbSearchResponseDto(
          results: [
            TmdbSearchResultDto(
              id: 671,
              title: 'Harry Potter and the Philosopher\'s Stone',
              releaseDate: '2001-11-16',
              mediaType: 'movie',
            ),
          ],
        ),
      );

      final result = await repo.searchByTitle(
        'Harry Potter',
        '9325336120538',
        'ean13',
        typeHint: MediaType.film,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(
        single.metadata.title,
        'Harry Potter and the Philosopher\'s Stone',
      );
    });

    test('searches MusicBrainz when typeHint is music', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
      );

      when(() => mockMbApi.searchByTitle('Vertigo')).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [MusicBrainzReleaseDto(id: 'mb-1', title: 'Vertigo 2005')],
        ),
      );

      final result = await repo.searchByTitle(
        'Vertigo',
        '602498746400',
        'ean13',
        typeHint: MediaType.music,
      );

      expect(result, isA<SingleScanResult>());
    });

    test('returns notFound when no APIs return results', () async {
      final repo = MetadataRepositoryImpl(cacheDao: mockCache);

      final result = await repo.searchByTitle(
        'Nonexistent Movie',
        '0000000000000',
        'ean13',
        typeHint: MediaType.film,
      );

      expect(result, isA<NotFoundScanResult>());
    });

    test('tries all sources when no typeHint given', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tmdbApi: mockTmdbApi,
        musicBrainzApi: mockMbApi,
      );

      // TMDB returns nothing
      when(
        () => mockTmdbApi.searchMulti('Test'),
      ).thenAnswer((_) async => const TmdbSearchResponseDto(results: []));

      // MusicBrainz finds a result
      when(() => mockMbApi.searchByTitle('Test')).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [MusicBrainzReleaseDto(id: 'mb-1', title: 'Test Album')],
        ),
      );

      final result = await repo.searchByTitle('Test', '0000000000000', 'ean13');

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.sourceApis, ['musicbrainz']);
    });
  });

  group('_enrichMetadata integration', () {
    const barcode = '602498746400';
    late MockMusicBrainzApi mockMbApi;
    late MockTheAudioDbApi mockAudioDbApi;
    late MockFanartApi mockFanartApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockMbApi = MockMusicBrainzApi();
      mockAudioDbApi = MockTheAudioDbApi();
      mockFanartApi = MockFanartApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.getByBarcode(any())).thenAnswer((_) async => null);
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    test('enriches music result with TheAudioDB critic score', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
        theAudioDbApi: mockAudioDbApi,
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [
            MusicBrainzReleaseDto(
              id: 'mb-1',
              title: 'Test Album',
              date: '2005-01-01',
              releaseGroup: MusicBrainzReleaseGroupDto(
                id: 'rg-1',
                title: 'Test Album',
              ),
            ),
          ],
        ),
      );

      when(() => mockAudioDbApi.getByMusicBrainzId('rg-1')).thenAnswer(
        (_) async => const TheAudioDbAlbumDto(
          idAlbum: '123',
          intScore: '8.5',
          strDescriptionEN: 'A great album',
        ),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.criticScore, 8.5);
      expect(single.metadata.criticSource, 'TheAudioDB');
      expect(single.metadata.description, 'A great album');
    });

    test('enriches film result with fanart.tv poster', () async {
      final mockTmdbApi = MockTmdbApi();
      final mockUpcApi = MockUpcitemdbApi();
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tmdbApi: mockTmdbApi,
        upcitemdbApi: mockUpcApi,
        fanartApi: mockFanartApi,
      );

      when(() => mockUpcApi.lookup(barcode)).thenAnswer(
        (_) async => const UpcSearchResponseDto(
          code: 'OK',
          total: 1,
          items: [UpcItemDto(title: 'Test Movie', category: 'DVD')],
        ),
      );
      when(() => mockTmdbApi.searchMulti('Test Movie')).thenAnswer(
        (_) async => const TmdbSearchResponseDto(
          results: [
            TmdbSearchResultDto(
              id: 550,
              title: 'Test Movie',
              mediaType: 'movie',
            ),
          ],
        ),
      );
      when(() => mockFanartApi.getMovieImages(550)).thenAnswer(
        (_) async => const FanartMovieImagesDto(
          movieposter: [
            FanartImageDto(url: 'https://fanart.tv/movies/550/poster.jpg'),
          ],
        ),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.film,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(
        single.metadata.coverUrl,
        'https://fanart.tv/movies/550/poster.jpg',
      );
    });

    test('enrichment failure does not break the result', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
        theAudioDbApi: mockAudioDbApi,
        fanartApi: mockFanartApi,
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [
            MusicBrainzReleaseDto(
              id: 'mb-1',
              title: 'Test Album',
              releaseGroup: MusicBrainzReleaseGroupDto(id: 'rg-1'),
            ),
          ],
        ),
      );

      // Both enrichment APIs throw
      when(
        () => mockAudioDbApi.getByMusicBrainzId('rg-1'),
      ).thenThrow(Exception('API down'));
      when(
        () => mockFanartApi.getAlbumImages('rg-1'),
      ).thenThrow(Exception('API down'));

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      // Should still return the result despite enrichment failure
      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Test Album');
    });
  });

  group('_lookupMusicBrainz multi-match', () {
    const barcode = '602498746400';
    late MockMusicBrainzApi mockMbApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockMbApi = MockMusicBrainzApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.getByBarcode(barcode)).thenAnswer((_) async => null);
    });

    test('returns multiMatch when MusicBrainz returns 2+ releases', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 3,
          releases: [
            MusicBrainzReleaseDto(id: 'r1', title: 'Album A'),
            MusicBrainzReleaseDto(id: 'r2', title: 'Album B'),
            MusicBrainzReleaseDto(id: 'r3', title: 'Album C'),
          ],
        ),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, 3);
      expect(multi.candidates[0].sourceApi, 'musicbrainz');
      expect(multi.candidates[0].sourceId, 'r1');
    });

    test('limits MusicBrainz candidates to maxCandidates', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        musicBrainzApi: mockMbApi,
      );

      final releases = List.generate(
        10,
        (i) => MusicBrainzReleaseDto(id: 'r$i', title: 'Album $i'),
      );

      when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async =>
            MusicBrainzSearchResponseDto(count: 10, releases: releases),
      );

      final result = await repo.lookupBarcode(
        barcode,
        typeHint: MediaType.music,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, AppConstants.maxCandidates);
    });
  });

  group('_searchTmdbByTitle edge cases', () {
    late MockTmdbApi mockTmdbApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockTmdbApi = MockTmdbApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    test('filters out person results from TMDB searchMulti', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tmdbApi: mockTmdbApi,
      );

      when(() => mockTmdbApi.searchMulti('Harry')).thenAnswer(
        (_) async => const TmdbSearchResponseDto(
          results: [
            TmdbSearchResultDto(
              id: 1,
              title: 'Harry Potter',
              mediaType: 'movie',
            ),
            TmdbSearchResultDto(
              id: 2,
              name: 'Harry Styles',
              mediaType: 'person',
            ),
            TmdbSearchResultDto(
              id: 3,
              title: 'Harry Brown',
              mediaType: 'movie',
            ),
          ],
        ),
      );

      final result = await repo.searchByTitle(
        'Harry',
        '000',
        'ean13',
        typeHint: MediaType.film,
      );

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      // Person result should be filtered out
      expect(multi.candidates.length, 2);
      expect(multi.candidates.every((c) => c.title != 'Harry Styles'), isTrue);
    });

    test('returns notFound when all TMDB results are person type', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tmdbApi: mockTmdbApi,
      );

      when(() => mockTmdbApi.searchMulti('John')).thenAnswer(
        (_) async => const TmdbSearchResponseDto(
          results: [
            TmdbSearchResultDto(id: 1, name: 'John Smith', mediaType: 'person'),
          ],
        ),
      );

      final result = await repo.searchByTitle(
        'John',
        '000',
        'ean13',
        typeHint: MediaType.film,
      );

      expect(result, isA<NotFoundScanResult>());
    });
  });

  group('_searchBookByTitle — Open Library fallback', () {
    late MockGoogleBooksApi mockGoogleBooksApi;
    late MockOpenLibraryApi mockOpenLibraryApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockGoogleBooksApi = MockGoogleBooksApi();
      mockOpenLibraryApi = MockOpenLibraryApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    DioException upstream5xx() => DioException(
      requestOptions: RequestOptions(path: '/books/v1/volumes'),
      response: Response(
        requestOptions: RequestOptions(path: '/books/v1/volumes'),
        statusCode: 503,
        statusMessage: 'Service Unavailable',
      ),
      type: DioExceptionType.badResponse,
    );

    test('falls back to Open Library when Google Books returns 503', () async {
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        googleBooksApi: mockGoogleBooksApi,
        openLibraryApi: mockOpenLibraryApi,
      );

      when(
        () => mockGoogleBooksApi.searchByIsbn('Gruffalo'),
      ).thenThrow(upstream5xx());
      when(() => mockOpenLibraryApi.searchByTitle('Gruffalo')).thenAnswer(
        (_) async => const OpenLibrarySearchResponseDto(
          numFound: 1,
          docs: [
            OpenLibrarySearchDocDto(
              key: '/works/OL27479W',
              title: 'The Gruffalo',
              authorName: ['Julia Donaldson', 'Axel Scheffler'],
              firstPublishYear: 1999,
              coverI: 8315657,
              isbn: ['9780333710937', '0333710932'],
              publisher: ['Macmillan'],
            ),
          ],
        ),
      );

      final result = await repo.searchByTitle(
        'Gruffalo',
        '0000',
        'ocr-lookup',
        typeHint: MediaType.book,
      );

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'The Gruffalo');
      expect(single.metadata.year, 1999);
      expect(single.metadata.coverUrl, contains('8315657'));
      expect(single.metadata.sourceApis, ['open_library']);
    });

    test(
      'returns multiMatch when Open Library returns 2+ docs after 503',
      () async {
        final repo = MetadataRepositoryImpl(
          cacheDao: mockCache,
          googleBooksApi: mockGoogleBooksApi,
          openLibraryApi: mockOpenLibraryApi,
        );

        when(
          () => mockGoogleBooksApi.searchByIsbn('Harry'),
        ).thenThrow(upstream5xx());
        when(() => mockOpenLibraryApi.searchByTitle('Harry')).thenAnswer(
          (_) async => const OpenLibrarySearchResponseDto(
            numFound: 2,
            docs: [
              OpenLibrarySearchDocDto(key: '/works/OL1', title: 'Harry One'),
              OpenLibrarySearchDocDto(key: '/works/OL2', title: 'Harry Two'),
            ],
          ),
        );

        final result = await repo.searchByTitle(
          'Harry',
          '0000',
          'ocr-lookup',
          typeHint: MediaType.book,
        );

        expect(result, isA<MultiMatchScanResult>());
        final multi = result as MultiMatchScanResult;
        expect(multi.candidates, hasLength(2));
        expect(
          multi.candidates.every((c) => c.sourceApi == 'open_library'),
          isTrue,
        );
      },
    );

    test(
      'returns notFound when both Google Books and Open Library fail',
      () async {
        final repo = MetadataRepositoryImpl(
          cacheDao: mockCache,
          googleBooksApi: mockGoogleBooksApi,
          openLibraryApi: mockOpenLibraryApi,
        );

        when(
          () => mockGoogleBooksApi.searchByIsbn('nothing'),
        ).thenThrow(upstream5xx());
        when(() => mockOpenLibraryApi.searchByTitle('nothing')).thenAnswer(
          (_) async =>
              const OpenLibrarySearchResponseDto(numFound: 0, docs: []),
        );

        final result = await repo.searchByTitle(
          'nothing',
          '0000',
          'ocr-lookup',
          typeHint: MediaType.book,
        );

        expect(result, isA<NotFoundScanResult>());
      },
    );
  });

  group('fetchCandidateDetail — TVDB', () {
    test('fetches TVDB series detail', () async {
      final mockTvdbApi = MockTvdbApi();
      final mockCache = MockBarcodeCacheDao();
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tvdbApi: mockTvdbApi,
      );

      when(() => mockTvdbApi.getSeries(73739)).thenAnswer(
        (_) async => const TvdbSeriesResponseDto(
          status: 'success',
          data: TvdbSeriesDto(
            id: 73739,
            name: 'Lost',
            year: '2004',
            overview: 'Plane crash survivors.',
          ),
        ),
      );
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});

      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'tvdb',
          sourceId: '73739',
          title: 'Lost',
        ),
        '123456',
        'ean13',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Lost');
      expect(result.mediaType, MediaType.tv);
      expect(result.sourceApis, ['tvdb']);
    });

    test('returns null when TVDB returns no data', () async {
      final mockTvdbApi = MockTvdbApi();
      final mockCache = MockBarcodeCacheDao();
      final repo = MetadataRepositoryImpl(
        cacheDao: mockCache,
        tvdbApi: mockTvdbApi,
      );

      when(() => mockTvdbApi.getSeries(99999)).thenAnswer(
        (_) async => const TvdbSeriesResponseDto(status: 'success', data: null),
      );

      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'tvdb',
          sourceId: '99999',
          title: 'Unknown',
        ),
        '123456',
        'ean13',
      );

      expect(result, equals(null));
    });
  });

  group('_lookupGeneral with MusicBrainz', () {
    const barcode = '9318113987752';
    late MockMusicBrainzApi mockMbApi;
    late MockBarcodeCacheDao mockCache;

    setUp(() {
      mockMbApi = MockMusicBrainzApi();
      mockCache = MockBarcodeCacheDao();
      when(() => mockCache.getByBarcode(barcode)).thenAnswer((_) async => null);
      when(() => mockCache.upsert(any())).thenAnswer((_) async {});
    });

    test(
      'returns MusicBrainz result when general lookup finds music',
      () async {
        final repo = MetadataRepositoryImpl(
          cacheDao: mockCache,
          musicBrainzApi: mockMbApi,
        );

        when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
          (_) async => const MusicBrainzSearchResponseDto(
            count: 1,
            releases: [
              MusicBrainzReleaseDto(
                id: 'mb-aus',
                title: 'Australian Album',
                date: '2022-01-01',
              ),
            ],
          ),
        );

        // No typeHint — goes through _lookupGeneral
        final result = await repo.lookupBarcode(barcode);

        expect(result, isA<SingleScanResult>());
        final single = result as SingleScanResult;
        expect(single.metadata.title, 'Australian Album');
        expect(single.metadata.sourceApis, ['musicbrainz']);
      },
    );

    test(
      'falls through to UPC when MusicBrainz finds nothing in general',
      () async {
        final mockUpcApi = MockUpcitemdbApi();
        final repo = MetadataRepositoryImpl(
          cacheDao: mockCache,
          musicBrainzApi: mockMbApi,
          upcitemdbApi: mockUpcApi,
        );

        when(() => mockMbApi.searchByBarcode(barcode)).thenAnswer(
          (_) async =>
              const MusicBrainzSearchResponseDto(count: 0, releases: []),
        );
        when(() => mockUpcApi.lookup(barcode)).thenAnswer(
          (_) async => const UpcSearchResponseDto(
            code: 'OK',
            total: 1,
            items: [UpcItemDto(title: 'Some Game', category: 'Games')],
          ),
        );

        final result = await repo.lookupBarcode(barcode);

        expect(result, isA<SingleScanResult>());
        final single = result as SingleScanResult;
        expect(single.metadata.title, 'Some Game');
        expect(single.metadata.sourceApis, ['upcitemdb']);
      },
    );
  });
}
