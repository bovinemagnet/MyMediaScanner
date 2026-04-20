import 'dart:async';
import 'dart:typed_data';

import 'package:dart_accuraterip/dart_accuraterip.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';
import 'package:mymediascanner/core/utils/mp3_reader.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:audio_defect_detector/audio_defect_detector.dart';
import 'package:mymediascanner/domain/usecases/analyse_rip_quality_usecase.dart';
import 'package:mymediascanner/domain/usecases/match_rips_usecase.dart';
import 'package:mymediascanner/domain/usecases/scan_rip_library_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

/// Stream of all non-deleted rip albums.
final allRipAlbumsProvider = StreamProvider<List<RipAlbum>>((ref) {
  return ref.watch(ripLibraryRepositoryProvider).watchAll();
});

/// Stream of the rip album linked to a specific media item.
final ripAlbumForItemProvider =
    StreamProvider.family<RipAlbum?, String>((ref, mediaItemId) {
  return ref.watch(ripLibraryRepositoryProvider).watchByMediaItemId(mediaItemId);
});

/// Tracks for a specific rip album.
final ripTracksProvider =
    FutureProvider.family<List<RipTrack>, String>((ref, ripAlbumId) {
  return ref.watch(ripLibraryRepositoryProvider).getTracksForAlbum(ripAlbumId);
});

/// Raw metadata tags read from an audio file (FLAC Vorbis Comments or MP3 ID3).
/// Keyed by file path. Returns all tag key-value pairs.
final trackRawTagsProvider =
    FutureProvider.family<Map<String, String>, String>((ref, filePath) async {
  final ext = filePath.toLowerCase();
  if (ext.endsWith('.flac')) {
    final meta = await FlacReader.readMetadata(filePath);
    return meta?.rawTags ?? {};
  } else if (ext.endsWith('.mp3')) {
    final meta = await Mp3Reader.readMetadata(filePath);
    if (meta == null) return {};
    // Build a tag map from Mp3Metadata fields
    return {
      if (meta.title != null) 'TITLE': meta.title!,
      if (meta.artist != null) 'ARTIST': meta.artist!,
      if (meta.albumArtist != null) 'ALBUMARTIST': meta.albumArtist!,
      if (meta.album != null) 'ALBUM': meta.album!,
      if (meta.trackNumber != null) 'TRACKNUMBER': meta.trackNumber.toString(),
      if (meta.totalTracks != null) 'TOTALTRACKS': meta.totalTracks.toString(),
      if (meta.discNumber != null) 'DISCNUMBER': meta.discNumber.toString(),
      if (meta.barcode != null) 'BARCODE': meta.barcode!,
    };
  }
  return {};
});

/// Set of media item IDs that have linked rip albums.
final rippedItemIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(ripLibraryRepositoryProvider).watchRippedMediaItemIds();
});

/// The configured FLAC library root path, stored in secure storage.
const _ripLibraryPathKey = 'rip_library_path';

final ripLibraryPathProvider =
    AsyncNotifierProvider<RipLibraryPathNotifier, String?>(
  RipLibraryPathNotifier.new,
);

class RipLibraryPathNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.watch(secureStorageProvider);
    return storage.read(key: _ripLibraryPathKey);
  }

  Future<void> setPath(String path) async {
    await ref.read(secureStorageProvider).write(
          key: _ripLibraryPathKey,
          value: path,
        );
    ref.invalidateSelf();
  }
}

/// Scan state for the rip library scanner.
enum RipScanStatus { idle, scanning, complete }

class RipScanState {
  const RipScanState({
    this.status = RipScanStatus.idle,
    this.albumsScanned = 0,
    this.totalDirectories = 0,
    this.currentDirectory = '',
    this.matchedCount = 0,
    this.error,
  });

  final RipScanStatus status;
  final int albumsScanned;
  final int totalDirectories;
  final String currentDirectory;
  final int matchedCount;
  final String? error;

  RipScanState copyWith({
    RipScanStatus? status,
    int? albumsScanned,
    int? totalDirectories,
    String? currentDirectory,
    int? matchedCount,
    String? error,
  }) =>
      RipScanState(
        status: status ?? this.status,
        albumsScanned: albumsScanned ?? this.albumsScanned,
        totalDirectories: totalDirectories ?? this.totalDirectories,
        currentDirectory: currentDirectory ?? this.currentDirectory,
        matchedCount: matchedCount ?? this.matchedCount,
        error: error,
      );
}

final ripScanNotifierProvider =
    NotifierProvider<RipScanNotifier, RipScanState>(RipScanNotifier.new);

class RipScanNotifier extends Notifier<RipScanState> {
  @override
  RipScanState build() => const RipScanState();

