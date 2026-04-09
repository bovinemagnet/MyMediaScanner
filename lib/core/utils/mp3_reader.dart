/// Pure Dart MP3 ID3v2 tag reader.
///
/// Reads ID3v2.3 and ID3v2.4 tags from MP3 files. Does not decode audio.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Metadata extracted from an MP3 file's ID3v2 tags and MPEG audio header.
class Mp3Metadata {
  const Mp3Metadata({
    this.artist,
    this.albumArtist,
    this.album,
    this.title,
    this.trackNumber,
    this.discNumber,
    this.barcode,
    this.totalTracks,
    this.durationMs,
  });

  /// TPE1 — track artist.
  final String? artist;

  /// TPE2 — album artist.
  final String? albumArtist;

  /// TALB — album title.
  final String? album;

  /// TIT2 — track title.
  final String? title;

  /// TRCK — track number (the portion before '/').
  final int? trackNumber;

  /// TPOS — disc number (the portion before '/').
  final int? discNumber;

  /// TXXX frame whose description matches BARCODE, UPC, or EAN (case-insensitive).
  final String? barcode;

  /// TRCK — total tracks (the portion after '/').
  final int? totalTracks;

  /// Duration in milliseconds, derived from a Xing/Info VBR header or CBR
  /// bitrate calculation. May be null if the MPEG frame cannot be located or
  /// parsed.
  final int? durationMs;

  /// The effective artist — albumArtist takes precedence over artist.
  String? get effectiveArtist => albumArtist ?? artist;
}

/// Pure Dart MP3 ID3v2 tag reader.
///
/// Supports ID3v2.3 and ID3v2.4. Does not decode audio.
class Mp3Reader {
  const Mp3Reader._();

