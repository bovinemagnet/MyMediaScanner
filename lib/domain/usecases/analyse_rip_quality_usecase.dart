/// Use case for analysing the audio quality of ripped FLAC tracks.
///
/// Implements a three-tier analysis pipeline:
/// 1. Parse rip log files (cheapest)
/// 2. Query AccurateRip database
/// 3. Statistical click/pop detection (most expensive)
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_accuraterip/dart_accuraterip.dart' as ar;
import 'package:audio_defect_detector/audio_defect_detector.dart' as add;
import 'package:dart_rip_log/dart_rip_log.dart' as rl;
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

/// Progress update emitted during quality analysis.
class QualityAnalysisProgress {
  const QualityAnalysisProgress({
    required this.currentTrack,
    required this.totalTracks,
    required this.currentStep,
  });

  final int currentTrack;
  final int totalTracks;
  final String currentStep;
}

/// Analyses the audio quality of all tracks in a rip album.
class AnalyseRipQualityUseCase {
  AnalyseRipQualityUseCase({
    required IRipLibraryRepository repository,
    required FlacDecoder flacDecoder,
    required ar.AccurateRipClient accurateRipClient,
    this.sensitivity = add.Sensitivity.medium,
  })  : _repository = repository,
        _flacDecoder = flacDecoder,
        _arClient = accurateRipClient;

  final IRipLibraryRepository _repository;
  final FlacDecoder _flacDecoder;
  final ar.AccurateRipClient _arClient;
  final add.Sensitivity sensitivity;

