import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/gnudb/cue_frame_offsets_parser.dart';
import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/entities/gnudb_query_result.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_gnudb_candidate_cache.dart';
import 'package:mymediascanner/domain/repositories/i_gnudb_service.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';

class _MockApi extends Mock implements IGnudbService {}

class _MockCache extends Mock implements IGnudbCandidateCache {}

class _MockRepo extends Mock implements IRipLibraryRepository {}

RipAlbum _album({
  String? cueFilePath = '/lib/album/album.cue',
  int discCount = 1,
}) =>
    RipAlbum(
      id: 'album-1',
      libraryPath: '/lib/album',
      trackCount: 3,
      discCount: discCount,
      totalSizeBytes: 0,
      cueFilePath: cueFilePath,
      lastScannedAt: 0,
      updatedAt: 0,
    );

List<RipTrack> _tracks({int count = 3, int durationMs = 200000}) => [
      for (var i = 1; i <= count; i++)
        RipTrack(
          id: 'track-$i',
          ripAlbumId: 'album-1',
          discNumber: 1,
          trackNumber: i,
          filePath: '/lib/album/track$i.flac',
          durationMs: durationMs,
          fileSizeBytes: 0,
          updatedAt: 0,
        ),
    ];

/// CUE offsets for a single-file image (3 tracks at 0, 15000, 30000 frames).
List<CueTrackOffset> _singleImageOffsets() => const [
      CueTrackOffset(
          trackNumber: 1,
          filePath: 'album.flac',
          inFileFrameOffset: 0),
      CueTrackOffset(
          trackNumber: 2,
          filePath: 'album.flac',
          inFileFrameOffset: 15000),
      CueTrackOffset(
          trackNumber: 3,
          filePath: 'album.flac',
          inFileFrameOffset: 30000),
    ];

/// CUE offsets for a per-track multi-file CUE.
List<CueTrackOffset> _perTrackOffsets() => const [
      CueTrackOffset(
          trackNumber: 1, filePath: 't1.flac', inFileFrameOffset: 0),
      CueTrackOffset(
          trackNumber: 2, filePath: 't2.flac', inFileFrameOffset: 0),
      CueTrackOffset(
          trackNumber: 3, filePath: 't3.flac', inFileFrameOffset: 0),
    ];

