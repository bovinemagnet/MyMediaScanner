// Tests for Mp3Reader.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/mp3_reader.dart';

// ---------------------------------------------------------------------------
// Test fixture builder
// ---------------------------------------------------------------------------

/// Builds a minimal valid ID3v2.3 tag as raw bytes.
///
/// [textFrames] maps standard frame IDs (e.g. 'TIT2') to string values.
/// [txxxFrames] maps TXXX descriptions to their values.
///
/// No MPEG audio frames are appended, so [Mp3Metadata.durationMs] will be null
/// for all metadata-only tests.
Uint8List _buildId3v23Tag(
  Map<String, String> textFrames, {
  Map<String, String>? txxxFrames,
  int textEncoding = 3, // UTF-8
}) {
  final frameBuilder = BytesBuilder();

  // Text frames.
  for (final entry in textFrames.entries) {
    _appendTextFrame(frameBuilder, entry.key, entry.value, textEncoding);
  }

  // TXXX frames.
  if (txxxFrames != null) {
    for (final entry in txxxFrames.entries) {
      _appendTxxxFrame(frameBuilder, entry.key, entry.value, textEncoding);
    }
  }

  final frameBytes = frameBuilder.toBytes();

  // ID3v2.3 header (10 bytes).
  final header = BytesBuilder();
  // Magic
  header.add([0x49, 0x44, 0x33]);
  // Version 2.3.0
  header.add([0x03, 0x00]);
  // Flags: 0 (no extended header, no unsynchronisation)
  header.addByte(0x00);
  // Tag size as syncsafe integer.
  header.add(_syncsafe4(frameBytes.length));

  final output = BytesBuilder();
  output.add(header.toBytes());
  output.add(frameBytes);
  return output.toBytes();
}

void _appendTextFrame(
  BytesBuilder out,
  String frameId,
  String value,
  int encoding,
) {
  final textBytes = _encodeText(encoding, value);
  // Frame ID (4 bytes).
  out.add(frameId.codeUnits);
  // Size (4 bytes big-endian uint32): 1 byte encoding + text bytes.
  final frameSize = 1 + textBytes.length;
  out.add(_uint32BE(frameSize));
  // Flags (2 zero bytes).
  out.add([0x00, 0x00]);
  // Encoding byte.
  out.addByte(encoding);
  // Text bytes.
  out.add(textBytes);
}

void _appendTxxxFrame(
  BytesBuilder out,
  String description,
  String value,
  int encoding,
) {
  final descBytes = _encodeText(encoding, description);
  final valBytes = _encodeText(encoding, value);
  // Frame ID.
  out.add('TXXX'.codeUnits);
  // Size: encoding byte + description + null terminator + value.
  final frameSize = 1 + descBytes.length + 1 + valBytes.length;
  out.add(_uint32BE(frameSize));
  // Flags.
  out.add([0x00, 0x00]);
  // Encoding byte.
  out.addByte(encoding);
  // Description (null-terminated).
  out.add(descBytes);
  out.addByte(0x00);
  // Value.
  out.add(valBytes);
}

Uint8List _encodeText(int encoding, String text) {
  switch (encoding) {
    case 0: // ISO-8859-1: use raw code units (latin1 range only).
      return Uint8List.fromList(text.codeUnits);
    case 3: // UTF-8
    default:
      return Uint8List.fromList(utf8.encode(text));
  }
}

Uint8List _syncsafe4(int value) {
  return Uint8List(4)
    ..[0] = (value >> 21) & 0x7F
    ..[1] = (value >> 14) & 0x7F
    ..[2] = (value >> 7) & 0x7F
    ..[3] = value & 0x7F;
}

Uint8List _uint32BE(int value) {
  return Uint8List(4)
    ..[0] = (value >> 24) & 0xFF
    ..[1] = (value >> 16) & 0xFF
    ..[2] = (value >> 8) & 0xFF
    ..[3] = value & 0xFF;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Mp3Reader', () {
    test('readMetadataFromBytes returns null for empty bytes', () {
      final result = Mp3Reader.readMetadataFromBytes(Uint8List(0));
      expect(result, isNull);
    });

    test('readMetadataFromBytes returns null for non-ID3 data', () {
      // Random bytes that do not start with 'ID3'.
      final bytes = Uint8List.fromList([0x66, 0x4C, 0x61, 0x43, 0x00, 0x00]);
      final result = Mp3Reader.readMetadataFromBytes(bytes);
      expect(result, isNull);
    });

    test('readMetadataFromBytes extracts basic text frames', () {
      final bytes = _buildId3v23Tag({
        'TIT2': 'Test Song',
        'TPE1': 'Test Artist',
        'TALB': 'Test Album',
        'TPE2': 'Album Artist',
      });

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.title, equals('Test Song'));
      expect(result.artist, equals('Test Artist'));
      expect(result.album, equals('Test Album'));
      expect(result.albumArtist, equals('Album Artist'));
    });

    test('readMetadataFromBytes parses track number', () {
      final bytes = _buildId3v23Tag({'TRCK': '3'});

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.trackNumber, equals(3));
      expect(result.totalTracks, isNull);
    });

    test('readMetadataFromBytes parses track and total', () {
      final bytes = _buildId3v23Tag({'TRCK': '5/12'});

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.trackNumber, equals(5));
      expect(result.totalTracks, equals(12));
    });

    test('readMetadataFromBytes parses disc number', () {
      final bytes = _buildId3v23Tag({'TPOS': '2/3'});

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.discNumber, equals(2));
    });

    test('readMetadataFromBytes extracts barcode from TXXX BARCODE', () {
      final bytes = _buildId3v23Tag(
        {'TALB': 'Some Album'},
        txxxFrames: {'BARCODE': '0602547202888'},
      );

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.barcode, equals('0602547202888'));
    });

    test('readMetadataFromBytes extracts barcode from TXXX UPC', () {
      final bytes = _buildId3v23Tag(
        {'TALB': 'Another Album'},
        txxxFrames: {'UPC': '012345678901'},
      );

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.barcode, equals('012345678901'));
    });

    test('effectiveArtist prefers albumArtist over artist', () {
      final bytes = _buildId3v23Tag({
        'TPE1': 'Track Artist',
        'TPE2': 'Album Artist Name',
        'TALB': 'Compilation',
      });

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.effectiveArtist, equals('Album Artist Name'));
      expect(result.artist, equals('Track Artist'));
      expect(result.albumArtist, equals('Album Artist Name'));
    });

    test('readMetadataFromBytes handles ISO-8859-1 encoding', () {
      // Build a TIT2 frame using encoding byte 0 (ISO-8859-1).
      final bytes = _buildId3v23Tag(
        {'TIT2': 'Cafe Noir'},
        textEncoding: 0, // ISO-8859-1
      );

      final result = Mp3Reader.readMetadataFromBytes(bytes);

      expect(result, isNotNull);
      expect(result!.title, equals('Cafe Noir'));
    });

    test('readMetadataFromBytes returns null for too-small input', () {
      // 5 bytes — too small for a valid 10-byte ID3 header.
      final bytes = Uint8List.fromList([0x49, 0x44, 0x33, 0x03, 0x00]);
      final result = Mp3Reader.readMetadataFromBytes(bytes);
      expect(result, isNull);
    });
  });
}
