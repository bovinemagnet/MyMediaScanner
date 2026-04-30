import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

abstract interface class IRipLibraryRepository {
  Stream<List<RipAlbum>> watchAll();
  Stream<RipAlbum?> watchByMediaItemId(String mediaItemId);
  Future<RipAlbum?> getByLibraryPath(String path);
  Future<void> insertAlbum(RipAlbum album);
  Future<void> updateAlbum(RipAlbum album);
  Future<void> softDeleteAlbum(String id);
  Future<List<RipTrack>> getTracksForAlbum(String ripAlbumId);
  Future<void> insertTracks(List<RipTrack> tracks);
  Future<void> deleteTracksForAlbum(String ripAlbumId);

  /// Atomically insert a brand-new album with its tracks. Used by
  /// scan-rip-library so a crash between the album-insert and the
  /// track-insert can't leave a track-less orphan visible in the UI.
  Future<void> insertAlbumWithTracks(
      RipAlbum album, List<RipTrack> tracks);

  /// Atomically update an existing album and replace all of its tracks.
  /// Used by re-scan; the album row and the track set are committed
  /// together so a crash mid-rescan can't leave them out of sync.
  Future<void> updateAlbumAndReplaceTracks(
      RipAlbum album, List<RipTrack> tracks);
  Stream<Set<String>> watchRippedMediaItemIds();
  Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId);
  Future<void> unlinkFromMediaItem(String ripAlbumId);
  Future<List<RipAlbum>> getAllNonDeleted();
  Future<void> updateTrackTitle(String trackId, String? title);
  Future<void> updateGnudbDiscId(String ripAlbumId, String? discId);
  Future<void> updateTrackQuality(
    String trackId, {
    String? arStatus,
    int? arConfidence,
    String? arCrcV1,
    String? arCrcV2,
    double? peakLevel,
    double? trackQuality,
    String? copyCrc,
    int? clickCount,
    int? popCount,
    int? clippingCount,
    int? dropoutCount,
    double? defectConfidence,
    String? ripLogSource,
    int? qualityCheckedAt,
  });
}
