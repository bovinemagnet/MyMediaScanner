import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/gnudb/cddb_disc_id_calculator.dart';

/// Tests for the CDDB Disc ID algorithm.
///
/// The CDDB Disc ID is a 32-bit integer encoded as eight lowercase hex
/// characters. It is calculated from per-track starting frame offsets
/// (LBA, including the standard 150-frame pregap) and the leadout frame
/// offset. Formula:
///
///   offset_seconds_i = frameOffsets[i] ~/ 75
///   sum_of_digits(x) = digit-sum of x's base-10 representation
///   n = Σ sum_of_digits(offset_seconds_i)   (across all tracks, not leadout)
///   t = (leadoutFrame ~/ 75) - offset_seconds_0
///   discid = ((n % 255) << 24) | (t << 8) | numTracks
///
/// Vectors below are hand-computed.
void main() {
  group('CddbDiscIdCalculator.calculate', () {
    test('three-track synthetic disc produces expected id', () {
      // Offsets in frames. 150 = 2s pregap. 15000 = 200s. 30000 = 400s.
      // Leadout 45000 = 600s.
      // cddb_sum(2)+cddb_sum(200)+cddb_sum(400) = 2+2+4 = 8
      // t = 600 - 2 = 598
      // discid = (8 << 24) | (598 << 8) | 3 = 0x08025603
      final id = CddbDiscIdCalculator.calculate(
        frameOffsets: const [150, 15000, 30000],
        leadoutFrame: 45000,
      );
      expect(id, '08025603');
    });

    test('ten-track synthetic disc produces expected id', () {
      // Ten tracks, 40s apart, starting at 150 frames; leadout at 30150.
      // Seconds: 2, 42, 82, 122, 162, 202, 242, 282, 322, 362
      // Digit sums: 2, 6, 10, 5, 9, 4, 8, 12, 7, 11 → n = 74
      // t = 402 - 2 = 400
      // discid = (74 << 24) | (400 << 8) | 10 = 0x4a01900a
      final id = CddbDiscIdCalculator.calculate(
        frameOffsets: const [
          150, 3150, 6150, 9150, 12150, 15150, 18150, 21150, 24150, 27150,
        ],
        leadoutFrame: 30150,
      );
      expect(id, '4a01900a');
    });

    test('single-track disc produces expected id', () {
      // Offset 150 = 2s, leadout 30000 = 400s.
      // n = 2, t = 398, tracks = 1
      // discid = (2 << 24) | (398 << 8) | 1 = 0x02018e01
      final id = CddbDiscIdCalculator.calculate(
        frameOffsets: const [150],
        leadoutFrame: 30000,
      );
      expect(id, '02018e01');
    });

    test('n wraps at 255 (digit-sum reduction)', () {
      // Craft offsets whose second-values have digit sums summing to 256.
      // 255 tracks is impractical; use two tracks whose digit-sums total 256.
      // Offset with seconds = 9999999... too large. Instead, verify the
      // modulus branch by direct arithmetic: construct a case where the
      // raw n is 256 and check the id's top byte is 1 (256 % 255 = 1).
      // Seconds with digit-sum 256: use 30 tracks each with digit-sum ≈ 9.
      // Simpler: synthesise 100 tracks at 10s apart starting at 150.
      final offsets = List<int>.generate(100, (i) => 150 + i * 750);
      // Digit sums of (2, 12, 22, …, 992): computed below.
      int expectedN = 0;
      for (var i = 0; i < 100; i++) {
        var s = 2 + i * 10;
        var ds = 0;
        while (s > 0) {
          ds += s % 10;
          s ~/= 10;
        }
        expectedN += ds;
      }
      const leadoutSec = 2 + 100 * 10; // one extra 10s past last offset
      const leadoutFrame = leadoutSec * 75;
      const t = leadoutSec - 2;
      final expectedTopByte = (expectedN % 255) & 0xFF;
      final expected =
          (expectedTopByte << 24) | (t << 8) | 100;
      final id = CddbDiscIdCalculator.calculate(
        frameOffsets: offsets,
        leadoutFrame: leadoutFrame,
      );
      expect(id, expected.toRadixString(16).padLeft(8, '0'));
    });

    test('throws when frameOffsets is empty', () {
      expect(
        () => CddbDiscIdCalculator.calculate(
          frameOffsets: const [],
          leadoutFrame: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when leadoutFrame is not after last offset', () {
      expect(
        () => CddbDiscIdCalculator.calculate(
          frameOffsets: const [150, 15000],
          leadoutFrame: 15000,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when offsets are not strictly ascending', () {
      expect(
        () => CddbDiscIdCalculator.calculate(
          frameOffsets: const [150, 15000, 10000],
          leadoutFrame: 20000,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('result is lowercase 8-char hex', () {
      final id = CddbDiscIdCalculator.calculate(
        frameOffsets: const [150, 15000, 30000],
        leadoutFrame: 45000,
      );
      expect(id.length, 8);
      expect(id, id.toLowerCase());
      expect(RegExp(r'^[0-9a-f]{8}$').hasMatch(id), isTrue);
    });
  });

  group('CddbDiscIdCalculator.cddbSum (digit sum)', () {
    test('returns 0 for 0', () {
      expect(CddbDiscIdCalculator.cddbSum(0), 0);
    });
    test('single-digit numbers return themselves', () {
      expect(CddbDiscIdCalculator.cddbSum(7), 7);
    });
    test('multi-digit numbers sum digits', () {
      expect(CddbDiscIdCalculator.cddbSum(123), 6);
      expect(CddbDiscIdCalculator.cddbSum(999), 27);
      expect(CddbDiscIdCalculator.cddbSum(2025), 9);
    });
  });
}
