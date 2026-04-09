/// Use case for editing FLAC rip metadata (artist, album title, track titles).
///
/// Writes tag changes to the actual FLAC files via metaflac, then updates
/// the local database to match.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/core/utils/metaflac_writer.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

/// Orchestrates writing metadata to FLAC files and updating the database.
class EditRipMetadataUseCase {
  const EditRipMetadataUseCase({
    required IRipLibraryRepository repository,
    required MetaflacWriter writer,
  })  : _repository = repository,
        _writer = writer;

  final IRipLibraryRepository _repository;
  final MetaflacWriter _writer;

  /// Edit album-level metadata (artist, album title).
  ///
  /// Updates ALBUMARTIST and ALBUM Vorbis Comment tags on every FLAC track
  /// file in the album, then updates the database record. Collects errors
  /// from individual file writes and throws a summary if any failed.
  Future<void> editAlbumMetadata({
    required RipAlbum album,
    required List<RipTrack> tracks,
    String? artist,
    String? albumTitle,
  }) async {
    final tags = <String, String>{};
    final removals = <String>[];

    if (artist != null) {
      if (artist.isEmpty) {
        removals.add('ALBUMARTIST');
      } else {
        tags['ALBUMARTIST'] = artist;
      }
    }
    if (albumTitle != null) {
      if (albumTitle.isEmpty) {
        removals.add('ALBUM');
      } else {
        tags['ALBUM'] = albumTitle;
      }
    }

    if (tags.isEmpty && removals.isEmpty) return;

    // Only write to FLAC files — metaflac doesn't support MP3.
    final flacTracks =
        tracks.where((t) => t.filePath.toLowerCase().endsWith('.flac'));

    final errors = <String>[];
    for (final track in flacTracks) {
      try {
        if (tags.isNotEmpty) {
          await _writer.setTags(track.filePath, tags);
        }
        for (final key in removals) {
          await _writer.removeTag(track.filePath, key);
        }
      } catch (e) {
        errors.add('${track.filePath}: $e');
      }
    }

    // Update DB even if some files failed (partial success).
    final now = DateTime.now().millisecondsSinceEpoch;
    await _repository.updateAlbum(album.copyWith(
      artist: artist?.isEmpty == true ? null : artist ?? album.artist,
      albumTitle:
          albumTitle?.isEmpty == true ? null : albumTitle ?? album.albumTitle,
      updatedAt: now,
    ));

    if (errors.isNotEmpty) {
      throw MetaflacWriteException(
        'Failed to update ${errors.length} file(s):\n${errors.join('\n')}',
      );
    }
  }

  /// Edit a single track's title.
  ///
  /// Updates the TITLE Vorbis Comment tag on the track's FLAC file,
  /// then updates the database record.
  Future<void> editTrackTitle({
    required RipTrack track,
    required String? title,
  }) async {
    // Only write to FLAC files.
    if (track.filePath.toLowerCase().endsWith('.flac')) {
      if (title != null && title.isNotEmpty) {
        await _writer.setTags(track.filePath, {'TITLE': title});
      } else {
        await _writer.removeTag(track.filePath, 'TITLE');
      }
    }

    await _repository.updateTrackTitle(
      track.id,
      title?.isEmpty == true ? null : title,
    );
  }
}
