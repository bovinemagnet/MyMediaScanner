// Author: Paul Snow

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:dart_accuraterip/dart_accuraterip.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/analyse_rip_quality_usecase.dart';

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

  setUp(() {
    mockRepo = MockRipLibraryRepository();
    mockFlacDecoder = MockFlacDecoder();
    mockArClient = MockAccurateRipClient();

    useCase = AnalyseRipQualityUseCase(
      repository: mockRepo,
      flacDecoder: mockFlacDecoder,
      accurateRipClient: mockArClient,
    );
  });

  // TODO: Tests for AccurateRip and click detection paths require refactoring
  // Isolate.run to be injectable.

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
  });
}
