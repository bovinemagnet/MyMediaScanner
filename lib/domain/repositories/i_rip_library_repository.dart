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
  Stream<Set<String>> watchRippedMediaItemIds();
  Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId);
  Future<void> unlinkFromMediaItem(String ripAlbumId);
  Future<List<RipAlbum>> getAllNonDeleted();
  Future<void> updateTrackQuality(
    String trackId, {
    String? arStatus,
    int? arConfidence,
    String? arCrc,
    double? peakLevel,
    double? trackQuality,
    String? copyCrc,
    int? clickCount,
    String? ripLogSource,
    int? qualityCheckedAt,
  });
}
