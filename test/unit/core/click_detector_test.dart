import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/click_detector.dart';

/// Build stereo 16-bit LE PCM from mono double samples (-1.0 to 1.0).
///
/// Both channels receive the same value.
Uint8List _buildStereoPcm(List<double> monoSamples) {
  final bytes = ByteData(monoSamples.length * 4); // 2 channels * 2 bytes
  for (var i = 0; i < monoSamples.length; i++) {
    final sample = (monoSamples[i] * 32767).round().clamp(-32768, 32767);
    bytes.setInt16(i * 4, sample, Endian.little); // left
    bytes.setInt16(i * 4 + 2, sample, Endian.little); // right
  }
  return bytes.buffer.asUint8List();
}

/// Generate a sine wave of given frequency and duration.
List<double> _sineWave(double frequency, double durationSeconds,
    {int sampleRate = 44100, double amplitude = 0.5}) {
  final sampleCount = (sampleRate * durationSeconds).round();
  return List.generate(sampleCount, (i) {
    return amplitude * math.sin(2 * math.pi * frequency * i / sampleRate);
  });
}

void main() {
  group('ClickDetector', () {
    test('clean sine wave produces zero clicks', () {
      final samples = _sineWave(440, 1.0);
      final pcm = _buildStereoPcm(samples);

      final result = detectClicks(pcm);

      expect(result.clickCount, equals(0));
      expect(result.clicks, isEmpty);
      expect(result.peakLevel, greaterThan(0));
      expect(result.peakLevel, lessThanOrEqualTo(1.0));
    });

    test('sine wave with injected spikes detects clicks', () {
      // Use low amplitude so the spike-to-RMS ratio easily exceeds the
      // threshold. Amplitude 0.1 gives RMS ~0.07; spike at 1.0 gives
      // ratio ~14, well above threshold 8.0.
      final samples = _sineWave(440, 1.0, amplitude: 0.1);

      // Inject 3 spikes at known positions (well separated)
      // At 0.2s (sample 8820), 0.5s (sample 22050), 0.8s (sample 35280)
      final spikePositions = [8820, 22050, 35280];
      for (final pos in spikePositions) {
        samples[pos] = 1.0; // Full-scale spike (much higher than 0.1 amplitude)
      }

      final pcm = _buildStereoPcm(samples);
      final result = detectClicks(pcm);

      expect(result.clickCount, equals(3));
      expect(result.clicks, hasLength(3));

      // Verify approximate timestamps (within 50ms tolerance)
      expect(result.clicks[0].timestampMs, closeTo(200, 50));
      expect(result.clicks[1].timestampMs, closeTo(500, 50));
      expect(result.clicks[2].timestampMs, closeTo(800, 50));

      // Severity should be positive
      for (final click in result.clicks) {
        expect(click.severity, greaterThan(0));
      }
    });

    test('silence produces zero clicks and no false positives', () {
      final samples = List.filled(44100, 0.0); // 1 second of silence
      final pcm = _buildStereoPcm(samples);

      final result = detectClicks(pcm);

      expect(result.clickCount, equals(0));
      expect(result.clicks, isEmpty);
      expect(result.peakLevel, equals(0));
    });

    test('empty PCM data returns zero clicks', () {
      final result = detectClicks(Uint8List(0));

      expect(result.clickCount, equals(0));
      expect(result.clicks, isEmpty);
      expect(result.peakLevel, equals(0));
    });

    test('peak level is correctly computed', () {
      // Generate a sine wave with known peak amplitude
      final samples = _sineWave(440, 0.5, amplitude: 0.75);
      final pcm = _buildStereoPcm(samples);

      final result = detectClicks(pcm);

      // Peak should be close to 0.75 (within rounding tolerance)
      expect(result.peakLevel, closeTo(0.75, 0.01));
    });
  });
}