  /// Read metadata from the MP3 file at [filePath].
  ///
  /// Returns `null` if the file does not exist, is not a valid MP3/ID3v2 file,
  /// or cannot be read.
  static Future<Mp3Metadata?> readMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return readMetadataFromBytes(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Read metadata from raw [bytes] (useful for testing).
  ///
  /// Returns `null` if [bytes] does not start with a valid ID3v2.3/2.4 header.
  static Mp3Metadata? readMetadataFromBytes(Uint8List bytes) {
    try {
      return _parseId3v2(bytes);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Core parser
  // ---------------------------------------------------------------------------

  static Mp3Metadata? _parseId3v2(Uint8List bytes) {
    // Minimum: 10-byte ID3 header.
    if (bytes.length < 10) return null;

    // Magic: 'ID3'
    if (bytes[0] != 0x49 || bytes[1] != 0x44 || bytes[2] != 0x33) return null;

    final majorVersion = bytes[3];
    // Only ID3v2.3 and ID3v2.4 are supported.
    if (majorVersion != 3 && majorVersion != 4) return null;

    final flags = bytes[5];
    final hasExtendedHeader = (flags & 0x40) != 0;

    // Tag size is a syncsafe integer (4 × 7 bits).
    final tagSize = _readSyncsafe4(bytes, 6);
    if (tagSize < 0) return null;

    // Offset where the tag body begins (after the 10-byte header).
    var offset = 10;

    // Skip the extended header if present.
    if (hasExtendedHeader) {
      if (offset + 4 > bytes.length) return null;
      // Extended header size field encoding differs between v2.3 and v2.4, but
      // in both cases the first 4 bytes encode the extended header size
      // (including those 4 bytes in v2.4; excluding in v2.3). We read it as a
      // plain big-endian uint32 (v2.3) or syncsafe (v2.4) — using uint32 is
      // safe enough for skipping purposes as we only need an upper bound.
      final extSize = majorVersion == 4
          ? _readSyncsafe4(bytes, offset)
          : _readUint32BE(bytes, offset);
      if (extSize < 0) return null;
      offset += majorVersion == 4 ? extSize : extSize + 4;
    }

    final tagEnd = 10 + tagSize;
    if (tagEnd > bytes.length) return null;

    // Frame fields we accumulate.
    String? title;
    String? artist;
    String? albumArtist;
    String? album;
    int? trackNumber;
    int? totalTracks;
    int? discNumber;
    String? barcode;

    // Walk frames.
    while (offset + 10 <= tagEnd) {
      // Frame ID: 4 ASCII bytes. All-zero padding = end of tag.
      if (bytes[offset] == 0 &&
          bytes[offset + 1] == 0 &&
          bytes[offset + 2] == 0 &&
          bytes[offset + 3] == 0) {
        break;
      }

      final frameId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      offset += 4;

      // Frame size encoding differs between ID3v2.3 and ID3v2.4.
      final int frameSize;
      if (majorVersion == 4) {
        frameSize = _readSyncsafe4(bytes, offset);
      } else {
        frameSize = _readUint32BE(bytes, offset);
      }
      offset += 4;

      // Skip flags (2 bytes).
      offset += 2;

      if (frameSize <= 0) continue;
      if (offset + frameSize > tagEnd) break;

      final frameData = Uint8List.sublistView(bytes, offset, offset + frameSize);
      offset += frameSize;

      if (frameId == 'TXXX') {
        final desc = _parseTxxxFrame(frameData);
        if (desc != null) {
          final descUpper = desc.$1.toUpperCase();
          if ((descUpper == 'BARCODE' ||
                  descUpper == 'UPC' ||
                  descUpper == 'EAN') &&
              barcode == null) {
            barcode = desc.$2;
          }
        }
      } else if (frameId.startsWith('T')) {
        final text = _decodeTextFrame(frameData);
        if (text == null) continue;

        switch (frameId) {
          case 'TIT2':
            title ??= text;
          case 'TPE1':
            artist ??= text;
          case 'TPE2':
            albumArtist ??= text;
          case 'TALB':
            album ??= text;
          case 'TRCK':
            final parts = text.split('/');
            trackNumber ??= int.tryParse(parts[0].trim());
            if (parts.length > 1) {
              totalTracks ??= int.tryParse(parts[1].trim());
            }
          case 'TPOS':
            final parts = text.split('/');
            discNumber ??= int.tryParse(parts[0].trim());
        }
      }
    }

    // Attempt duration calculation from MPEG frames after the ID3 tag.
    final durationMs = _parseDuration(bytes, tagEnd);

    return Mp3Metadata(
      title: title,
      artist: artist,
      albumArtist: albumArtist,
      album: album,
      trackNumber: trackNumber,
      totalTracks: totalTracks,
      discNumber: discNumber,
      barcode: barcode,
      durationMs: durationMs,
    );
  }

  // ---------------------------------------------------------------------------
  // Text frame decoders
  // ---------------------------------------------------------------------------

  /// Decode a standard text frame (first byte = encoding, rest = text).
  static String? _decodeTextFrame(Uint8List data) {
    if (data.isEmpty) return null;
    final encoding = data[0];
    final textBytes = Uint8List.sublistView(data, 1);
    return _decodeString(encoding, textBytes);
  }

  /// Parse a TXXX frame. Returns (description, value) or null on failure.
  static (String, String)? _parseTxxxFrame(Uint8List data) {
    if (data.isEmpty) return null;
    final encoding = data[0];
    var pos = 1;

    // Find end of null-terminated description.
    final nullWidth = (encoding == 1 || encoding == 2) ? 2 : 1;
    int descEnd = pos;
    while (descEnd + nullWidth <= data.length) {
      if (nullWidth == 2) {
        if (data[descEnd] == 0 && data[descEnd + 1] == 0) break;
        descEnd += 2;
      } else {
        if (data[descEnd] == 0) break;
        descEnd++;
      }
    }

    final descBytes = Uint8List.sublistView(data, pos, descEnd);
    final description = _decodeString(encoding, descBytes);
    if (description == null) return null;

    final valueStart = descEnd + nullWidth;
    if (valueStart > data.length) return (description, '');

    final valueBytes = Uint8List.sublistView(data, valueStart);
    final value = _decodeString(encoding, valueBytes) ?? '';
    return (description, value);
  }

  /// Decode [bytes] using the ID3v2 text [encoding]:
  /// - 0: ISO-8859-1
  /// - 1: UTF-16 with BOM
  /// - 2: UTF-16BE (no BOM)
  /// - 3: UTF-8
  static String? _decodeString(int encoding, Uint8List bytes) {
    // Strip trailing null bytes before decoding.
    var end = bytes.length;
    if (encoding == 1 || encoding == 2) {
      // Strip trailing UTF-16 null pair.
      while (end >= 2 && bytes[end - 2] == 0 && bytes[end - 1] == 0) {
        end -= 2;
      }
    } else {
      while (end > 0 && bytes[end - 1] == 0) {
        end--;
      }
    }
    final trimmed = end == bytes.length ? bytes : Uint8List.sublistView(bytes, 0, end);

    switch (encoding) {
      case 0: // ISO-8859-1
        return String.fromCharCodes(trimmed);
      case 1: // UTF-16 with BOM
        if (trimmed.length < 2) return '';
        final bigEndian = trimmed[0] == 0xFE && trimmed[1] == 0xFF;
        return _decodeUtf16(trimmed, 2, bigEndian: bigEndian);
      case 2: // UTF-16BE (no BOM)
        return _decodeUtf16(trimmed, 0, bigEndian: true);
      case 3: // UTF-8
        return utf8.decode(trimmed, allowMalformed: true);
      default:
        return utf8.decode(trimmed, allowMalformed: true);
    }
  }

  static String _decodeUtf16(Uint8List bytes, int start, {required bool bigEndian}) {
    final codeUnits = <int>[];
    for (var i = start; i + 1 < bytes.length; i += 2) {
      final unit = bigEndian
          ? (bytes[i] << 8) | bytes[i + 1]
          : bytes[i] | (bytes[i + 1] << 8);
      codeUnits.add(unit);
    }
    return String.fromCharCodes(codeUnits);
  }

  // ---------------------------------------------------------------------------
  // Duration calculation
  // ---------------------------------------------------------------------------

  /// Attempt to compute duration (in ms) from MPEG audio frames starting at
  /// [audioOffset] in [bytes].
  static int? _parseDuration(Uint8List bytes, int audioOffset) {
    try {
      return _parseDurationUnsafe(bytes, audioOffset);
    } catch (_) {
      return null;
    }
  }

  static int? _parseDurationUnsafe(Uint8List bytes, int audioOffset) {
    // Scan for MPEG frame sync (0xFF followed by byte with top 3 bits set).
    var pos = audioOffset;
    while (pos + 4 <= bytes.length) {
      if (bytes[pos] == 0xFF && (bytes[pos + 1] & 0xE0) == 0xE0) break;
      pos++;
    }
    if (pos + 4 > bytes.length) return null;

    final header = _readUint32BE(bytes, pos);

    // Version: bits 19-20 (in the 32-bit header, bit 31 = MSB).
    // Header layout: AAAAAAAA AAABBCCD EEEEFFGH IIJJKLMM
    // A=sync, B=version, C=layer, D=protection, E=bitrate, F=sampleRate, ...
    final versionBits = (header >> 19) & 0x3;
    if (versionBits == 1) return null; // reserved
    final layerBits = (header >> 17) & 0x3;
    if (layerBits == 0) return null; // reserved
    if (layerBits != 1) return null; // only Layer III supported here

    final bitrateIndex = (header >> 12) & 0xF;
    final sampleRateIndex = (header >> 10) & 0x3;

    if (bitrateIndex == 0 || bitrateIndex == 0xF) return null; // free/bad
    if (sampleRateIndex == 3) return null; // reserved

    // Only handle MPEG1 Layer III for simplicity.
    if (versionBits != 3) return null; // 3 = MPEG1

    const bitrateTable = [
      0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0,
    ];
    const sampleRateTable = [44100, 48000, 32000, 0];

    final bitrateKbps = bitrateTable[bitrateIndex];
    final sampleRate = sampleRateTable[sampleRateIndex];
    if (bitrateKbps == 0 || sampleRate == 0) return null;

    // Samples per MPEG1 Layer III frame = 1152.
    const samplesPerFrame = 1152;

    // Side information size for MPEG1 stereo/joint stereo = 32, mono = 17.
    // Bit 6 of the second header byte: channel mode bits 9-8.
    final channelMode = (header >> 6) & 0x3;
    final sideInfoSize = channelMode == 3 ? 17 : 32; // mono vs others

    // Check for Xing/Info header at the expected offset.
    // Xing/Info starts after the 4-byte MPEG header + side info.
    final xingOffset = pos + 4 + sideInfoSize;
    if (xingOffset + 8 <= bytes.length) {
      final tag = String.fromCharCodes(bytes.sublist(xingOffset, xingOffset + 4));
      if (tag == 'Xing' || tag == 'Info') {
        // Xing flags field at offset +4.
        final xingFlags = _readUint32BE(bytes, xingOffset + 4);
        if (xingFlags & 0x01 != 0 && xingOffset + 12 <= bytes.length) {
          // Frame count present at offset +8.
          final frameCount = _readUint32BE(bytes, xingOffset + 8);
          if (frameCount > 0 && sampleRate > 0) {
            return (frameCount * samplesPerFrame * 1000) ~/ sampleRate;
          }
        }
      }
    }

    // CBR fallback: (fileSize - id3TagSize) * 8 / bitrateKbps / 1000 * 1000
    // Simplified: (audioBytes * 8) / (bitrateKbps * 1000) * 1000
    final audioBytes = bytes.length - audioOffset;
    if (audioBytes <= 0) return null;
    return (audioBytes * 8) ~/ (bitrateKbps * 1000) * 1000;
  }

  // ---------------------------------------------------------------------------
  // Binary helpers
  // ---------------------------------------------------------------------------

  /// Read a 4-byte syncsafe integer (7 bits per byte) from [bytes] at [offset].
  static int _readSyncsafe4(Uint8List bytes, int offset) {
    if (offset + 4 > bytes.length) return -1;
    return (bytes[offset] << 21) |
        (bytes[offset + 1] << 14) |
        (bytes[offset + 2] << 7) |
        bytes[offset + 3];
  }

  /// Read a 4-byte big-endian unsigned integer from [bytes] at [offset].
  static int _readUint32BE(Uint8List bytes, int offset) {
    if (offset + 4 > bytes.length) return -1;
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }
}
