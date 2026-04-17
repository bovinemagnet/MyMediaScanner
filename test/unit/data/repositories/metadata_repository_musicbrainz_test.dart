import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
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
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
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

  group('ranking', () {
    test('auto-accepts Official release over a bootleg with the same barcode',
        () async {
      const official = MusicBrainzReleaseDto(
        id: 'rel-official',
        title: 'The Album (Official)',
        status: 'Official',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 10)],
      );
      const bootleg = MusicBrainzReleaseDto(
        id: 'rel-bootleg',
        title: 'The Album (Bootleg)',
        status: 'Bootleg',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 10)],
      );
      when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 2,
          releases: [bootleg, official],
        ),
      );
      when(() => mbApi.getRelease('rel-official'))
          .thenAnswer((_) async => official);
      when(() => coverArtApi.findFrontArtwork(
            releaseId: any(named: 'releaseId'),
            releaseGroupId: any(named: 'releaseGroupId'),
          )).thenAnswer((_) async => null);

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<SingleScanResult>());
      expect((result as SingleScanResult).metadata.title,
          'The Album (Official)');
    });

    test(
        'auto-accepts clearly dominant candidate when MusicBrainz score '
        'gap is large', () async {
      const dominant = MusicBrainzReleaseDto(
        id: 'rel-dominant',
        title: 'Dominant',
        status: 'Official',
        score: 100,
        country: 'GB',
        date: '2010-01-01',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 14)],
      );
      const weak = MusicBrainzReleaseDto(
        id: 'rel-weak',
        title: 'Weak',
        status: 'Official',
        score: 60,
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 14)],
      );
      when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 2,
          releases: [weak, dominant],
        ),
      );
      when(() => mbApi.getRelease('rel-dominant'))
          .thenAnswer((_) async => dominant);
      when(() => coverArtApi.findFrontArtwork(
            releaseId: any(named: 'releaseId'),
            releaseGroupId: any(named: 'releaseGroupId'),
          )).thenAnswer((_) async => null);

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<SingleScanResult>());
      expect((result as SingleScanResult).metadata.title, 'Dominant');
    });

    test(
        'keeps two close Official releases in the disambiguation list',
        () async {
      const a = MusicBrainzReleaseDto(
        id: 'rel-a',
        title: 'Variant A',
        status: 'Official',
        score: 100,
        country: 'GB',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 10)],
      );
      const b = MusicBrainzReleaseDto(
        id: 'rel-b',
        title: 'Variant B',
        status: 'Official',
        score: 95,
        country: 'US',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 10)],
      );
      when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 2,
          releases: [b, a],
        ),
      );

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, 2);
      // Ranking must place the stronger score first so users see it above.
      expect(multi.candidates.first.sourceId, 'rel-a');
    });

    test(
        'ranks preferred physical formats above non-physical when '
        'everything else is equal', () async {
      const digital = MusicBrainzReleaseDto(
        id: 'rel-digital',
        title: 'Digital Edition',
        status: 'Official',
        score: 90,
        media: [MusicBrainzMediaDto(format: 'Digital Media', trackCount: 10)],
      );
      const cd = MusicBrainzReleaseDto(
        id: 'rel-cd',
        title: 'CD Edition',
        status: 'Official',
        score: 90,
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 10)],
      );
      when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 2,
          releases: [digital, cd],
        ),
      );

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<MultiMatchScanResult>());
      final multi = result as MultiMatchScanResult;
      expect(multi.candidates.first.sourceId, 'rel-cd');
    });
  });

  group('cache', () {
    test('serves a cached MusicBrainz response without calling the API',
        () async {
      const cached = MusicBrainzReleaseDto(
        id: 'rel-cached',
        title: 'Cached Album',
        status: 'Official',
        country: 'GB',
        date: '2015-06-01',
        media: [MusicBrainzMediaDto(format: 'CD', trackCount: 11)],
      );

      when(() => cacheDao.getByBarcode(barcode)).thenAnswer(
        (_) async => BarcodeCacheTableData(
          barcode: barcode,
          mediaTypeHint: 'music',
          responseJson: jsonEncode(cached.toJson()),
          sourceApi: 'musicbrainz',
          cachedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, 'Cached Album');
      expect(single.metadata.sourceApis, contains('musicbrainz'));
      verifyNever(() => mbApi.searchByBarcode(any()));
      verifyNever(() => discogsApi.searchByBarcode(any()));
    });

    test(
        'bypasses a stale cache entry and queries MusicBrainz live',
        () async {
      const stale = MusicBrainzReleaseDto(
        id: 'rel-stale',
        title: 'Stale',
      );
      // 30 days old — past the 7-day cacheDurationDays window.
      final staleTs = DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch;
      when(() => cacheDao.getByBarcode(barcode)).thenAnswer(
        (_) async => BarcodeCacheTableData(
          barcode: barcode,
          mediaTypeHint: 'music',
          responseJson: jsonEncode(stale.toJson()),
          sourceApi: 'musicbrainz',
          cachedAt: staleTs,
        ),
      );
      when(() => mbApi.searchByBarcode(barcode)).thenAnswer(
        (_) async => const MusicBrainzSearchResponseDto(
          count: 1,
          releases: [
            MusicBrainzReleaseDto(
                id: 'rel-fresh', title: 'Fresh', status: 'Official'),
          ],
        ),
      );
      when(() => mbApi.getRelease('rel-fresh')).thenAnswer(
        (_) async => const MusicBrainzReleaseDto(
            id: 'rel-fresh', title: 'Fresh', status: 'Official'),
      );
      when(() => coverArtApi.findFrontArtwork(
            releaseId: any(named: 'releaseId'),
            releaseGroupId: any(named: 'releaseGroupId'),
          )).thenAnswer((_) async => null);

      final result =
          await repo.lookupBarcode(barcode, typeHint: MediaType.music);

      expect(result, isA<SingleScanResult>());
      expect((result as SingleScanResult).metadata.title, 'Fresh');
      verify(() => mbApi.searchByBarcode(barcode)).called(1);
    });
  });

  group('fetchCandidateDetail — musicbrainz', () {
    test('fetches release detail and applies Cover Art Archive artwork',
        () async {
      const release = MusicBrainzReleaseDto(
        id: 'rel-detail',
        title: 'Detailed Release',
        releaseGroup:
            MusicBrainzReleaseGroupDto(id: 'rg-1', title: 'Group'),
      );
      when(() => mbApi.getRelease('rel-detail'))
          .thenAnswer((_) async => release);
      when(() => coverArtApi.findFrontArtwork(
            releaseId: 'rel-detail',
            releaseGroupId: 'rg-1',
          )).thenAnswer((_) async => 'https://example.com/detail.jpg');

      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'musicbrainz',
          sourceId: 'rel-detail',
          title: 'Detailed Release',
        ),
        barcode,
        'ean13',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Detailed Release');
      expect(result.coverUrl, 'https://example.com/detail.jpg');
      expect(result.sourceApis, contains('musicbrainz'));
    });

    test('returns null when MusicBrainz getRelease yields nothing',
        () async {
      when(() => mbApi.getRelease('rel-missing'))
          .thenAnswer((_) async => null);

      final result = await repo.fetchCandidateDetail(
        const MetadataCandidate(
          sourceApi: 'musicbrainz',
          sourceId: 'rel-missing',
          title: 'Missing',
        ),
        barcode,
        'ean13',
      );

      expect(result, isNull);
    });
  });
}
