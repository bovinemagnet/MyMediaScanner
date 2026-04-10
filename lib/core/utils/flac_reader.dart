/// FLAC metadata reader backed by the pure-Dart `dart_metaflac` package.
///
/// Extracts the fields the app cares about (common Vorbis comments plus a
/// duration derived from STREAMINFO) from a file path or an in-memory byte
/// buffer.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';

import 'package:dart_metaflac/dart_metaflac.dart';
import 'package:dart_metaflac/io.dart';

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
  ///
  /// When a key appears more than once the first occurrence wins, matching
  /// the previous implementation.
  final Map<String, String> rawTags;

  /// The effective artist — ALBUMARTIST takes precedence over ARTIST.
  String? get effectiveArtist => albumArtist ?? artist;
}

/// Reads FLAC metadata blocks via `dart_metaflac`.
class FlacReader {
  const FlacReader._();

  /// Read metadata from the FLAC file at [filePath].
  ///
  /// Returns `null` if the file is not a valid FLAC file or cannot be read.
  static Future<FlacMetadata?> readMetadata(String filePath) async {
    try {
      final doc = await FlacFileEditor.readFile(filePath);
      return _fromDocument(doc);
    } catch (_) {
      return null;
    }
  }

  /// Read metadata from raw bytes (useful for testing).
  static FlacMetadata? readMetadataFromBytes(Uint8List bytes) {
    try {
      final doc = FlacMetadataDocument.readFromBytes(bytes);
      return _fromDocument(doc);
    } catch (_) {
      return null;
    }
  }

  static FlacMetadata _fromDocument(FlacMetadataDocument doc) {
    final tags = _rawTagsFrom(doc.vorbisComment?.comments);

    final streamInfo = doc.streamInfo;
    int? durationMs;
    if (streamInfo.sampleRate > 0 && streamInfo.totalSamples > 0) {
      durationMs = (streamInfo.totalSamples * 1000) ~/ streamInfo.sampleRate;
    }

    final barcode = tags['BARCODE'] ?? tags['UPC'] ?? tags['EAN'];

    return FlacMetadata(
      artist: tags['ARTIST'],
      albumArtist: tags['ALBUMARTIST'],
      album: tags['ALBUM'],
      title: tags['TITLE'],
      trackNumber: _parseInt(tags['TRACKNUMBER']),
      discNumber: _parseInt(tags['DISCNUMBER']),
      barcode: barcode,
      totalTracks:
          _parseInt(tags['TOTALTRACKS']) ?? _parseInt(tags['TRACKTOTAL']),
      durationMs: durationMs,
      rawTags: tags,
    );
  }

  static Map<String, String> _rawTagsFrom(VorbisComments? comments) {
    if (comments == null) return const {};
    final out = <String, String>{};
    for (final entry in comments.entries) {
      out.putIfAbsent(entry.canonicalKey, () => entry.value);
    }
    return out;
  }

  static int? _parseInt(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}
