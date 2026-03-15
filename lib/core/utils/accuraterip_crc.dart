/// AccurateRip CRC computation for v1 and v2 checksums.
///
/// Computes checksums from raw PCM data (16-bit signed LE, stereo interleaved).
/// Each uint32 naturally packs left and right samples as
/// `left_16bit | (right_16bit << 16)`.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';

/// Number of uint32 samples to skip at the start/end of first/last tracks.
const _skipSamples = 5 * 588; // 2940

/// Computes the AccurateRip v1 CRC for PCM data.
///
/// [pcmData] must be raw PCM bytes (16-bit signed LE, stereo interleaved).
/// [isFirstTrack] — skip the first 2940 uint32 samples.
/// [isLastTrack] — skip the last 2940 uint32 samples.
int computeArV1(
  Uint8List pcmData, {
  bool isFirstTrack = false,
  bool isLastTrack = false,
}) {
  final samples = pcmData.buffer.asUint32List(
    pcmData.offsetInBytes,
    pcmData.lengthInBytes ~/ 4,
  );

  final totalSamples = samples.length;
  final startIndex = isFirstTrack ? _skipSamples : 0;
  final endIndex =
      isLastTrack ? (totalSamples - _skipSamples).clamp(0, totalSamples) : totalSamples;

  int crc = 0;
  int multiplier = 1;

  for (var i = startIndex; i < endIndex; i++) {
    final sample = samples[i];
    crc = (crc + (sample * multiplier)) & 0xFFFFFFFF;
    multiplier++;
  }

  return crc;
}

/// Computes the AccurateRip v2 CRC for PCM data.
///
/// [pcmData] must be raw PCM bytes (16-bit signed LE, stereo interleaved).
/// [isFirstTrack] — skip the first 2940 uint32 samples.
/// [isLastTrack] — skip the last 2940 uint32 samples.
int computeArV2(
  Uint8List pcmData, {
  bool isFirstTrack = false,
  bool isLastTrack = false,
}) {
  final samples = pcmData.buffer.asUint32List(
    pcmData.offsetInBytes,
    pcmData.lengthInBytes ~/ 4,
  );

  final totalSamples = samples.length;
  final startIndex = isFirstTrack ? _skipSamples : 0;
  final endIndex =
      isLastTrack ? (totalSamples - _skipSamples).clamp(0, totalSamples) : totalSamples;

  int crc = 0;
  int multiplier = 1;

  for (var i = startIndex; i < endIndex; i++) {
    final sample = samples[i];
    // 64-bit multiply, fold upper 32 bits back
    final mult = sample * multiplier;
    crc = (crc + (mult & 0xFFFFFFFF) + ((mult >> 32) & 0xFFFFFFFF)) &
        0xFFFFFFFF;
    multiplier++;
  }

  return crc;
}
