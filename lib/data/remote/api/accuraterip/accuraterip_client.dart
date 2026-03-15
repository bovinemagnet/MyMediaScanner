/// AccurateRip database client for verifying CD rip integrity.
///
/// Queries the AccurateRip online database to verify that ripped tracks
/// match known-good checksums from other users' rips.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Identifies a disc in the AccurateRip database.
class AccurateRipDiscId {
  const AccurateRipDiscId({
    required this.discId1,
    required this.discId2,
    required this.cddbDiscId,
    required this.trackCount,
  });

  final int discId1;
  final int discId2;
  final int cddbDiscId;
  final int trackCount;

  /// Compute a disc ID from track sample counts.
  ///
  /// [trackSampleCounts] — total stereo samples per track (from FLAC STREAMINFO).
  /// [sampleRate] — sample rate in Hz (typically 44100).
  ///
  /// Track offsets are in CD sectors (1 sector = 588 stereo samples).
  /// AccurateRip adds 150 sectors (the standard CD lead-in) to each offset.
  static AccurateRipDiscId computeDiscId(
    List<int> trackSampleCounts, {
    int sampleRate = 44100,
  }) {
    final trackCount = trackSampleCounts.length;

    // Compute track offsets in sectors (sector = 588 stereo samples)
    final offsets = <int>[0]; // Track 1 starts at sector 0
    for (var i = 0; i < trackCount - 1; i++) {
      offsets.add(offsets[i] + (trackSampleCounts[i] ~/ 588));
    }
    // Lead-out offset
    final leadOutOffset =
        offsets.last + (trackSampleCounts.last ~/ 588);

    // discId1: sum of (offset + 150) for all tracks + (leadOutOffset + 150)
    int id1 = 0;
    for (final offset in offsets) {
      id1 += offset + 150;
    }
    id1 += leadOutOffset + 150;
    id1 &= 0xFFFFFFFF;

    // discId2: sum of (offset + 150) * (trackIndex + 1) for all tracks
    // + (leadOutOffset + 150) * (trackCount + 1)
    int id2 = 0;
    for (var i = 0; i < offsets.length; i++) {
      id2 += (offsets[i] + 150) * (i + 1);
    }
    id2 += (leadOutOffset + 150) * (trackCount + 1);
    id2 &= 0xFFFFFFFF;

    // CDDB disc ID
    int digitSumTotal = 0;
    for (final offset in offsets) {
      var seconds = (offset + 150) ~/ 75;
      while (seconds > 0) {
        digitSumTotal += seconds % 10;
        seconds ~/= 10;
      }
    }
    final totalSeconds =
        (leadOutOffset + 150) ~/ 75 - (offsets[0] + 150) ~/ 75;
    final n = digitSumTotal % 0xFF;
    final cddbId = ((n & 0xFF) << 24) | ((totalSeconds & 0xFFFF) << 8) | (trackCount & 0xFF);

    return AccurateRipDiscId(
      discId1: id1,
      discId2: id2,
      cddbDiscId: cddbId,
      trackCount: trackCount,
    );
  }
}

/// Result of querying the AccurateRip database for a disc.
class AccurateRipDiscResult {
  const AccurateRipDiscResult({required this.tracks});

  /// Per-track results, indexed by track number (1-based).
  final List<AccurateRipTrackResult> tracks;
}

/// AccurateRip data for a single track across multiple pressings.
class AccurateRipTrackResult {
  const AccurateRipTrackResult({
    required this.trackNumber,
    required this.entries,
  });

  final int trackNumber;

  /// One entry per pressing/submission in the database.
  final List<AccurateRipEntry> entries;
}

/// A single AccurateRip entry from one pressing of a disc.
class AccurateRipEntry {
  const AccurateRipEntry({
    required this.confidence,
    required this.crcV1,
    required this.crcV2,
  });

  final int confidence;
  final int crcV1;
  final int crcV2;
}

/// Client for querying the AccurateRip HTTP database.
class AccurateRipClient {
  AccurateRipClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Query the AccurateRip database for a disc.
  ///
  /// Returns `null` if the disc is not found (HTTP 404) or the response
  /// cannot be parsed.
  Future<AccurateRipDiscResult?> queryDisc(AccurateRipDiscId discId) async {
    final url = _buildUrl(discId);

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 404 || response.data == null) {
        return null;
      }

      return _parseResponse(
          Uint8List.fromList(response.data!), discId.trackCount);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static String _buildUrl(AccurateRipDiscId discId) {
    final hex1 = discId.discId1.toRadixString(16).padLeft(8, '0');
    final hex2 = discId.discId2.toRadixString(16).padLeft(8, '0');
    final hexCddb = discId.cddbDiscId.toRadixString(16).padLeft(8, '0');
    final tc = discId.trackCount.toString().padLeft(3, '0');

    // Path components derived from discId1 hex
    final a = hex1[7]; // last hex char
    final b = hex1.substring(6, 8); // second-to-last + last
    final c = hex1.substring(5, 8); // third-to-last + second-to-last + last

    return 'http://www.accuraterip.com/accuraterip/$a/$b/$c/'
        'dBAR-$tc-$hex1-$hex2-$hexCddb.bin';
  }

  static AccurateRipDiscResult? _parseResponse(
      Uint8List data, int expectedTrackCount) {
    if (data.isEmpty) return null;

    // Collect all entries per track across chunks
    final trackEntries = <int, List<AccurateRipEntry>>{};

    var offset = 0;
    while (offset < data.length) {
      // Each chunk: 1 byte trackCount + 4 bytes discId1 + 4 bytes discId2
      // + 4 bytes cddbDiscId + (trackCount * 9) bytes of track data
      if (offset + 13 > data.length) break;

      final chunkTrackCount = data[offset];
      offset += 1;

      // Skip discId1, discId2, cddbDiscId (4+4+4 = 12 bytes)
      offset += 12;

      final trackDataSize = chunkTrackCount * 9;
      if (offset + trackDataSize > data.length) break;

      for (var t = 0; t < chunkTrackCount; t++) {
        final confidence = data[offset];
        offset += 1;

        final crcV1 = _readUint32LE(data, offset);
        offset += 4;

        final crcV2 = _readUint32LE(data, offset);
        offset += 4;

        final trackNumber = t + 1;
        trackEntries.putIfAbsent(trackNumber, () => []);
        trackEntries[trackNumber]!.add(AccurateRipEntry(
          confidence: confidence,
          crcV1: crcV1,
          crcV2: crcV2,
        ));
      }
    }

    if (trackEntries.isEmpty) return null;

    final tracks = trackEntries.entries
        .map((e) => AccurateRipTrackResult(
              trackNumber: e.key,
              entries: e.value,
            ))
        .toList()
      ..sort((a, b) => a.trackNumber.compareTo(b.trackNumber));

    return AccurateRipDiscResult(tracks: tracks);
  }

  static int _readUint32LE(Uint8List data, int offset) {
    return data[offset] |
        (data[offset + 1] << 8) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 24);
  }
}
