// Author: Paul Snow

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_defect_detector/audio_defect_detector.dart' as add;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';
import 'package:dart_accuraterip/dart_accuraterip.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/analyse_rip_quality_usecase.dart';

// ---------------------------------------------------------------------------
// Synchronous IsolateRunner — runs the closure inline on the test thread so
// tests can drive the FLAC decode, AccurateRip CRC, and click-detection
// paths without spinning up real isolates (closures capture mocks that are
// not isolate-safe).
// ---------------------------------------------------------------------------

Future<R> _syncIsolateRunner<R>(FutureOr<R> Function() computation) async {
  return await computation();
}

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockFlacDecoder extends Mock implements FlacDecoder {}

class MockAccurateRipClient extends Mock implements AccurateRipClient {}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a minimal [RipTrack] for testing purposes.
///
/// The [filePath] defaults to a non-existent path so that [_tryParseLog]
/// catches the directory-listing exception and returns null, allowing tests
/// to exercise the flac-availability branch without real filesystem I/O.
RipTrack _track({
  required String id,
  required int trackNumber,
  String? filePath,
}) =>
    RipTrack(
      id: id,
      ripAlbumId: 'album-1',
      trackNumber: trackNumber,
      filePath: filePath ?? '/fake/path/track$trackNumber.flac',
      fileSizeBytes: 30000000,
      updatedAt: 0,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late AnalyseRipQualityUseCase useCase;
  late MockRipLibraryRepository mockRepo;
  late MockFlacDecoder mockFlacDecoder;
  late MockAccurateRipClient mockArClient;

  setUpAll(() {
    // The AR-path tests use `mockArClient.queryDisc(any())`, which forces
    // mocktail to register a fallback value for AccurateRipDiscId.
    registerFallbackValue(AccurateRipDiscId.fromTrackSampleCounts(const [1]));
  });

  setUp(() {
    mockRepo = MockRipLibraryRepository();
    mockFlacDecoder = MockFlacDecoder();
    mockArClient = MockAccurateRipClient();

    useCase = AnalyseRipQualityUseCase(
      repository: mockRepo,
      flacDecoder: mockFlacDecoder,
      accurateRipClient: mockArClient,
      isolateRunner: _syncIsolateRunner,
    );
  });

  group('execute', () {
    group('returns empty stream when album has no tracks', () {
      test('execute_withNoTracks_emitsNothing', () async {
        // Arrange
        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => []);

        // Act
        final events = await useCase.execute('album-1').toList();

        // Assert
        expect(events, isEmpty);
        verifyNever(() => mockFlacDecoder.isAvailable());
        verifyNever(() => mockRepo.updateTrackQuality(any()));
      });
    });

    group('marks tracks as not_checked when flac decoder is unavailable', () {
      test(
          'execute_withTracksAndFlacUnavailable_updatesAllTracksAsNotChecked',
          () async {
        // Arrange
        // Non-existent paths cause _tryParseLog to catch an IO exception and
        // return null, so all tracks proceed to the flac availability check.
        final tracks = [
          _track(id: 'track-1', trackNumber: 1),
          _track(id: 'track-2', trackNumber: 2),
        ];

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => tracks);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => false);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Act
        // Drain the stream so all async* yields and awaits complete.
        await useCase.execute('album-1').drain<void>();

        // Assert — every track must be marked not_checked exactly once
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_checked',
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
        verify(() => mockRepo.updateTrackQuality(
              'track-2',
              arStatus: 'not_checked',
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
      });
    });

    group('yields initial progress with correct track count', () {
      test(
          'execute_withTwoTracks_firstProgressEventHasTotalTracksOfTwo',
          () async {
        // Arrange
        final tracks = [
          _track(id: 'track-1', trackNumber: 1),
          _track(id: 'track-2', trackNumber: 2),
        ];

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => tracks);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => false);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Act
        // Collect only the first emitted progress event before draining the
        // remainder so we do not block on the Isolate.run paths.
        final firstEvent =
            await useCase.execute('album-1').first;

        // Assert
        expect(firstEvent.totalTracks, equals(2));
        expect(firstEvent.currentTrack, equals(0));
        expect(firstEvent.currentStep, equals('Parsing log'));
      });

      test(
          'execute_withSingleTrack_firstProgressEventHasTotalTracksOfOne',
          () async {
        // Arrange
        final tracks = [_track(id: 'track-1', trackNumber: 1)];

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => tracks);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => false);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Act
        final firstEvent = await useCase.execute('album-1').first;

        // Assert
        expect(firstEvent.totalTracks, equals(1));
      });
    });

    group('applies log results when AccurateRip status is verified', () {
      test(
          'execute_withVerifiedEacLog_updatesTrackAsVerifiedWithLogFields',
          () async {
        // Arrange — write an EAC log containing a verified track into a
        // temp directory and point the track's filePath at that directory.
        final tempDir =
            await Directory.systemTemp.createTemp('riplog_verified_');
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        const logContent = '''
Exact Audio Copy V1.6 from 23. October 2019

EAC extraction logfile from 15. March 2026

Artist / Title / Year : Test Artist / Test Album / 2024
Format                : FLAC (Tracks)
Used drive            : ASUS BW-16D1HT   Adapter: 1   ID: 0

Read mode             : Secure

Track  1

     Filename C:\\Music\\TestAlbum\\01 - Track One.flac

     Peak level 96.2 %
     Track quality 99.8 %
     Test CRC 882B01BE
     Copy CRC 882B01BE
     Accurately ripped (confidence 1)  [F4E2268A]  (AR v2 signature: A1B2C3D4)
     Copy OK


All tracks accurately ripped

No errors occurred

End of status report

==== Log checksum ABCDEF1234567890ABCDEF1234567890 ====
''';
        await File('${tempDir.path}/rip.log').writeAsString(logContent);

        final track = _track(
          id: 'track-1',
          trackNumber: 1,
          filePath: '${tempDir.path}/01 - Track One.flac',
        );

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => [track]);
        // flac unavailable stops the pipeline after the log branch so we
        // do not exercise the Isolate.run paths.
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => false);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              arConfidence: any(named: 'arConfidence'),
              arCrcV1: any(named: 'arCrcV1'),
              arCrcV2: any(named: 'arCrcV2'),
              peakLevel: any(named: 'peakLevel'),
              trackQuality: any(named: 'trackQuality'),
              copyCrc: any(named: 'copyCrc'),
              ripLogSource: any(named: 'ripLogSource'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Act
        await useCase.execute('album-1').drain<void>();

        // Assert — verified branch writes AR fields and log-derived metrics.
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'verified',
              arConfidence: 1,
              arCrcV1: 'F4E2268A',
              arCrcV2: 'A1B2C3D4',
              peakLevel: any(named: 'peakLevel'),
              trackQuality: any(named: 'trackQuality'),
              copyCrc: '882B01BE',
              ripLogSource: 'EAC',
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
        // Verified tracks do not need further analysis, so not_checked must
        // not be written.
        verifyNever(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_checked',
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            ));
      });
    });

    group(
        'falls through to defect detection when AccurateRip is unreachable',
        () {
      test(
          'execute_withFlacAvailable_andUnknownSampleCounts_runsDefectDetection',
          () async {
        // Arrange
        // The fake file path means _tryParseLog fails (no log) and
        // FlacReader.readMetadata returns null, which makes
        // sampleCounts.every((c) => c > 0) false, so the AR query is
        // skipped and the pipeline falls into step 3 (defect detection).
        final track = _track(id: 'track-1', trackNumber: 1);
        // 0.1 s of 16-bit stereo silence at 44.1 kHz: 4 bytes/frame *
        // 4410 frames = 17 640 bytes. Silence has no clicks/pops, so the
        // detector returns an empty defects list deterministically.
        final pcmData = Uint8List(17640);

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => [track]);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => true);
        when(() => mockFlacDecoder.decode(any()))
            .thenAnswer((_) async => pcmData);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              clickCount: any(named: 'clickCount'),
              popCount: any(named: 'popCount'),
              clippingCount: any(named: 'clippingCount'),
              dropoutCount: any(named: 'dropoutCount'),
              defectConfidence: any(named: 'defectConfidence'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Act
        await useCase.execute('album-1').drain<void>();

        // Assert — track is marked not_found (AR could not verify) with
        // every defect-type count explicitly zeroed (silence in, no
        // defects out). AccurateRip must NOT be queried because sample
        // counts were unknown.
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_found',
              clickCount: 0,
              popCount: 0,
              clippingCount: 0,
              dropoutCount: 0,
              defectConfidence: any(named: 'defectConfidence'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
        // AccurateRip is unreachable when sample counts are unknown, so the
        // client should not be touched at all.
        verifyZeroInteractions(mockArClient);
      });

      test(
          'execute_withInjectedDetector_partitionsDefectsByType',
          () async {
        // Arrange — inject a fake DefectDetector returning one defect of
        // each DefectType plus a known aggregateConfidence so we can
        // assert the use case partitions counts correctly and forwards
        // the confidence verbatim.
        final track = _track(id: 'track-1', trackNumber: 1);
        final pcmData = Uint8List(17640);

        const aggregate = 0.42;
        const result = add.AnalysisResult(
          defects: [
            add.Defect(
              offset: Duration.zero,
              length: Duration(milliseconds: 1),
              type: add.DefectType.click,
              confidence: 0.9,
              channel: 0,
              sampleIndex: 100,
              amplitude: 0.95,
            ),
            add.Defect(
              offset: Duration(milliseconds: 50),
              length: Duration(milliseconds: 5),
              type: add.DefectType.pop,
              confidence: 0.8,
              channel: 1,
              sampleIndex: 2205,
              amplitude: 0.85,
            ),
            add.Defect(
              offset: Duration(milliseconds: 200),
              length: Duration(milliseconds: 1),
              type: add.DefectType.clipping,
              confidence: 0.95,
              channel: 0,
              sampleIndex: 8820,
              amplitude: 0.99,
            ),
            add.Defect(
              offset: Duration(milliseconds: 500),
              length: Duration(milliseconds: 20),
              type: add.DefectType.dropout,
              confidence: 0.7,
              channel: 1,
              sampleIndex: 22050,
              amplitude: 0.0,
            ),
          ],
          aggregateConfidence: aggregate,
          metadata: add.AudioMetadata(
            sampleRate: 44100,
            bitDepth: 16,
            channels: 2,
            duration: Duration(milliseconds: 100),
          ),
        );

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => [track]);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => true);
        when(() => mockFlacDecoder.decode(any()))
            .thenAnswer((_) async => pcmData);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              clickCount: any(named: 'clickCount'),
              popCount: any(named: 'popCount'),
              clippingCount: any(named: 'clippingCount'),
              dropoutCount: any(named: 'dropoutCount'),
              defectConfidence: any(named: 'defectConfidence'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        useCase = AnalyseRipQualityUseCase(
          repository: mockRepo,
          flacDecoder: mockFlacDecoder,
          accurateRipClient: mockArClient,
          isolateRunner: _syncIsolateRunner,
          defectDetector: (_, {required format, required config}) => result,
        );

        // Act
        await useCase.execute('album-1').drain<void>();

        // Assert — one defect per type, aggregate confidence forwarded.
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_found',
              clickCount: 1,
              popCount: 1,
              clippingCount: 1,
              dropoutCount: 1,
              defectConfidence: aggregate,
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
      });
    });

    group('AccurateRip verified path', () {
      test(
          'execute_withMatchingArEntry_marksTrackVerifiedWithConfidence',
          () async {
        // Arrange
        // 0.1 s of 16-bit stereo silence at 44.1 kHz. The exact bytes do
        // not matter — what matters is that the locally computed v1/v2
        // CRC for this buffer exactly equals the entry CRC we seed in
        // the AR result, so production code takes the "match" branch.
        final track = _track(id: 'track-1', trackNumber: 1);
        final pcmData = Uint8List(17640);

        // Compute the expected v1 CRC the same way the use case does.
        // isFirst/isLast are true because this is the only track in the
        // album.
        final expectedV1 = computeArV1(
          pcmData,
          isFirstTrack: true,
          isLastTrack: true,
        );

        // Stand up an AR response whose only entry's CRC equals the
        // locally computed v1, with a non-zero confidence so we can
        // assert it was forwarded to the repository.
        final arResult = AccurateRipDiscResult(tracks: [
          AccurateRipTrackResult(
            trackNumber: 1,
            entries: [
              AccurateRipEntry(
                confidence: 7,
                crc: expectedV1,
                frame450Crc: 0,
              ),
            ],
          ),
        ]);

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => [track]);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => true);
        when(() => mockFlacDecoder.decode(any()))
            .thenAnswer((_) async => pcmData);
        when(() => mockArClient.queryDisc(any()))
            .thenAnswer((_) async => arResult);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              arConfidence: any(named: 'arConfidence'),
              arCrcV1: any(named: 'arCrcV1'),
              arCrcV2: any(named: 'arCrcV2'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        // Build a use case whose metadata reader returns synthetic
        // STREAMINFO with non-zero totalSamples so the AR query path is
        // reachable (the default reader returns null for fake paths).
        useCase = AnalyseRipQualityUseCase(
          repository: mockRepo,
          flacDecoder: mockFlacDecoder,
          accurateRipClient: mockArClient,
          isolateRunner: _syncIsolateRunner,
          flacMetadataReader: (_) async =>
              const FlacMetadata(totalSamples: 4410),
        );

        // Act
        await useCase.execute('album-1').drain<void>();

        // Assert — verified branch: confidence forwarded, CRCs in hex.
        final expectedV1Hex =
            expectedV1.toRadixString(16).padLeft(8, '0').toUpperCase();
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'verified',
              arConfidence: 7,
              arCrcV1: expectedV1Hex,
              arCrcV2: any(named: 'arCrcV2'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
        // Click detection must not run when AR verified the track.
        verifyNever(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_found',
              clickCount: any(named: 'clickCount'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            ));
      });
    });

    group('AccurateRip mismatch path', () {
      test(
          'execute_withNonMatchingArEntry_marksTrackMismatchAndSkipsClickDetection',
          () async {
        // Arrange — same shape as the verified test, but the AR entry's
        // CRC is deliberately set to a value that cannot match either
        // computed v1 or v2 (silence's locally computed CRCs are not
        // 0xDEADBEEF).
        final track = _track(id: 'track-1', trackNumber: 1);
        final pcmData = Uint8List(17640);

        const arResult = AccurateRipDiscResult(tracks: [
          AccurateRipTrackResult(
            trackNumber: 1,
            entries: [
              AccurateRipEntry(
                confidence: 3,
                crc: 0xDEADBEEF,
                frame450Crc: 0,
              ),
            ],
          ),
        ]);

        when(() => mockRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => [track]);
        when(() => mockFlacDecoder.isAvailable())
            .thenAnswer((_) async => true);
        when(() => mockFlacDecoder.decode(any()))
            .thenAnswer((_) async => pcmData);
        when(() => mockArClient.queryDisc(any()))
            .thenAnswer((_) async => arResult);
        when(() => mockRepo.updateTrackQuality(
              any(),
              arStatus: any(named: 'arStatus'),
              arCrcV1: any(named: 'arCrcV1'),
              arCrcV2: any(named: 'arCrcV2'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).thenAnswer((_) async {});

        useCase = AnalyseRipQualityUseCase(
          repository: mockRepo,
          flacDecoder: mockFlacDecoder,
          accurateRipClient: mockArClient,
          isolateRunner: _syncIsolateRunner,
          flacMetadataReader: (_) async =>
              const FlacMetadata(totalSamples: 4410),
        );

        // Act
        await useCase.execute('album-1').drain<void>();

        // Assert — mismatch branch: CRCs forwarded but no confidence
        // (the entry was wrong, so no submission's confidence applies).
        verify(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'mismatch',
              arCrcV1: any(named: 'arCrcV1'),
              arCrcV2: any(named: 'arCrcV2'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            )).called(1);
        // Click detection must NOT run when AR returned a (mismatching)
        // entry — the mismatch branch is terminal for this track.
        verifyNever(() => mockRepo.updateTrackQuality(
              'track-1',
              arStatus: 'not_found',
              clickCount: any(named: 'clickCount'),
              qualityCheckedAt: any(named: 'qualityCheckedAt'),
            ));
      });
    });
  });
}