void main() {
  setUpAll(() {
    registerFallbackValue(const <int>[]);
    registerFallbackValue(const <GnudbCandidate>[]);
  });

  late _MockApi api;
  late _MockCache cache;
  late _MockRepo repo;

  setUp(() {
    api = _MockApi();
    cache = _MockCache();
    repo = _MockRepo();
    when(() => repo.updateGnudbDiscId(any(), any()))
        .thenAnswer((_) async {});
    when(() => cache.read(any())).thenAnswer((_) async => null);
    when(() => cache.write(any(), any())).thenAnswer((_) async {});
  });

  LookupGnudbForRipUseCase buildUseCase(
      {CueFrameOffsetsLoader? loader}) =>
      LookupGnudbForRipUseCase(
        api: api,
        cache: cache,
        repository: repo,
        rootPath: '/lib/album',
        loader: loader ?? (path) async => _singleImageOffsets(),
      );

  group('early validation errors', () {
    test('no cue => error', () async {
      final result = await buildUseCase().execute(
        album: _album(cueFilePath: null),
        tracks: _tracks(),
      );
      expect(result, isA<GnudbLookupError>());
    });

    test('multi-disc proceeds past the early gate', () async {
      // Multi-disc albums are no longer rejected at the early-validation
      // stage. The use case continues into cue parsing and API lookup;
      // with no GnuDB match for whatever the CUE describes the caller
      // sees a normal no-match result instead of the historical
      // "multi-disc not supported" rejection.
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => const GnudbQueryNoMatch());
      final result = await buildUseCase().execute(
        album: _album(discCount: 2),
        tracks: _tracks(),
      );
      expect(result, isA<GnudbLookupNoMatch>());
    });

    test('empty tracks => error', () async {
      final result = await buildUseCase().execute(
        album: _album(),
        tracks: const [],
      );
      expect(result, isA<GnudbLookupError>());
    });

    test('missing duration => error', () async {
      final tracks = _tracks()
          .map((t) => t.copyWith(durationMs: null))
          .toList();
      final result = await buildUseCase().execute(
        album: _album(),
        tracks: tracks,
      );
      expect(result, isA<GnudbLookupError>());
    });

    test('track count mismatch => error', () async {
      final uc = buildUseCase(
        loader: (_) async => _singleImageOffsets().take(2).toList(),
      );
      final result = await uc.execute(album: _album(), tracks: _tracks());
      expect(result, isA<GnudbLookupError>());
    });
  });

  group('successful flows', () {
    test('single match returns GnudbLookupSingle, writes cache and discid',
        () async {
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => const GnudbQuerySingle(
            GnudbQueryMatch(
              category: 'rock',
              discId: '08025603',
              title: 'Example Artist / Example Album',
            ),
          ));

      when(() => api.read(
            category: any(named: 'category'),
            discId: any(named: 'discId'),
          )).thenAnswer((_) async => const GnudbDisc(
            discId: '08025603',
            artist: 'Example Artist',
            albumTitle: 'Example Album',
            year: 2023,
            genre: 'Rock',
            trackTitles: ['One', 'Two', 'Three'],
          ));

      final result = await buildUseCase().execute(
        album: _album(),
        tracks: _tracks(),
      );

      expect(result, isA<GnudbLookupSingle>());
      final single = result as GnudbLookupSingle;
      expect(single.candidate.discId, '08025603');
      verify(() => repo.updateGnudbDiscId('album-1', any())).called(1);

      // Cache is keyed by the *computed* disc id. With 3 tracks of 200s
      // each and LBAs [150, 15150, 30150], the disc id is 0c025803.
      final written =
          verify(() => cache.write('0c025803', captureAny())).captured.single
              as List<GnudbCandidate>;
      expect(written, hasLength(1));
      expect(written.single.discId, '08025603');
    });

    test('multi match returns at most _maxMultiCandidates candidates',
        () async {
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => GnudbQueryMulti([
            for (var i = 0; i < 8; i++)
              GnudbQueryMatch(
                category: 'misc',
                discId: '0000000$i',
                title: 'Artist $i / Album $i',
              ),
          ]));

      when(() => api.read(
            category: any(named: 'category'),
            discId: any(named: 'discId'),
          )).thenAnswer((invocation) async {
        final discId =
            invocation.namedArguments[const Symbol('discId')] as String;
        return GnudbDisc(
          discId: discId,
          artist: 'A',
          albumTitle: 'B',
          trackTitles: const ['x', 'y', 'z'],
        );
      });

      final result = await buildUseCase().execute(
        album: _album(),
        tracks: _tracks(),
      );

      expect(result, isA<GnudbLookupMulti>());
      expect((result as GnudbLookupMulti).candidates, hasLength(5));
    });

    test('no-match from server', () async {
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => const GnudbQueryNoMatch());

      final result = await buildUseCase().execute(
        album: _album(),
        tracks: _tracks(),
      );

      expect(result, isA<GnudbLookupNoMatch>());
    });

    test('server error bubbles up as GnudbLookupError', () async {
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => const GnudbQueryError(
              code: 500, message: 'Internal server error'));

      final result = await buildUseCase().execute(
        album: _album(),
        tracks: _tracks(),
      );
      expect(result, isA<GnudbLookupError>());
    });
  });

  group('caching', () {
    test('cache hit short-circuits API', () async {
      when(() => cache.read('0c025803')).thenAnswer((_) async => const [
            GnudbCandidate(
              discId: '08025603',
              category: 'rock',
              disc: GnudbDisc(
                discId: '08025603',
                artist: 'A',
                albumTitle: 'B',
                trackTitles: ['1', '2', '3'],
              ),
            ),
          ]);

      final result =
          await buildUseCase().execute(album: _album(), tracks: _tracks());
      expect(result, isA<GnudbLookupSingle>());
      verifyNever(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          ));
    });

    test('multiple cached candidates surface as GnudbLookupMulti', () async {
      when(() => cache.read('0c025803')).thenAnswer((_) async => const [
            GnudbCandidate(
              discId: '00000001',
              category: 'rock',
              disc: GnudbDisc(
                discId: '00000001',
                artist: 'A',
                albumTitle: 'B',
                trackTitles: ['1', '2', '3'],
              ),
            ),
            GnudbCandidate(
              discId: '00000002',
              category: 'misc',
              disc: GnudbDisc(
                discId: '00000002',
                artist: 'C',
                albumTitle: 'D',
                trackTitles: ['1', '2', '3'],
              ),
            ),
          ]);

      final result =
          await buildUseCase().execute(album: _album(), tracks: _tracks());
      expect(result, isA<GnudbLookupMulti>());
      expect((result as GnudbLookupMulti).candidates, hasLength(2));
    });
  });

  group('multi-file CUE produces correct LBAs', () {
    test('per-track file cue yields cumulative offsets', () async {
      // 3 tracks of 200s each → 15000 frames each.
      // Expected LBAs: 150, 15150, 30150 → identical to single-image case,
      // which means the Disc ID should match the first test's 08025603.
      when(() => api.query(
            discId: any(named: 'discId'),
            frameOffsets: any(named: 'frameOffsets'),
            totalSeconds: any(named: 'totalSeconds'),
          )).thenAnswer((_) async => const GnudbQueryNoMatch());

      final uc = buildUseCase(loader: (_) async => _perTrackOffsets());
      await uc.execute(album: _album(), tracks: _tracks());

      final captured = verify(() => api.query(
            discId: captureAny(named: 'discId'),
            frameOffsets: captureAny(named: 'frameOffsets'),
            totalSeconds: captureAny(named: 'totalSeconds'),
          )).captured;
      expect(captured[0], '0c025803');
      expect(captured[1], [150, 15150, 30150]);
      expect(captured[2], 602);
    });
  });
}
