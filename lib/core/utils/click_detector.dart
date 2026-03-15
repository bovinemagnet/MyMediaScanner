/// Statistical click/pop detector for PCM audio data.
///
/// Uses sliding-window RMS analysis to detect amplitude spikes that
/// indicate clicks or pops in ripped audio. Designed to run in an isolate
/// for CPU-intensive processing.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// A single detected click event.
class ClickEvent {
  const ClickEvent({
    required this.timestampMs,
    required this.severity,
  });

  /// Timestamp of the click in milliseconds from the start of the track.
  final int timestampMs;

  /// Severity as the ratio of the spike amplitude to the local RMS.
  final double severity;
}

/// Result of running click detection on a PCM audio stream.
class ClickDetectionResult {
  const ClickDetectionResult({
    required this.clickCount,
    required this.clicks,
    required this.peakLevel,
  });

  /// Total number of distinct click events detected.
  final int clickCount;

  /// Individual click events with timestamps and severity.
  final List<ClickEvent> clicks;

  /// Peak sample level as a fraction 0.0-1.0 (max |sample| / 32767).
  final double peakLevel;
}

/// Default window size in samples for RMS computation.
const _windowSize = 1024;

/// Window advance (50% overlap).
const _windowStep = 512;

/// Absolute RMS threshold below which a window is considered silent.
const _silenceThreshold = 100.0;

/// Default merge distance in samples (100ms at 44.1kHz).
const _mergeDistanceSamples = 4410;

/// Detect clicks and pops in raw PCM audio data.
///
/// [pcmData] must be 16-bit signed LE, stereo interleaved.
/// [threshold] — spike-to-RMS ratio to flag as a click (default 8.0).
/// [sampleRate] — audio sample rate in Hz (default 44100).
///
/// Returns a [ClickDetectionResult] with detected clicks and peak level.
ClickDetectionResult detectClicks(
  Uint8List pcmData, {
  double threshold = 8.0,
  int sampleRate = 44100,
}) {
  // Convert to 16-bit signed samples (mono mix: average L+R)
  final sampleCount = pcmData.lengthInBytes ~/ 2;
  if (sampleCount == 0) {
    return const ClickDetectionResult(
        clickCount: 0, clicks: [], peakLevel: 0);
  }

  final int16View = pcmData.buffer.asInt16List(
    pcmData.offsetInBytes,
    sampleCount,
  );

  // Mono-mix stereo pairs: (L + R) / 2
  final monoSamples = sampleCount ~/ 2;
  final mono = Int16List(monoSamples);
  int maxAbsSample = 0;

  for (var i = 0; i < monoSamples; i++) {
    final left = int16View[i * 2];
    final right = int16View[i * 2 + 1];
    final mixed = ((left + right) ~/ 2);
    mono[i] = mixed;
    final abs = mixed.abs();
    if (abs > maxAbsSample) maxAbsSample = abs;
  }

  final peakLevel = maxAbsSample / 32767.0;

  // Detect click candidates using sliding window
  final candidateSamples = <int>{}; // sample indices flagged as clicks

  for (var windowStart = 0;
      windowStart + _windowSize <= monoSamples;
      windowStart += _windowStep) {
    // Compute local RMS for this window
    double sumSquares = 0;
    for (var j = 0; j < _windowSize; j++) {
      final s = mono[windowStart + j].toDouble();
      sumSquares += s * s;
    }
    final localRms = math.sqrt(sumSquares / _windowSize);

    // Skip silent regions
    if (localRms < _silenceThreshold) continue;

    // Check each sample against threshold
    final spikeThreshold = threshold * localRms;
    for (var j = 0; j < _windowSize; j++) {
      final sampleIndex = windowStart + j;
      final absSample = mono[sampleIndex].abs().toDouble();
      if (absSample > spikeThreshold) {
        candidateSamples.add(sampleIndex);
      }
    }
  }

  if (candidateSamples.isEmpty) {
    return ClickDetectionResult(
        clickCount: 0, clicks: [], peakLevel: peakLevel);
  }

  // Sort candidate samples and merge adjacent detections
  final sorted = candidateSamples.toList()..sort();
  final clicks = <ClickEvent>[];

  var groupStart = sorted[0];
  var groupEnd = sorted[0];
  double groupMaxSeverity = 0;

  // Compute severity for the first candidate
  groupMaxSeverity = _severityAt(mono, sorted[0], threshold);

  for (var i = 1; i < sorted.length; i++) {
    final current = sorted[i];
    if (current - groupEnd <= _mergeDistanceSamples) {
      // Merge into current group
      groupEnd = current;
      final severity = _severityAt(mono, current, threshold);
      if (severity > groupMaxSeverity) groupMaxSeverity = severity;
    } else {
      // Emit the previous group
      final midSample = (groupStart + groupEnd) ~/ 2;
      clicks.add(ClickEvent(
        timestampMs: (midSample * 1000) ~/ sampleRate,
        severity: groupMaxSeverity,
      ));

      // Start new group
      groupStart = current;
      groupEnd = current;
      groupMaxSeverity = _severityAt(mono, current, threshold);
    }
  }

  // Emit the last group
  final midSample = (groupStart + groupEnd) ~/ 2;
  clicks.add(ClickEvent(
    timestampMs: (midSample * 1000) ~/ sampleRate,
    severity: groupMaxSeverity,
  ));

  return ClickDetectionResult(
    clickCount: clicks.length,
    clicks: clicks,
    peakLevel: peakLevel,
  );
}

/// Compute approximate severity for a sample by estimating local RMS
/// from a small neighbourhood.
double _severityAt(Int16List mono, int sampleIndex, double threshold) {
  final start = (sampleIndex - _windowSize ~/ 2).clamp(0, mono.length - 1);
  final end =
      (sampleIndex + _windowSize ~/ 2).clamp(0, mono.length);
  final count = end - start;
  if (count == 0) return 0;

  double sumSquares = 0;
  for (var i = start; i < end; i++) {
    final s = mono[i].toDouble();
    sumSquares += s * s;
  }
  final localRms = math.sqrt(sumSquares / count);
  if (localRms < _silenceThreshold) return 0;

  return mono[sampleIndex].abs() / localRms;
}
