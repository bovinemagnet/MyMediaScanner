import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/musicbrainz_api.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

class _MockBarcodeCacheDao extends Mock implements BarcodeCacheDao {}

class _MockMusicBrainzApi extends Mock implements MusicBrainzApi {}

class _MockDiscogsApi extends Mock implements DiscogsApi {}

class _MockCoverArtArchiveApi extends Mock implements CoverArtArchiveApi {}

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

  late _MockBarcodeCacheDao cacheDao;
  late _MockMusicBrainzApi mbApi;
  late _MockDiscogsApi discogsApi;
  late _MockCoverArtArchiveApi coverArtApi;
  late MetadataRepositoryImpl repo;

  const barcode = '5099902894225';

  setUp(() {
    cacheDao = _MockBarcodeCacheDao();
    mbApi = _MockMusicBrainzApi();
    discogsApi = _MockDiscogsApi();
    coverArtApi = _MockCoverArtArchiveApi();

    when(() => cacheDao.getByBarcode(any())).thenAnswer((_) async => null);
    when(() => cacheDao.upsert(any())).thenAnswer((_) async => 0);

    repo = MetadataRepositoryImpl(
      cacheDao: cacheDao,
      musicBrainzApi: mbApi,
      discogsApi: discogsApi,
      coverArtArchiveApi: coverArtApi,
    );
  });

  test('auto-accepts a single Official MusicBrainz match', () async {
    const release = MusicBrainzReleaseDto(
      id: 'rel-1',
      title: 'Live Album',
      status: 'Official',
      date: '2001-01-01',
      country: 'GB',
      media: [MusicBrainzMediaDto(format: 'CD', trackCount: 12)],
    );
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const MusicBrainzSearchResponseDto(
        count: 1,
        releases: [release],
      ),
    );
    when(() => mbApi.getRelease('rel-1'))
        .thenAnswer((_) async => release);
    when(() => coverArtApi.findFrontArtwork(
          releaseId: any(named: 'releaseId'),
          releaseGroupId: any(named: 'releaseGroupId'),
        )).thenAnswer((_) async => 'https://example.com/front.jpg');

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    final single = result as SingleScanResult;
    expect(single.metadata.title, 'Live Album');
    expect(single.metadata.sourceApis, contains('musicbrainz'));
    expect(single.metadata.coverUrl, 'https://example.com/front.jpg');
  });

  test('presents disambiguation when multiple MusicBrainz releases match',
      () async {
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const MusicBrainzSearchResponseDto(
        count: 2,
        releases: [
          MusicBrainzReleaseDto(
              id: 'rel-a', title: 'A', status: 'Official', country: 'GB'),
          MusicBrainzReleaseDto(
              id: 'rel-b', title: 'B', status: 'Official', country: 'US'),
        ],
      ),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<MultiMatchScanResult>());
    final multi = result as MultiMatchScanResult;
    expect(multi.candidates.length, 2);
    expect(multi.candidates.map((c) => c.country),
        containsAll(<String>['GB', 'US']));
  });

  test('falls back to Discogs when MusicBrainz returns no results',
      () async {
    when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
      (_) async =>
          const MusicBrainzSearchResponseDto(count: 0, releases: []),
    );
    when(() => discogsApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const DiscogsSearchResponseDto(
        results: [DiscogsSearchResultDto(id: 42, title: 'Discogs Album')],
      ),
    );
    when(() => discogsApi.getRelease(42)).thenAnswer(
      (_) async => const DiscogsReleaseDto(id: 42, title: 'Discogs Album'),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    expect((result as SingleScanResult).metadata.sourceApis,
        contains('discogs'));
  });

  test('falls back to Discogs when MusicBrainz reports rate-limit',
      () async {
    when(() => mbApi.searchByBarcode(barcode)).thenThrow(
      const RateLimitExceededException('/release/'),
    );
    when(() => discogsApi.searchByBarcode(barcode)).thenAnswer(
      (_) async => const DiscogsSearchResponseDto(
        results: [DiscogsSearchResultDto(id: 1, title: 'Fallback')],
      ),
    );
    when(() => discogsApi.getRelease(1)).thenAnswer(
      (_) async => const DiscogsReleaseDto(id: 1, title: 'Fallback'),
    );

    final result =
        await repo.lookupBarcode(barcode, typeHint: MediaType.music);

    expect(result, isA<SingleScanResult>());
    expect((result as SingleScanResult).metadata.title, 'Fallback');
  });
}
