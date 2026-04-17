/// Pure implementation of the CDDB Disc ID hashing algorithm used by GnuDB
/// (and, historically, FreeDB). Given per-track LBA frame offsets and the
/// leadout frame offset, produces an 8-character lowercase hexadecimal
/// identifier.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

/// Calculator for CDDB Disc IDs.
class CddbDiscIdCalculator {
  const CddbDiscIdCalculator._();

  /// Frames per second on a CD (constant: 75 frames = 1 second).
  static const int framesPerSecond = 75;

  /// Returns the sum of the decimal digits of [n].
  ///
  /// Example: `cddbSum(123)` returns `6`. Negative inputs are treated as
  /// their absolute value; zero returns zero.
  static int cddbSum(int n) {
    var x = n.abs();
    var sum = 0;
    if (x == 0) return 0;
    while (x > 0) {
      sum += x % 10;
      x ~/= 10;
    }
    return sum;
  }

  /// Computes the CDDB Disc ID.
  ///
  /// [frameOffsets] contains the starting LBA frame offset of each track,
  /// including the conventional 150-frame (2-second) pregap baked in — i.e.
  /// track 1 normally starts at frame 150. Offsets must be strictly
  /// ascending.
  ///
  /// [leadoutFrame] is the LBA frame offset of the leadout (one past the
  /// final sample). Must be strictly greater than the last track offset.
  ///
  /// Returns the Disc ID as eight lowercase hexadecimal characters.
  static String calculate({
    required List<int> frameOffsets,
    required int leadoutFrame,
  }) {
    if (frameOffsets.isEmpty) {
      throw ArgumentError.value(
          frameOffsets, 'frameOffsets', 'must not be empty');
    }
    for (var i = 1; i < frameOffsets.length; i++) {
      if (frameOffsets[i] <= frameOffsets[i - 1]) {
        throw ArgumentError.value(
            frameOffsets, 'frameOffsets', 'must be strictly ascending');
      }
    }
    if (leadoutFrame <= frameOffsets.last) {
      throw ArgumentError.value(leadoutFrame, 'leadoutFrame',
          'must be strictly greater than the last track offset');
    }

    final numTracks = frameOffsets.length;
    final firstOffsetSeconds = frameOffsets.first ~/ framesPerSecond;
    final leadoutSeconds = leadoutFrame ~/ framesPerSecond;

    var n = 0;
    for (final frameOffset in frameOffsets) {
      final seconds = frameOffset ~/ framesPerSecond;
      n += cddbSum(seconds);
    }

    final t = leadoutSeconds - firstOffsetSeconds;
    final topByte = n % 255;
    final discId = ((topByte & 0xFF) << 24) |
        ((t & 0xFFFF) << 8) |
        (numTracks & 0xFF);

    return discId.toRadixString(16).padLeft(8, '0').toLowerCase();
  }
}