  Future<void> startScan(String rootPath) async {
    if (state.status == RipScanStatus.scanning) return;

    state = const RipScanState(status: RipScanStatus.scanning);

    try {
      final scanUseCase = ScanRipLibraryUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
      );

      await for (final progress in scanUseCase.execute(rootPath)) {
        state = state.copyWith(
          albumsScanned: progress.albumsScanned,
          totalDirectories: progress.totalDirectories,
          currentDirectory: progress.currentDirectory,
        );
      }

      // Run matching after scan
      final matchUseCase = MatchRipsUseCase(
        ripRepository: ref.read(ripLibraryRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      );
      final matchedCount = await matchUseCase.execute();

      state = state.copyWith(
        status: RipScanStatus.complete,
        matchedCount: matchedCount,
      );

      // Invalidate rip-related providers so UI updates
      ref.invalidate(rippedItemIdsProvider);
    } catch (e) {
      state = state.copyWith(
        status: RipScanStatus.complete,
        error: e.toString(),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Audio Quality Analysis providers (Phase B)
// ---------------------------------------------------------------------------

/// Secure storage key for the flac binary path override.
const _flacBinaryPathKey = 'flac_binary_path';

/// Secure storage key for click detection threshold.
const _clickSensitivityKey = 'click_detection_sensitivity';

/// Provider for the FLAC decoder instance.
final flacDecoderProvider = Provider<FlacDecoder>((ref) {
  final pathOverride =
      ref.watch(flacBinaryPathOverrideProvider).value;
  return FlacDecoder(
      binaryPath: (pathOverride != null && pathOverride.isNotEmpty)
          ? pathOverride
          : null);
});

/// Provider for the AccurateRip HTTP client.
///
/// The `dart_accuraterip` package has zero HTTP dependencies; we
/// supply a fetcher closure that runs the request through Dio, so
/// connection timeouts and the rest of the app's HTTP configuration
/// continue to apply.
final accurateRipClientProvider = Provider<AccurateRipClient>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.bytes,
  ));
  return AccurateRipClient(
    fetch: (uri) async {
      final response = await dio.getUri<List<int>>(uri);
      if (response.statusCode == 404 || response.data == null) {
        return Uint8List(0);
      }
      return Uint8List.fromList(response.data!);
    },
  );
});

/// FLAC binary path override, stored in secure storage.
final flacBinaryPathOverrideProvider =
    AsyncNotifierProvider<FlacBinaryPathNotifier, String?>(
  FlacBinaryPathNotifier.new,
);

class FlacBinaryPathNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.watch(secureStorageProvider);
    return storage.read(key: _flacBinaryPathKey);
  }

  Future<void> setPath(String path) async {
    await ref.read(secureStorageProvider).write(
          key: _flacBinaryPathKey,
          value: path,
        );
    ref.invalidateSelf();
  }
}

/// Click detection sensitivity, stored in secure storage.
final clickDetectionSensitivityProvider =
    AsyncNotifierProvider<ClickDetectionSensitivityNotifier, Sensitivity>(
  ClickDetectionSensitivityNotifier.new,
);

class ClickDetectionSensitivityNotifier extends AsyncNotifier<Sensitivity> {
  @override
  Future<Sensitivity> build() async {
    final storage = ref.watch(secureStorageProvider);
    final stored = await storage.read(key: _clickSensitivityKey);
    return Sensitivity.values
            .where((s) => s.name == stored)
            .firstOrNull ??
        Sensitivity.medium;
  }

  Future<void> setSensitivity(Sensitivity value) async {
    await ref.read(secureStorageProvider).write(
          key: _clickSensitivityKey,
          value: value.name,
        );
    ref.invalidateSelf();
  }
}

/// State for the quality analysis process.
enum QualityAnalysisStatus { idle, analysing, complete }

class QualityAnalysisState {
  const QualityAnalysisState({
    this.status = QualityAnalysisStatus.idle,
    this.currentTrack = 0,
    this.totalTracks = 0,
    this.currentStep = '',
    this.error,
  });

  final QualityAnalysisStatus status;
  final int currentTrack;
  final int totalTracks;
  final String currentStep;
  final String? error;

  QualityAnalysisState copyWith({
    QualityAnalysisStatus? status,
    int? currentTrack,
    int? totalTracks,
    String? currentStep,
    String? error,
  }) =>
      QualityAnalysisState(
        status: status ?? this.status,
        currentTrack: currentTrack ?? this.currentTrack,
        totalTracks: totalTracks ?? this.totalTracks,
        currentStep: currentStep ?? this.currentStep,
        error: error,
      );
}

