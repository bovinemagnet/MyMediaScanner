/// Unified audio metadata reader supporting FLAC and MP3 formats.
///
/// Dispatches to format-specific readers based on file extension.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/core/utils/flac_reader.dart';
import 'package:mymediascanner/core/utils/mp3_reader.dart';

/// Audio file format.
enum AudioFormat { flac, mp3 }

/// Common metadata extracted from any supported audio file.
class AudioMetadata {
  const AudioMetadata({
    this.artist,
    this.albumArtist,
    this.album,
    this.title,
    this.trackNumber,
    this.discNumber,
    this.barcode,
    this.totalTracks,
    this.durationMs,
    required this.format,
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
  final AudioFormat format;

  /// The effective artist — albumArtist takes precedence over artist.
  String? get effectiveArtist => albumArtist ?? artist;
}

/// Reads metadata from FLAC and MP3 files via format-specific parsers.
class AudioMetadataReader {
  const AudioMetadataReader._();

  /// File extensions supported by this reader.
  static const supportedExtensions = {'.flac', '.mp3'};

  /// Read metadata from any supported audio file based on its extension.
  ///
  /// Returns `null` if the file is not a supported format or cannot be read.
  static Future<AudioMetadata?> readMetadata(String filePath) async {
    final ext = filePath.toLowerCase();
    if (ext.endsWith('.flac')) {
      return _fromFlac(filePath);
    } else if (ext.endsWith('.mp3')) {
      return _fromMp3(filePath);
    }
    return null;
  }

  static Future<AudioMetadata?> _fromFlac(String filePath) async {
    final m = await FlacReader.readMetadata(filePath);
    if (m == null) return null;
    return AudioMetadata(
      artist: m.artist,
      albumArtist: m.albumArtist,
      album: m.album,
      title: m.title,
      trackNumber: m.trackNumber,
      discNumber: m.discNumber,
      barcode: m.barcode,
      totalTracks: m.totalTracks,
      durationMs: m.durationMs,
      format: AudioFormat.flac,
    );
  }

  static Future<AudioMetadata?> _fromMp3(String filePath) async {
    final m = await Mp3Reader.readMetadata(filePath);
    if (m == null) return null;
    return AudioMetadata(
      artist: m.artist,
      albumArtist: m.albumArtist,
      album: m.album,
      title: m.title,
      trackNumber: m.trackNumber,
      discNumber: m.discNumber,
      barcode: m.barcode,
      totalTracks: m.totalTracks,
      durationMs: m.durationMs,
      format: AudioFormat.mp3,
    );
  }
}