  /// Execute the analysis pipeline for the given album.
  ///
  /// Yields [QualityAnalysisProgress] updates as each track is processed.
  Stream<QualityAnalysisProgress> execute(String ripAlbumId) async* {
    final tracks = await _repository.getTracksForAlbum(ripAlbumId);
    if (tracks.isEmpty) return;

    final totalTracks = tracks.length;

    // Step 1: Try to parse a rip log file
    yield QualityAnalysisProgress(
      currentTrack: 0,
      totalTracks: totalTracks,
      currentStep: 'Parsing log',
    );

    final logResults = await _tryParseLog(tracks);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Apply log results where tracks were accurately ripped
    final tracksNeedingAnalysis = <RipTrack>[];
    for (final track in tracks) {
      final logResult = logResults
          ?.where((r) => r.trackNumber == track.trackNumber)
          .firstOrNull;

      if (logResult != null &&
          logResult.accurateRipStatus == rl.AccurateRipStatus.verified) {
        await _repository.updateTrackQuality(
          track.id,
          arStatus: 'verified',
          arConfidence: logResult.accurateRipConfidence,
          arCrcV1: logResult.accurateRipCrcV1,
          arCrcV2: logResult.accurateRipCrcV2,
          peakLevel: logResult.peakLevel,
          trackQuality: logResult.trackQuality,
          copyCrc: logResult.copyCrc,
          ripLogSource: logResult.logFormat.name.toUpperCase(),
          qualityCheckedAt: now,
        );
      } else if (logResult != null) {
        // Log exists but track not verified — still save log data, continue
        await _repository.updateTrackQuality(
          track.id,
          peakLevel: logResult.peakLevel,
          trackQuality: logResult.trackQuality,
          copyCrc: logResult.copyCrc,
          ripLogSource: logResult.logFormat.name.toUpperCase(),
        );
        tracksNeedingAnalysis.add(track);
      } else {
        tracksNeedingAnalysis.add(track);
      }
    }

    if (tracksNeedingAnalysis.isEmpty) return;

    // Step 2: Check flac availability
    final flacAvailable = await _flacDecoder.isAvailable();
    if (!flacAvailable) {
      // Cannot decode — mark all remaining as not_checked
      for (final track in tracksNeedingAnalysis) {
        await _repository.updateTrackQuality(
          track.id,
          arStatus: 'not_checked',
          qualityCheckedAt: now,
        );
      }
      return;
    }

    // Gather sample counts for disc ID computation
    final sampleCounts = <int>[];
    for (final track in tracks) {
      final metadata = await FlacReader.readMetadata(track.filePath);
      if (metadata?.totalSamples != null) {
        sampleCounts.add(metadata!.totalSamples!);
      } else if (metadata?.durationMs != null) {
        // Fallback when STREAMINFO totalSamples was missing/zero.
        sampleCounts.add((metadata!.durationMs! * 44100) ~/ 1000);
      } else {
        sampleCounts.add(0);
      }
    }

    // Compute disc ID and query AccurateRip (once for all tracks)
    ar.AccurateRipDiscResult? arResult;
    if (sampleCounts.every((c) => c > 0)) {
      yield QualityAnalysisProgress(
        currentTrack: 0,
        totalTracks: totalTracks,
        currentStep: 'Checking AccurateRip',
      );

      try {
        final discId =
            ar.AccurateRipDiscId.fromTrackSampleCounts(sampleCounts);
        arResult = await _arClient.queryDisc(discId);
      } catch (_) {
        // AccurateRip query failed — continue with click detection
      }
    }

    // Process each track that needs analysis
    for (var i = 0; i < tracksNeedingAnalysis.length; i++) {
      final track = tracksNeedingAnalysis[i];
      final trackIndex =
          tracks.indexWhere((t) => t.id == track.id);
      final isFirst = trackIndex == 0;
      final isLast = trackIndex == tracks.length - 1;

      yield QualityAnalysisProgress(
        currentTrack: i + 1,
        totalTracks: totalTracks,
        currentStep: 'Decoding track ${track.trackNumber}',
      );

      Uint8List pcmData;
      try {
        pcmData = await Isolate.run(() => _flacDecoder.decode(track.filePath));
      } catch (_) {
        await _repository.updateTrackQuality(
          track.id,
          arStatus: 'not_checked',
          qualityCheckedAt: now,
        );
        continue;
      }

      // Compute AR CRCs in isolate
      yield QualityAnalysisProgress(
        currentTrack: i + 1,
        totalTracks: totalTracks,
        currentStep: 'Computing checksums for track ${track.trackNumber}',
      );

      final crcResults = await Isolate.run(() {
        final v1 = ar.computeArV1(pcmData,
            isFirstTrack: isFirst, isLastTrack: isLast);
        final v2 = ar.computeArV2(pcmData,
            isFirstTrack: isFirst, isLastTrack: isLast);
        return (v1, v2);
      });

      final crcV1 = crcResults.$1;
      final crcV2 = crcResults.$2;

      // Check against AccurateRip results
      if (arResult != null) {
        final arTrack = arResult.tracks
            .where((t) => t.trackNumber == track.trackNumber)
            .firstOrNull;

        if (arTrack != null) {
          // AccurateRip entries carry a single CRC without a v1/v2 label;
          // let the entry match itself against both locally computed CRCs.
          final match = arTrack.entries
              .where((e) => e.matches(computedV1: crcV1, computedV2: crcV2))
              .firstOrNull;

          final v1Hex =
              crcV1.toRadixString(16).padLeft(8, '0').toUpperCase();
          final v2Hex =
              crcV2.toRadixString(16).padLeft(8, '0').toUpperCase();

          if (match != null) {
            await _repository.updateTrackQuality(
              track.id,
              arStatus: 'verified',
              arConfidence: match.confidence,
              arCrcV1: v1Hex,
              arCrcV2: v2Hex,
              qualityCheckedAt: now,
            );
            continue;
          } else {
            // CRC mismatch — all entries checked, none match
            await _repository.updateTrackQuality(
              track.id,
              arStatus: 'mismatch',
              arCrcV1: v1Hex,
              arCrcV2: v2Hex,
              qualityCheckedAt: now,
            );
            continue;
          }
        }
      }

      // Step 3: No AR data — run click detection
      yield QualityAnalysisProgress(
        currentTrack: i + 1,
        totalTracks: totalTracks,
        currentStep: 'Detecting clicks on track ${track.trackNumber}',
      );

      final clickResult = await Isolate.run(() {
        return add.analysePcm(
          pcmData,
          format: const add.PcmFormat(
            sampleRate: 44100,
            bitDepth: 16,
            channels: 2,
          ),
          config: add.DetectorConfig(sensitivity: sensitivity),
        );
      });

      await _repository.updateTrackQuality(
        track.id,
        arStatus: 'not_found',
        clickCount: clickResult.defects.length,
        qualityCheckedAt: now,
      );
    }
  }

  /// Try to find and parse a rip log file in the album directory.
  Future<List<rl.RipLogTrack>?> _tryParseLog(List<RipTrack> tracks) async {
    if (tracks.isEmpty) return null;

    // Get the album directory from the first track's path
    final firstTrackPath = tracks.first.filePath;
    final albumDir = File(firstTrackPath).parent;

    try {
      final entries = await albumDir.list().toList();
      for (final entry in entries) {
        if (entry is File && entry.path.toLowerCase().endsWith('.log')) {
          final content = await entry.readAsString();
          final log = rl.parseRipLog(content);
          if (log.tracks.isNotEmpty) return log.tracks;
        }
      }
    } catch (_) {
      // Directory not accessible or other IO error
    }

    return null;
  }
}
