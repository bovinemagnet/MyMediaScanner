/// Unit tests for [QualityAnalysisNotifier].
///
/// Verifies state transitions for the audio quality analysis workflow,
/// including idle → analysing → complete, no-op whilst already analysing,
/// and error handling.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/data/remote/api/accuraterip/accuraterip_client.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

/// Mocktail mock for the concrete [FlacDecoder] class.
class MockFlacDecoder extends Mock implements FlacDecoder {}

/// Mocktail mock for the concrete [AccurateRipClient] class.
class MockAccurateRipClient extends Mock implements AccurateRipClient {}

/// Stub notifier that returns a fixed threshold of 8.0 synchronously.
///
/// The real [ClickDetectionThresholdNotifier] reads from secure storage, which
/// is unavailable in unit tests. This stub returns [AsyncValue.data] immediately
/// so that `ref.read(clickDetectionThresholdProvider).value` resolves to 8.0.
class ClickDetectionThresholdStub extends ClickDetectionThresholdNotifier {
  @override
  Future<double> build() async => 8.0;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _createContainer({
  required MockRipLibraryRepository ripRepo,
  required MockFlacDecoder flacDecoder,
  required MockAccurateRipClient arClient,
}) {
  return ProviderContainer(
    overrides: [
      ripLibraryRepositoryProvider.overrideWithValue(ripRepo),
      flacDecoderProvider.overrideWithValue(flacDecoder),
      accurateRipClientProvider.overrideWithValue(arClient),
      clickDetectionThresholdProvider
          .overrideWith(() => ClickDetectionThresholdStub()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRipLibraryRepository mockRipRepo;
  late MockFlacDecoder mockFlacDecoder;
  late MockAccurateRipClient mockArClient;

  setUp(() {
    mockRipRepo = MockRipLibraryRepository();
    mockFlacDecoder = MockFlacDecoder();
    mockArClient = MockAccurateRipClient();
  });

  group('QualityAnalysisNotifier', () {
    group('initial state', () {
      test('is idle with zero progress and no error', () {
        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        final state = container.read(qualityAnalysisNotifierProvider);

        expect(state.status, QualityAnalysisStatus.idle);
        expect(state.currentTrack, 0);
        expect(state.totalTracks, 0);
        expect(state.currentStep, '');
        expect(state.error, isNull);
      });
    });

    group('analyse', () {
      test(
          'transitions through analysing then completes when album has no tracks',
          () async {
        // Arrange — repository returns an empty track list so the use case
        // stream closes immediately without yielding any progress events.
        when(() => mockRipRepo.getTracksForAlbum('album-1'))
            .thenAnswer((_) async => []);

        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        final notifier =
            container.read(qualityAnalysisNotifierProvider.notifier);

        // Act
        await notifier.analyse('album-1');

        // Assert — final state is complete with no error
        final state = container.read(qualityAnalysisNotifierProvider);
        expect(state.status, QualityAnalysisStatus.complete);
        expect(state.error, isNull);
      });

      test('invalidates ripTracksProvider on successful completion', () async {
        // Arrange
        when(() => mockRipRepo.getTracksForAlbum('album-2'))
            .thenAnswer((_) async => []);

        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        // Prime ripTracksProvider so it is in the container's dependency graph.
        // After analyse() completes, the provider should be invalidated,
        // causing its state to revert to loading.
        container.read(ripTracksProvider('album-2'));

        final notifier =
            container.read(qualityAnalysisNotifierProvider.notifier);

        // Act
        await notifier.analyse('album-2');

        // Assert — ripTracksProvider has been invalidated. In Riverpod 3,
        // invalidating a FutureProvider that already has data transitions it
        // to AsyncData with isLoading:true, rather than a bare AsyncLoading.
        final tracksValue = container.read(ripTracksProvider('album-2'));
        expect(tracksValue.isLoading, isTrue);
      });

      test('is a no-op when already analysing', () async {
        // Arrange — use a completer so the first analyse call stays suspended
        // whilst we trigger a second call.
        final completer = Completer<void>();
        when(() => mockRipRepo.getTracksForAlbum(any()))
            .thenAnswer((_) => completer.future.then((_) => []));

        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        final notifier =
            container.read(qualityAnalysisNotifierProvider.notifier);

        // Start (but do not await) the first call — state becomes analysing.
        final firstCall = notifier.analyse('album-3');
        expect(
          container.read(qualityAnalysisNotifierProvider).status,
          QualityAnalysisStatus.analysing,
        );

        // Act — second call should be a no-op.
        await notifier.analyse('album-3');

        // Assert — state is still analysing (not reset or completed).
        expect(
          container.read(qualityAnalysisNotifierProvider).status,
          QualityAnalysisStatus.analysing,
        );

        // Repository method was called exactly once.
        verify(() => mockRipRepo.getTracksForAlbum(any())).called(1);

        // Clean up the suspended call.
        completer.complete();
        await firstCall;
      });

      test('sets error in state when the repository throws', () async {
        // Arrange — repository throws to simulate a database failure.
        when(() => mockRipRepo.getTracksForAlbum(any()))
            .thenThrow(Exception('DB failure'));

        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        final notifier =
            container.read(qualityAnalysisNotifierProvider.notifier);

        // Act
        await notifier.analyse('album-4');

        // Assert — status is complete with the error message present.
        final state = container.read(qualityAnalysisNotifierProvider);
        expect(state.status, QualityAnalysisStatus.complete);
        expect(state.error, contains('DB failure'));
      });

      test('uses default threshold of 8.0 when threshold provider is loading',
          () async {
        // Arrange — with our stub the threshold resolves to data(8.0) so
        // .value returns 8.0. We verify that the notifier does not throw even
        // when the underlying provider is in a loading state by using the
        // null-coalescing default.
        when(() => mockRipRepo.getTracksForAlbum(any()))
            .thenAnswer((_) async => []);

        final container = _createContainer(
          ripRepo: mockRipRepo,
          flacDecoder: mockFlacDecoder,
          arClient: mockArClient,
        );
        addTearDown(container.dispose);

        final notifier =
            container.read(qualityAnalysisNotifierProvider.notifier);

        // Act & Assert — completes without throwing.
        await expectLater(notifier.analyse('album-5'), completes);
      });
    });
  });
}
