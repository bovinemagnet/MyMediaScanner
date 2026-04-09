import 'dart:io';
import 'dart:typed_data';

/// Metadata extracted from a FLAC file's Vorbis comment and STREAMINFO blocks.
class FlacMetadata {
  const FlacMetadata({
    this.artist,
    this.albumArtist,
    this.album,
    this.title,
    this.trackNumber,
    this.discNumber,
    this.barcode,
    this.totalTracks,
    this.durationMs,
    this.rawTags = const {},
  });

  final String? artist;
  final String? albumArtist;
  final String? album;
  final String? title;
  final int? trackNumber;
  final int? discNumber;
  final String? barcode;
  final int? totalTracks;
  final int? durationMs;

  /// All Vorbis Comment tags as uppercase key → value pairs.
  final Map<String, String> rawTags;

  /// The effective artist — ALBUMARTIST takes precedence over ARTIST.
  String? get effectiveArtist => albumArtist ?? artist;
}

/// Pure Dart FLAC metadata parser.
///
/// Reads only the metadata blocks (STREAMINFO and VORBIS_COMMENT) from a FLAC
/// file. Does not decode audio data.
class FlacReader {
  const FlacReader._();

  /// Read metadata from the FLAC file at [filePath].
  ///
  /// Returns `null` if the file is not a valid FLAC file or cannot be read.
  static Future<FlacMetadata?> readMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final raf = await file.open(mode: FileMode.read);
      try {
        return await _parseFlac(raf);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Read metadata from raw bytes (useful for testing).
  static FlacMetadata? readMetadataFromBytes(Uint8List bytes) {
    try {
      return _parseFlacBytes(bytes);
    } catch (_) {
      return null;
    }
  }

  static Future<FlacMetadata?> _parseFlac(RandomAccessFile raf) async {
    // Read the magic bytes
    final magic = await raf.read(4);
    if (magic.length < 4 ||
        magic[0] != 0x66 || // f
        magic[1] != 0x4C || // L
        magic[2] != 0x61 || // a
        magic[3] != 0x43) {
      // C
      return null;
    }

    int? sampleRate;
    int? totalSamples;
    Map<String, String>? tags;

    // Parse metadata blocks
    var isLastBlock = false;
    while (!isLastBlock) {
      final headerBytes = await raf.read(4);
      if (headerBytes.length < 4) break;

      isLastBlock = (headerBytes[0] & 0x80) != 0;
      final blockType = headerBytes[0] & 0x7F;
      final blockLength =
          (headerBytes[1] << 16) | (headerBytes[2] << 8) | headerBytes[3];

      if (blockType == 0 && blockLength >= 34) {
        // STREAMINFO
        final data = await raf.read(blockLength);
        if (data.length >= 18) {
          final result = _parseStreamInfo(Uint8List.fromList(data));
          sampleRate = result.$1;
          totalSamples = result.$2;
        }
      } else if (blockType == 4) {
        // VORBIS_COMMENT
        final data = await raf.read(blockLength);
        tags = _parseVorbisComment(Uint8List.fromList(data));
      } else {
        // Skip this block
        await raf.setPosition(await raf.position() + blockLength);
      }
    }

    return _buildMetadata(sampleRate, totalSamples, tags);
  }

  static FlacMetadata? _parseFlacBytes(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // Check magic
    if (bytes[0] != 0x66 ||
        bytes[1] != 0x4C ||
        bytes[2] != 0x61 ||
        bytes[3] != 0x43) {
      return null;
    }

    var offset = 4;
    int? sampleRate;
    int? totalSamples;
    Map<String, String>? tags;

    var isLastBlock = false;
    while (!isLastBlock && offset + 4 <= bytes.length) {
      isLastBlock = (bytes[offset] & 0x80) != 0;
      final blockType = bytes[offset] & 0x7F;
      final blockLength = (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
      offset += 4;

      if (offset + blockLength > bytes.length) break;

      if (blockType == 0 && blockLength >= 18) {
        final data = Uint8List.sublistView(bytes, offset, offset + blockLength);
        final result = _parseStreamInfo(data);
        sampleRate = result.$1;
        totalSamples = result.$2;
      } else if (blockType == 4) {
        final data = Uint8List.sublistView(bytes, offset, offset + blockLength);
        tags = _parseVorbisComment(data);
      }

      offset += blockLength;
    }

    return _buildMetadata(sampleRate, totalSamples, tags);
  }

  /// Parse STREAMINFO block to extract sample rate and total samples.
  ///
  /// Bit layout (from offset 0 of block data):
  /// - 16 bits: min block size
  /// - 16 bits: max block size
  /// - 24 bits: min frame size
  /// - 24 bits: max frame size
  /// - 20 bits: sample rate (Hz)
  /// - 3 bits: channels - 1
  /// - 5 bits: bits per sample - 1
  /// - 36 bits: total samples
  static (int?, int?) _parseStreamInfo(Uint8List data) {
    if (data.length < 18) return (null, null);

    // Sample rate is at byte offset 10, starting at bit 0 of that byte,
    // spanning 20 bits across bytes 10, 11, and the top 4 bits of byte 12.
    final sampleRate =
        (data[10] << 12) | (data[11] << 4) | ((data[12] & 0xF0) >> 4);

    if (sampleRate == 0) return (sampleRate, null);

    // Total samples: starts at bit 4 of byte 13 (after channels + bps),
    // spanning 36 bits.
    // Byte 12 lower 4 bits: top bit is channel count overflow, then bps
    // Byte 13: lower 4 bits of bps-1 (1 bit) + top 4 bits of total samples
    // Actually the layout after sample rate (20 bits starting at byte 10):
    // - 3 bits channels-1 (bits 20-22 from byte 10)
    // - 5 bits bps-1 (bits 23-27)
    // - 36 bits total samples (bits 28-63)
    //
    // In terms of bytes:
    // byte 12: lower nibble = [chan(3)][bps_top1]
    // byte 13: [bps_low4][totalSamples_top4]
    // bytes 14-17: totalSamples_low32

    final totalSamplesHigh = data[13] & 0x0F;
    final totalSamplesLow = (data[14] << 24) |
        (data[15] << 16) |
        (data[16] << 8) |
        data[17];
    final totalSamples = (totalSamplesHigh << 32) | totalSamplesLow;

    return (sampleRate, totalSamples);
  }

  /// Parse a VORBIS_COMMENT block into a map of uppercase key → value pairs.
  static Map<String, String> _parseVorbisComment(Uint8List data) {
    final tags = <String, String>{};
    var offset = 0;

    if (data.length < 4) return tags;

    // Vendor string length (uint32 LE)
    final vendorLength = _readUint32LE(data, offset);
    offset += 4;
    if (offset + vendorLength > data.length) return tags;
    offset += vendorLength;

    if (offset + 4 > data.length) return tags;

    // Comment count (uint32 LE)
    final commentCount = _readUint32LE(data, offset);
    offset += 4;

    for (var i = 0; i < commentCount; i++) {
      if (offset + 4 > data.length) break;

      final commentLength = _readUint32LE(data, offset);
      offset += 4;

      if (offset + commentLength > data.length) break;

      final comment = String.fromCharCodes(
          data.sublist(offset, offset + commentLength));
      offset += commentLength;

      final equalsIndex = comment.indexOf('=');
      if (equalsIndex > 0) {
        final key = comment.substring(0, equalsIndex).toUpperCase();
        final value = comment.substring(equalsIndex + 1);
        // Keep the first occurrence of each tag
        tags.putIfAbsent(key, () => value);
      }
    }

    return tags;
  }

  static int _readUint32LE(Uint8List data, int offset) {
    return data[offset] |
        (data[offset + 1] << 8) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 24);
  }

  static FlacMetadata? _buildMetadata(
    int? sampleRate,
    int? totalSamples,
    Map<String, String>? tags,
  ) {
    int? durationMs;
    if (sampleRate != null && sampleRate > 0 && totalSamples != null) {
      durationMs = (totalSamples * 1000) ~/ sampleRate;
    }

    final barcode = tags?['BARCODE'] ?? tags?['UPC'] ?? tags?['EAN'];

    return FlacMetadata(
      artist: tags?['ARTIST'],
      albumArtist: tags?['ALBUMARTIST'],
      album: tags?['ALBUM'],
      title: tags?['TITLE'],
      trackNumber: _parseInt(tags?['TRACKNUMBER']),
      discNumber: _parseInt(tags?['DISCNUMBER']),
      barcode: barcode,
      totalTracks:
          _parseInt(tags?['TOTALTRACKS']) ?? _parseInt(tags?['TRACKTOTAL']),
      durationMs: durationMs,
      rawTags: tags ?? const {},
    );
  }

  static int? _parseInt(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}