/// Notifier managing audio quality analysis per album.
final qualityAnalysisNotifierProvider =
    NotifierProvider<QualityAnalysisNotifier, QualityAnalysisState>(
  QualityAnalysisNotifier.new,
);

class QualityAnalysisNotifier extends Notifier<QualityAnalysisState> {
  @override
  QualityAnalysisState build() => const QualityAnalysisState();

  /// Run the quality analysis pipeline for [ripAlbumId].
  ///
  /// [decoderOverride] lets callers (typically the bulk-analysis path)
  /// substitute a different [FlacDecoder] for the duration of this call,
  /// e.g. the system `flac` CLI on desktop where it is much faster than
  /// the pure-Dart fallback. When omitted, the standard
  /// [flacDecoderProvider] is used.
  Future<void> analyse(
    String ripAlbumId, {
    FlacDecoder? decoderOverride,
  }) async {
    if (state.status == QualityAnalysisStatus.analysing) return;

    state = const QualityAnalysisState(
        status: QualityAnalysisStatus.analysing);

    try {
      final sensitivity =
          ref.read(clickDetectionSensitivityProvider).value ??
              Sensitivity.medium;

      final useCase = AnalyseRipQualityUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
        flacDecoder: decoderOverride ?? ref.read(flacDecoderProvider),
        accurateRipClient: ref.read(accurateRipClientProvider),
        sensitivity: sensitivity,
      );

      await for (final progress in useCase.execute(ripAlbumId)) {
        state = state.copyWith(
          currentTrack: progress.currentTrack,
          totalTracks: progress.totalTracks,
          currentStep: progress.currentStep,
        );
      }

      state = state.copyWith(status: QualityAnalysisStatus.complete);

      // Invalidate track data so UI refreshes
      ref.invalidate(ripTracksProvider);
    } catch (e) {
      state = state.copyWith(
        status: QualityAnalysisStatus.complete,
        error: e.toString(),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Metadata editing providers
// ---------------------------------------------------------------------------

/// Provider for the [MetaflacWriter] instance.
///
/// Uses the pure-Dart `dart_metaflac` package, so no external binary is
/// required.
final metaflacWriterProvider =
    Provider<MetaflacWriter>((ref) => const MetaflacWriter());

/// State for rip metadata editing operations.
enum RipMetadataEditStatus { idle, saving, saved, error }

class RipMetadataEditState {
  const RipMetadataEditState({
    this.status = RipMetadataEditStatus.idle,
    this.error,
  });

  final RipMetadataEditStatus status;
  final String? error;

  RipMetadataEditState copyWith({
    RipMetadataEditStatus? status,
    String? error,
  }) =>
      RipMetadataEditState(
        status: status ?? this.status,
        error: error,
      );
}

/// Notifier managing rip metadata editing (writing tags to FLAC files).
final ripMetadataEditNotifierProvider =
    NotifierProvider<RipMetadataEditNotifier, RipMetadataEditState>(
  RipMetadataEditNotifier.new,
);

class RipMetadataEditNotifier extends Notifier<RipMetadataEditState> {
  @override
  RipMetadataEditState build() => const RipMetadataEditState();

  Future<void> saveAlbumMetadata({
    required RipAlbum album,
    required List<RipTrack> tracks,
    String? artist,
    String? albumTitle,
  }) async {
    if (state.status == RipMetadataEditStatus.saving) return;
    state = const RipMetadataEditState(status: RipMetadataEditStatus.saving);

    try {
      final useCase = EditRipMetadataUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
        writer: ref.read(metaflacWriterProvider),
      );
      await useCase.editAlbumMetadata(
        album: album,
        tracks: tracks,
        artist: artist,
        albumTitle: albumTitle,
      );
      state = const RipMetadataEditState(status: RipMetadataEditStatus.saved);
      ref.invalidate(allRipAlbumsProvider);
    } catch (e) {
      state = RipMetadataEditState(
        status: RipMetadataEditStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> saveTrackTitle({
    required RipTrack track,
    required String? title,
  }) async {
    if (state.status == RipMetadataEditStatus.saving) return;
    state = const RipMetadataEditState(status: RipMetadataEditStatus.saving);

    try {
      final useCase = EditRipMetadataUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
        writer: ref.read(metaflacWriterProvider),
      );
      await useCase.editTrackTitle(track: track, title: title);
      state = const RipMetadataEditState(status: RipMetadataEditStatus.saved);
      ref.invalidate(ripTracksProvider(track.ripAlbumId));
    } catch (e) {
      state = RipMetadataEditState(
        status: RipMetadataEditStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const RipMetadataEditState();
  }
}
