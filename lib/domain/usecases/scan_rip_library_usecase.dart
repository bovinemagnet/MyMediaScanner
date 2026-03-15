import 'dart:io';
import 'dart:isolate';

import 'package:mymediascanner/core/utils/flac_reader.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:uuid/uuid.dart';

/// Progress reported during a rip library scan.
class RipScanProgress {
  const RipScanProgress({
    required this.albumsScanned,
    required this.totalDirectories,
    required this.currentDirectory,
  });

  final int albumsScanned;
  final int totalDirectories;
  final String currentDirectory;
}

/// Result of scanning a single album directory.
class _AlbumScanResult {
  const _AlbumScanResult({
    required this.directoryPath,
    required this.artist,
    required this.albumTitle,
    required this.barcode,
    required this.trackCount,
    required this.discCount,
    required this.totalSizeBytes,
    required this.tracks,
  });

  final String directoryPath;
  final String? artist;
  final String? albumTitle;
  final String? barcode;
  final int trackCount;
  final int discCount;
  final int totalSizeBytes;
  final List<_TrackScanResult> tracks;
}

class _TrackScanResult {
  const _TrackScanResult({
    required this.filePath,
    required this.discNumber,
    required this.trackNumber,
    required this.title,
    required this.durationMs,
    required this.fileSizeBytes,
  });

  final String filePath;
  final int discNumber;
  final int trackNumber;
  final String? title;
  final int? durationMs;
  final int fileSizeBytes;
}

/// Scans a local directory of ripped FLAC files and upserts rip albums
/// and tracks into the local database.
class ScanRipLibraryUseCase {
  const ScanRipLibraryUseCase({
    required IRipLibraryRepository repository,
  }) : _repo = repository;

  final IRipLibraryRepository _repo;
  static const _uuid = Uuid();

  /// Scans the library at [rootPath] and yields progress updates.
  ///
  /// After scanning completes, the stream closes. The caller should read
  /// the final progress event for summary statistics.
  Stream<RipScanProgress> execute(String rootPath) async* {
    // Phase 1: Scan files in an isolate to avoid blocking the UI
    final scanResults = await Isolate.run(() => _scanDirectory(rootPath));

    if (scanResults.isEmpty) {
      yield const RipScanProgress(
        albumsScanned: 0,
        totalDirectories: 0,
        currentDirectory: '',
      );
      return;
    }

    // Phase 2: Upsert results on the main isolate (needs DB access)
    final existingAlbums = await _repo.getAllNonDeleted();
    final existingByPath = {
      for (final a in existingAlbums) a.libraryPath: a,
    };

    // Track which paths we've seen, for soft-deleting removed directories
    final seenPaths = <String>{};

    var albumsScanned = 0;
    for (final result in scanResults) {
      albumsScanned++;
      yield RipScanProgress(
        albumsScanned: albumsScanned,
        totalDirectories: scanResults.length,
        currentDirectory: result.directoryPath,
      );

      seenPaths.add(result.directoryPath);
      final now = DateTime.now().millisecondsSinceEpoch;

      final existing = existingByPath[result.directoryPath];
      if (existing != null) {
        // Update existing album
        final updated = RipAlbum(
          id: existing.id,
          libraryPath: result.directoryPath,
          artist: result.artist,
          albumTitle: result.albumTitle,
          barcode: result.barcode,
          trackCount: result.trackCount,
          discCount: result.discCount,
          totalSizeBytes: result.totalSizeBytes,
          mediaItemId: existing.mediaItemId,
          lastScannedAt: now,
          updatedAt: now,
        );
        await _repo.updateAlbum(updated);

        // Replace tracks
        await _repo.deleteTracksForAlbum(existing.id);
        await _repo.insertTracks(_buildTracks(existing.id, result.tracks, now));
      } else {
        // Insert new album
        final albumId = _uuid.v7();
        final album = RipAlbum(
          id: albumId,
          libraryPath: result.directoryPath,
          artist: result.artist,
          albumTitle: result.albumTitle,
          barcode: result.barcode,
          trackCount: result.trackCount,
          discCount: result.discCount,
          totalSizeBytes: result.totalSizeBytes,
          lastScannedAt: now,
          updatedAt: now,
        );
        await _repo.insertAlbum(album);
        await _repo.insertTracks(_buildTracks(albumId, result.tracks, now));
      }
    }

    // Soft-delete albums whose directories were not found in the scan
    for (final existing in existingAlbums) {
      if (!seenPaths.contains(existing.libraryPath) && !existing.deleted) {
        await _repo.softDeleteAlbum(existing.id);
      }
    }
  }

  List<RipTrack> _buildTracks(
    String albumId,
    List<_TrackScanResult> tracks,
    int now,
  ) {
    return tracks
        .map((t) => RipTrack(
              id: _uuid.v7(),
              ripAlbumId: albumId,
              discNumber: t.discNumber,
              trackNumber: t.trackNumber,
              title: t.title,
              filePath: t.filePath,
              durationMs: t.durationMs,
              fileSizeBytes: t.fileSizeBytes,
              updatedAt: now,
            ))
        .toList();
  }

  /// Scans the directory tree for FLAC files. Runs in an isolate.
  static Future<List<_AlbumScanResult>> _scanDirectory(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return [];

    // Find all FLAC files
    final flacFiles = <File>[];
    await for (final entity
        in rootDir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.flac')) {
        flacFiles.add(entity);
      }
    }

    if (flacFiles.isEmpty) return [];

    // Group by parent directory
    final grouped = <String, List<File>>{};
    for (final file in flacFiles) {
      final parentPath = file.parent.path;
      grouped.putIfAbsent(parentPath, () => []).add(file);
    }

    final results = <_AlbumScanResult>[];

    for (final entry in grouped.entries) {
      final dirPath = entry.key;
      final files = entry.value;

      // Sort files by name for consistent ordering
      files.sort((a, b) => a.path.compareTo(b.path));

      // Read metadata from first track for album-level info
      FlacMetadata? firstTrackMeta;
      for (final file in files) {
        firstTrackMeta = await FlacReader.readMetadata(file.path);
        if (firstTrackMeta != null) break;
      }

      // Read all tracks
      final tracks = <_TrackScanResult>[];
      var totalSize = 0;
      var maxDisc = 1;

      for (final file in files) {
        final stat = await file.stat();
        final fileSize = stat.size;
        totalSize += fileSize;

        final meta = await FlacReader.readMetadata(file.path);
        final discNumber = meta?.discNumber ?? 1;
        if (discNumber > maxDisc) maxDisc = discNumber;

        tracks.add(_TrackScanResult(
          filePath: file.path,
          discNumber: discNumber,
          trackNumber: meta?.trackNumber ?? (tracks.length + 1),
          title: meta?.title,
          durationMs: meta?.durationMs,
          fileSizeBytes: fileSize,
        ));
      }

      // Make path relative to root for consistent matching
      final relativePath = dirPath.startsWith(rootPath)
          ? dirPath.substring(rootPath.length).replaceAll(RegExp(r'^[/\\]'), '')
          : dirPath;

      results.add(_AlbumScanResult(
        directoryPath: relativePath,
        artist: firstTrackMeta?.effectiveArtist,
        albumTitle: firstTrackMeta?.album,
        barcode: firstTrackMeta?.barcode,
        trackCount: tracks.length,
        discCount: maxDisc,
        totalSizeBytes: totalSize,
        tracks: tracks,
      ));
    }

    return results;
  }
}
