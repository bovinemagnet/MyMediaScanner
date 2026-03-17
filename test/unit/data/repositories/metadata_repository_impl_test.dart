import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
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

void main() {
  setUpAll(() {
    registerFallbackValue(BarcodeCacheTableCompanion(
      barcode: const Value(''),
      mediaTypeHint: const Value(null),
      responseJson: const Value('{}'),
      sourceApi: const Value(''),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
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
      when(() => mockCacheDao.getByBarcode(barcode))
          .thenAnswer((_) async => null);
    });

    test('returns multiMatch when Discogs returns 2+ results', () async {
      when(() => mockDiscogsApi.searchByBarcode(barcode))
          .thenAnswer((_) async => const DiscogsSearchResponseDto(
                results: [
                  DiscogsSearchResultDto(id: 1, title: 'Album A', year: '2000'),
                  DiscogsSearchResultDto(id: 2, title: 'Album B', year: '2005'),
                  DiscogsSearchResultDto(id: 3, title: 'Album C', year: '2010'),
                ],
              ));

      final result = await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, 3);
      expect(multi.candidates[0].sourceId, '1');
      expect(multi.candidates[1].sourceId, '2');
    });

    test('returns single when Discogs returns exactly 1 result', () async {
      const release = DiscogsReleaseDto(id: 1, title: 'The Album', year: 2000);

      when(() => mockDiscogsApi.searchByBarcode(barcode))
          .thenAnswer((_) async => const DiscogsSearchResponseDto(
                results: [DiscogsSearchResultDto(id: 1, title: 'The Album')],
              ));
      when(() => mockDiscogsApi.getRelease(1))
          .thenAnswer((_) async => release);
      when(() => mockCacheDao.upsert(any()))
          .thenAnswer((_) async {});

      final result = await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<SingleScanResult>());
    });

    test('limits candidates to maxCandidates', () async {
      final results = List.generate(
        10,
        (i) => DiscogsSearchResultDto(id: i, title: 'Album $i'),
      );

      when(() => mockDiscogsApi.searchByBarcode(barcode))
          .thenAnswer((_) async => DiscogsSearchResponseDto(results: results));

      final result = await repo.lookupBarcode(barcode, typeHint: MediaType.music);

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

      when(() => mockDiscogsApi.getRelease(12345))
          .thenAnswer((_) async => release);
      when(() => mockCacheDao.upsert(any()))
          .thenAnswer((_) async {});

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
  });
}
