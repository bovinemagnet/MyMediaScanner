import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';

/// Builds a minimal valid FLAC file as raw bytes.
///
/// Contains the fLaC magic, a STREAMINFO block, and optionally a
/// VORBIS_COMMENT block with the supplied [tags].
Uint8List buildFlacFixture({
  Map<String, String>? tags,
  int sampleRate = 44100,
  int totalSamples = 441000, // 10 seconds at 44100
  bool includeVorbisComment = true,
  bool isLastBlockStreamInfo = false,
}) {
  final builder = BytesBuilder();

  // Magic: fLaC
  builder.add([0x66, 0x4C, 0x61, 0x43]);

  // STREAMINFO block (type 0, 34 bytes)
  final streamInfo = _buildStreamInfoBlock(
    sampleRate: sampleRate,
    totalSamples: totalSamples,
    isLast: isLastBlockStreamInfo || !includeVorbisComment,
  );
  builder.add(streamInfo);

  // VORBIS_COMMENT block (type 4) if requested
  if (includeVorbisComment && tags != null) {
    final vorbisComment = _buildVorbisCommentBlock(tags, isLast: true);
    builder.add(vorbisComment);
  }

  return builder.toBytes();
}

Uint8List _buildStreamInfoBlock({
  required int sampleRate,
  required int totalSamples,
  bool isLast = false,
}) {
  final data = Uint8List(34);

  // Min/max block size (16 bits each) — use 4096
  data[0] = 0x10;
  data[1] = 0x00;
  data[2] = 0x10;
  data[3] = 0x00;

  // Min/max frame size (24 bits each) — zeros are fine
  // bytes 4-9 = 0

  // Sample rate (20 bits at bytes 10-12, top 4 bits of byte 12)
  data[10] = (sampleRate >> 12) & 0xFF;
  data[11] = (sampleRate >> 4) & 0xFF;
  data[12] = ((sampleRate & 0x0F) << 4);

  // Channels - 1 (3 bits) = 1 (stereo), bits per sample - 1 (5 bits) = 15 (16-bit)
  // These sit in the lower nibble of byte 12 and upper nibble of byte 13
  data[12] |= 0x01; // channels - 1 = 1 (stereo), top bit into lower nibble
  data[13] = 0xF0; // bps-1 = 15 (lower 4 of bps occupy upper 4 bits here) + top 4 of total samples

  // Total samples (36 bits): top 4 bits in lower nibble of byte 13,
  // lower 32 bits in bytes 14-17
  data[13] = (data[13] & 0xF0) | ((totalSamples >> 32) & 0x0F);
  data[14] = (totalSamples >> 24) & 0xFF;
  data[15] = (totalSamples >> 16) & 0xFF;
  data[16] = (totalSamples >> 8) & 0xFF;
  data[17] = totalSamples & 0xFF;

  // MD5 (bytes 18-33) — zeros

  // Build the block header + data
  final block = BytesBuilder();
  final blockType = isLast ? 0x80 : 0x00; // type 0, with/without last-block flag
  block.addByte(blockType);
  // Length = 34, encoded as 24-bit big-endian
  block.add([0x00, 0x00, 34]);
  block.add(data);
  return block.toBytes();
}

Uint8List _buildVorbisCommentBlock(
  Map<String, String> tags, {
  bool isLast = true,
}) {
  final payload = BytesBuilder();

  // Vendor string
  const vendor = 'test-encoder';
  final vendorBytes = vendor.codeUnits;
  payload.add(_uint32LE(vendorBytes.length));
  payload.add(vendorBytes);

  // Comment count
  payload.add(_uint32LE(tags.length));

  // Comments
  for (final entry in tags.entries) {
    final comment = '${entry.key}=${entry.value}';
    final commentBytes = comment.codeUnits;
    payload.add(_uint32LE(commentBytes.length));
    payload.add(commentBytes);
  }

  final payloadBytes = payload.toBytes();

  // Block header
  final block = BytesBuilder();
  final blockType = isLast ? (0x80 | 4) : 4;
  block.addByte(blockType);
  // Length as 24-bit big-endian
  block.addByte((payloadBytes.length >> 16) & 0xFF);
  block.addByte((payloadBytes.length >> 8) & 0xFF);
  block.addByte(payloadBytes.length & 0xFF);
  block.add(payloadBytes);
  return block.toBytes();
}

