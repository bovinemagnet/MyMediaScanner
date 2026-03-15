import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/accuraterip_crc.dart';

/// Helper to build PCM bytes from a list of uint32 sample values.
Uint8List _buildPcmFromUint32s(List<int> values) {
  final bytes = ByteData(values.length * 4);
  for (var i = 0; i < values.length; i++) {
    bytes.setUint32(i * 4, values[i], Endian.little);
  }
  return bytes.buffer.asUint8List();
}

void main() {
  group('AccurateRip CRC', () {
    test('v1 computes correct CRC for a small known sequence', () {
      // Simple test: 4 samples [1, 2, 3, 4]
      // v1: crc = 1*1 + 2*2 + 3*3 + 4*4 = 1 + 4 + 9 + 16 = 30
      final pcm = _buildPcmFromUint32s([1, 2, 3, 4]);
      final crc = computeArV1(pcm);
      expect(crc, equals(30));
    });

    test('v2 computes correct CRC for small values (same as v1 when no overflow)', () {
      // For small values, v2 should match v1 because the upper 32 bits of the
      // 64-bit multiply are zero.
      final pcm = _buildPcmFromUint32s([1, 2, 3, 4]);
      final crcV2 = computeArV2(pcm);
      expect(crcV2, equals(30));
    });

    test('v1 and v2 differ for large sample values', () {
      // Use values large enough that sample * multiplier overflows 32 bits
      // differently between v1 (truncate) and v2 (fold).
      // sample = 0xFFFFFFFF, multiplier = 2
      // v1: (0xFFFFFFFF * 2) & 0xFFFFFFFF = 0xFFFFFFFE
      // v2: mult = 0xFFFFFFFF * 2 = 0x1FFFFFFFE
      //     low32 = 0xFFFFFFFE, high32 = 0x1
      //     crc += 0xFFFFFFFE + 0x1 = 0xFFFFFFFF
      //
      // First sample (0xFFFFFFFF * 1):
      // v1: 0xFFFFFFFF
      // v2: mult = 0xFFFFFFFF, low=0xFFFFFFFF, high=0 => 0xFFFFFFFF
      //
      // Second sample:
      // v1: 0xFFFFFFFF + 0xFFFFFFFE = 0x1FFFFFFFD & 0xFFFFFFFF = 0xFFFFFFFD
      // v2: 0xFFFFFFFF + 0xFFFFFFFE + 1 = 0x1FFFFFFFE & 0xFFFFFFFF = 0xFFFFFFFE
      final pcm = _buildPcmFromUint32s([0xFFFFFFFF, 0xFFFFFFFF]);
      final crcV1 = computeArV1(pcm);
      final crcV2 = computeArV2(pcm);
      expect(crcV1, isNot(equals(crcV2)));
      expect(crcV1, equals(0xFFFFFFFD));
      expect(crcV2, equals(0xFFFFFFFE));
    });

    test('first-track skip omits first 2940 samples', () {
      // Create data with 2945 samples. With isFirstTrack, only last 5 are used.
      final values = List.generate(2945, (i) => i + 1);
      final pcm = _buildPcmFromUint32s(values);

      final crcNoSkip = computeArV1(pcm);
      final crcWithSkip = computeArV1(pcm, isFirstTrack: true);

      // Without skip: sum of (i+1)*value for all 2945 samples
      // With skip: sum starts at index 2940, multiplier starts at 1
      // samples[2940..2944] = [2941, 2942, 2943, 2944, 2945]
      // crc = 2941*1 + 2942*2 + 2943*3 + 2944*4 + 2945*5
      //     = 2941 + 5884 + 8829 + 11776 + 14725 = 44155
      expect(crcWithSkip, equals(44155));
      expect(crcNoSkip, isNot(equals(crcWithSkip)));
    });

    test('last-track skip omits last 2940 samples', () {
      // Create data with 2945 samples. With isLastTrack, only first 5 are used.
      final values = List.generate(2945, (i) => i + 1);
      final pcm = _buildPcmFromUint32s(values);

      final crcWithSkip = computeArV1(pcm, isLastTrack: true);

      // samples[0..4] = [1, 2, 3, 4, 5], multipliers = [1, 2, 3, 4, 5]
      // crc = 1*1 + 2*2 + 3*3 + 4*4 + 5*5 = 1 + 4 + 9 + 16 + 25 = 55
      expect(crcWithSkip, equals(55));
    });

    test('empty PCM data returns zero', () {
      final pcm = Uint8List(0);
      expect(computeArV1(pcm), equals(0));
      expect(computeArV2(pcm), equals(0));
    });
  });
}
