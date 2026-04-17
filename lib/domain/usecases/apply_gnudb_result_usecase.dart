/// Applies a resolved GnuDB result to the local library.
///
/// On success the caller has picked (or auto-selected) a [GnudbCandidate].
/// This use case fans the metadata out to three destinations:
///
/// 1. `rip_albums` (artist + album title) and `rip_tracks.title` rows via
///    [EditRipMetadataUseCase], which also writes ALBUMARTIST/ALBUM/TITLE
///    Vorbis Comment tags to FLAC files (MP3 tags are not supported by
///    the underlying `metaflac` tool — MP3 tracks are skipped silently).
/// 2. A new linked `MediaItem` in the main collection via
///    [SaveMediaItemUseCase], created only when the rip album is not
///    already linked to one.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/data/mappers/gnudb_mapper.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

/// Summary of what was written.
class GnudbApplyOutcome {
  const GnudbApplyOutcome({
    required this.albumUpdated,
    required this.tracksUpdated,
    required this.mediaItemCreated,
    required this.mediaItemId,
  });
  final bool albumUpdated;
  final int tracksUpdated;
  final bool mediaItemCreated;
  final String? mediaItemId;
}

/// Orchestrator for writing GnuDB metadata back to a rip album.
class ApplyGnudbResultUseCase {
  const ApplyGnudbResultUseCase({
    required EditRipMetadataUseCase editRipMetadata,
    required SaveMediaItemUseCase saveMediaItem,
    required IRipLibraryRepository repository,
  })  : _editRipMetadata = editRipMetadata,
        _saveMediaItem = saveMediaItem,
        _repository = repository;

  final EditRipMetadataUseCase _editRipMetadata;
  final SaveMediaItemUseCase _saveMediaItem;
  final IRipLibraryRepository _repository;

  /// Applies [candidate] to [album] and its [tracks]. Set
  /// [createMediaItemIfUnlinked] to `false` to skip the collection-creation
  /// step (e.g. when the caller wants to defer linking).
  Future<GnudbApplyOutcome> execute({
    required RipAlbum album,
    required List<RipTrack> tracks,
    required GnudbCandidate candidate,
    bool createMediaItemIfUnlinked = true,
  }) async {
    final dto = candidate.dto;

    // 1. Album-level fields + FLAC tags.
    await _editRipMetadata.editAlbumMetadata(
      album: album,
      tracks: tracks,
      artist: dto.artist,
      albumTitle: dto.albumTitle,
    );

    // 2. Per-track titles. dto.trackTitles is index-aligned (0-based) to the
    // sorted track list returned by GnuDB (matching CD track 1..N).
    final orderedTracks = [...tracks]
      ..sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
    int tracksUpdated = 0;
    for (final track in orderedTracks) {
      final idx = track.trackNumber - 1;
      if (idx < 0 || idx >= dto.trackTitles.length) continue;
      final newTitle = dto.trackTitles[idx];
      if (newTitle.isEmpty) continue;
      if (track.title == newTitle) continue;
      await _editRipMetadata.editTrackTitle(
        track: track,
        title: newTitle,
      );
      tracksUpdated++;
    }

    // 3. Optionally create a linked MediaItem.
    String? mediaItemId;
    bool mediaItemCreated = false;
    if (createMediaItemIfUnlinked && album.mediaItemId == null) {
      final metadata = GnudbMapper.toMetadataResult(
        dto,
        category: candidate.category,
      );
      final item = await _saveMediaItem.execute(metadata);
      await _repository.linkToMediaItem(album.id, item.id);
      mediaItemId = item.id;
      mediaItemCreated = true;
    } else {
      mediaItemId = album.mediaItemId;
    }

    return GnudbApplyOutcome(
      albumUpdated: true,
      tracksUpdated: tracksUpdated,
      mediaItemCreated: mediaItemCreated,
      mediaItemId: mediaItemId,
    );
  }
}