Uint8List _uint32LE(int value) {
  return Uint8List(4)
    ..[0] = value & 0xFF
    ..[1] = (value >> 8) & 0xFF
    ..[2] = (value >> 16) & 0xFF
    ..[3] = (value >> 24) & 0xFF;
}

void main() {
  group('FlacReader', () {
    test('extracts artist, album, title, and track number', () {
      final bytes = buildFlacFixture(tags: {
        'ARTIST': 'Test Artist',
        'ALBUM': 'Test Album',
        'TITLE': 'Test Track',
        'TRACKNUMBER': '3',
        'DISCNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.artist, equals('Test Artist'));
      expect(metadata.album, equals('Test Album'));
      expect(metadata.title, equals('Test Track'));
      expect(metadata.trackNumber, equals(3));
      expect(metadata.discNumber, equals(1));
    });

    test('ALBUMARTIST takes precedence over ARTIST', () {
      final bytes = buildFlacFixture(tags: {
        'ARTIST': 'Track Artist',
        'ALBUMARTIST': 'Album Artist',
        'ALBUM': 'Compilation',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.effectiveArtist, equals('Album Artist'));
      expect(metadata.artist, equals('Track Artist'));
      expect(metadata.albumArtist, equals('Album Artist'));
    });

    test('handles missing tags gracefully', () {
      final bytes = buildFlacFixture(tags: {
        'ALBUM': 'Only Album',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.album, equals('Only Album'));
      expect(metadata.artist, isNull);
      expect(metadata.title, isNull);
      expect(metadata.trackNumber, isNull);
      expect(metadata.discNumber, isNull);
      expect(metadata.barcode, isNull);
      expect(metadata.effectiveArtist, isNull);
    });

    test('extracts barcode from BARCODE tag', () {
      final bytes = buildFlacFixture(tags: {
        'BARCODE': '0602445123456',
        'ALBUM': 'With Barcode',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.barcode, equals('0602445123456'));
    });

    test('extracts barcode from UPC tag as fallback', () {
      final bytes = buildFlacFixture(tags: {
        'UPC': '012345678901',
        'ALBUM': 'With UPC',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.barcode, equals('012345678901'));
    });

    test('extracts total tracks from TOTALTRACKS', () {
      final bytes = buildFlacFixture(tags: {
        'TOTALTRACKS': '12',
        'TRACKNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.totalTracks, equals(12));
    });

    test('extracts total tracks from TRACKTOTAL as fallback', () {
      final bytes = buildFlacFixture(tags: {
        'TRACKTOTAL': '10',
        'TRACKNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.totalTracks, equals(10));
    });

    test('computes duration from STREAMINFO', () {
      // 44100 Hz, 441000 samples = 10 seconds = 10000 ms
      final bytes = buildFlacFixture(
        tags: {'TITLE': 'Duration Test'},
        sampleRate: 44100,
        totalSamples: 441000,
      );

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.durationMs, equals(10000));
    });

    test('rejects non-FLAC files', () {
      final bytes = Uint8List.fromList([0x49, 0x44, 0x33, 0x04]); // ID3 header

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNull);
    });

    test('rejects empty bytes', () {
      final metadata = FlacReader.readMetadataFromBytes(Uint8List(0));

      expect(metadata, isNull);
    });

    test('handles file with no VORBIS_COMMENT block', () {
      final bytes = buildFlacFixture(
        tags: null,
        includeVorbisComment: false,
        isLastBlockStreamInfo: true,
      );

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.artist, isNull);
      expect(metadata.album, isNull);
      // Duration should still be computed from STREAMINFO
      expect(metadata.durationMs, equals(10000));
    });
  });
}
