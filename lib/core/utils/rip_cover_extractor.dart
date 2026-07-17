/// Album cover extraction for the rip library scanner.
///
/// Resolves one cover image per album directory — a conventional
/// folder image file first (user-curated art wins), falling back to
/// the first embedded FLAC PICTURE block — and writes a copy into the
/// local cover cache so artwork stays visible when the library volume
/// is unmounted. All failures degrade to `null`; artwork must never
/// fail a scan.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';

class RipCoverExtractor {
  const RipCoverExtractor._();

  /// Folder image base names, in priority order.
  static const _coverFileNames = ['cover', 'folder', 'album', 'front'];

  /// Accepted folder image extensions, in priority order per name.
  static const _coverFileExtensions = ['.jpg', '.jpeg', '.png'];

  /// Extracts the album cover for [albumDirPath] into [cacheDirPath].
  ///
  /// Returns the cached file's path, or null when no artwork was found
  /// or anything went wrong. The cache file name is the md5 of
  /// [relativePath] so rescans overwrite in place.
  static Future<String?> extractCover({
    required String albumDirPath,
    required String relativePath,
    required List<String> audioFilePaths,
    required String cacheDirPath,
  }) async {
    try {
      final source = await _folderImage(albumDirPath) ??
          await _embeddedPicture(audioFilePaths);
      if (source == null) return null;

      await Directory(cacheDirPath).create(recursive: true);
      final hash = md5.convert(utf8.encode(relativePath)).toString();
      final file = File('$cacheDirPath/$hash.${source.extension}');
      await file.writeAsBytes(source.bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<_CoverSource?> _folderImage(String albumDirPath) async {
    final dir = Directory(albumDirPath);
    if (!await dir.exists()) return null;

    // Index files by lowercase name so the name/extension priority
    // order below decides, not directory listing order.
    final byName = <String, File>{};
    await for (final entry in dir.list(followLinks: false)) {
      if (entry is File) {
        byName[entry.uri.pathSegments.last.toLowerCase()] = entry;
      }
    }

    for (final base in _coverFileNames) {
      for (final ext in _coverFileExtensions) {
        final file = byName['$base$ext'];
        if (file != null) {
          return _CoverSource(
            await file.readAsBytes(),
            ext == '.png' ? 'png' : 'jpg',
          );
        }
      }
    }
    return null;
  }

  static Future<_CoverSource?> _embeddedPicture(
      List<String> audioFilePaths) async {
    for (final path in audioFilePaths) {
      if (!path.toLowerCase().endsWith('.flac')) continue;
      final metadata = await FlacReader.readMetadata(path);
      final art = metadata?.coverArt;
      if (art != null && art.isNotEmpty) {
        final mime = metadata!.coverArtMimeType?.toLowerCase();
        return _CoverSource(art, mime == 'image/png' ? 'png' : 'jpg');
      }
    }
    return null;
  }
}

class _CoverSource {
  const _CoverSource(this.bytes, this.extension);

  final List<int> bytes;
  final String extension;
}
