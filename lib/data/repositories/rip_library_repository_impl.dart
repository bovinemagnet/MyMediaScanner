import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/rip_library_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

class RipLibraryRepositoryImpl implements IRipLibraryRepository {
  RipLibraryRepositoryImpl({required RipLibraryDao ripLibraryDao})
      : _dao = ripLibraryDao;

  final RipLibraryDao _dao;

  @override
  Stream<List<RipAlbum>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_albumFromRow).toList());
  }

  @override
  Stream<RipAlbum?> watchByMediaItemId(String mediaItemId) {
    return _dao
        .watchByMediaItemId(mediaItemId)
        .map((row) => row != null ? _albumFromRow(row) : null);
  }

  @override
  Future<RipAlbum?> getByLibraryPath(String path) async {
    final row = await _dao.getByLibraryPath(path);
    return row != null ? _albumFromRow(row) : null;
  }

  @override
  Future<void> insertAlbum(RipAlbum album) async {
    await _dao.insertAlbum(RipAlbumsTableCompanion(
      id: Value(album.id),
      libraryPath: Value(album.libraryPath),
      artist: Value(album.artist),
      albumTitle: Value(album.albumTitle),
      barcode: Value(album.barcode),
      trackCount: Value(album.trackCount),
      discCount: Value(album.discCount),
      totalSizeBytes: Value(album.totalSizeBytes),
      mediaItemId: Value(album.mediaItemId),
      cueFilePath: Value(album.cueFilePath),
      gnudbDiscId: Value(album.gnudbDiscId),
      lastScannedAt: Value(album.lastScannedAt),
      updatedAt: Value(album.updatedAt),
    ));
  }

  @override
  Future<void> updateAlbum(RipAlbum album) async {
    await _dao.updateAlbum(RipAlbumsTableCompanion(
      id: Value(album.id),
      libraryPath: Value(album.libraryPath),
      artist: Value(album.artist),
      albumTitle: Value(album.albumTitle),
      barcode: Value(album.barcode),
      trackCount: Value(album.trackCount),
      discCount: Value(album.discCount),
      totalSizeBytes: Value(album.totalSizeBytes),
      mediaItemId: Value(album.mediaItemId),
      cueFilePath: Value(album.cueFilePath),
      gnudbDiscId: Value(album.gnudbDiscId),
      lastScannedAt: Value(album.lastScannedAt),
      updatedAt: Value(album.updatedAt),
    ));
  }

  @override
  Future<void> updateGnudbDiscId(String ripAlbumId, String? discId) async {
    await _dao.updateGnudbDiscId(ripAlbumId, discId);
  }

  @override
  Future<void> softDeleteAlbum(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.softDeleteAlbum(id, now);
  }

  @override
  Future<List<RipTrack>> getTracksForAlbum(String ripAlbumId) async {
    final rows = await _dao.getTracksForAlbum(ripAlbumId);
    return rows.map(_trackFromRow).toList();
  }

  @override
  Future<void> insertTracks(List<RipTrack> tracks) async {
    final companions = tracks.map(_trackCompanion).toList();
    await _dao.insertTracks(companions);
  }

  @override
  Future<void> deleteTracksForAlbum(String ripAlbumId) async {
    await _dao.deleteTracksForAlbum(ripAlbumId);
  }

  @override
  Future<void> insertAlbumWithTracks(
      RipAlbum album, List<RipTrack> tracks) async {
    await _dao.insertAlbumWithTracks(
      _albumCompanion(album),
      tracks.map(_trackCompanion).toList(),
    );
  }

  @override
  Future<void> updateAlbumAndReplaceTracks(
      RipAlbum album, List<RipTrack> tracks) async {
    await _dao.updateAlbumAndReplaceTracks(
      _albumCompanion(album),
      tracks.map(_trackCompanion).toList(),
    );
  }

  RipAlbumsTableCompanion _albumCompanion(RipAlbum album) =>
      RipAlbumsTableCompanion(
        id: Value(album.id),
        libraryPath: Value(album.libraryPath),
        artist: Value(album.artist),
        albumTitle: Value(album.albumTitle),
        barcode: Value(album.barcode),
        trackCount: Value(album.trackCount),
        discCount: Value(album.discCount),
        totalSizeBytes: Value(album.totalSizeBytes),
        mediaItemId: Value(album.mediaItemId),
        cueFilePath: Value(album.cueFilePath),
        gnudbDiscId: Value(album.gnudbDiscId),
        lastScannedAt: Value(album.lastScannedAt),
        updatedAt: Value(album.updatedAt),
      );

  RipTracksTableCompanion _trackCompanion(RipTrack t) =>
      RipTracksTableCompanion(
        id: Value(t.id),
        ripAlbumId: Value(t.ripAlbumId),
        discNumber: Value(t.discNumber),
        trackNumber: Value(t.trackNumber),
        title: Value(t.title),
        filePath: Value(t.filePath),
        durationMs: Value(t.durationMs),
        fileSizeBytes: Value(t.fileSizeBytes),
        updatedAt: Value(t.updatedAt),
        accurateripStatus: Value(t.accurateRipStatus),
        accurateripConfidence: Value(t.accurateRipConfidence),
        accurateripCrcV1: Value(t.accurateRipCrcV1),
        accurateripCrcV2: Value(t.accurateRipCrcV2),
        peakLevel: Value(t.peakLevel),
        trackQuality: Value(t.trackQuality),
        copyCrc: Value(t.copyCrc),
        clickCount: Value(t.clickCount),
        popCount: Value(t.popCount),
        clippingCount: Value(t.clippingCount),
        dropoutCount: Value(t.dropoutCount),
        defectConfidence: Value(t.defectConfidence),
        ripLogSource: Value(t.ripLogSource),
        qualityCheckedAt: Value(t.qualityCheckedAt),
      );

  @override
  Stream<Set<String>> watchRippedMediaItemIds() {
    return _dao.watchRippedMediaItemIds();
  }

  @override
  Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId) async {
    await _dao.linkToMediaItem(ripAlbumId, mediaItemId);
  }

  @override
  Future<void> unlinkFromMediaItem(String ripAlbumId) async {
    await _dao.unlinkFromMediaItem(ripAlbumId);
  }

  @override
  Future<List<RipAlbum>> getAllNonDeleted() async {
    final rows = await _dao.getAllNonDeleted();
    return rows.map(_albumFromRow).toList();
  }

  RipAlbum _albumFromRow(RipAlbumsTableData row) => RipAlbum(
        id: row.id,
        libraryPath: row.libraryPath,
        artist: row.artist,
        albumTitle: row.albumTitle,
        barcode: row.barcode,
        trackCount: row.trackCount,
        discCount: row.discCount,
        totalSizeBytes: row.totalSizeBytes,
        mediaItemId: row.mediaItemId,
        cueFilePath: row.cueFilePath,
        gnudbDiscId: row.gnudbDiscId,
        lastScannedAt: row.lastScannedAt,
        updatedAt: row.updatedAt,
        deleted: row.deleted == 1,
      );

  @override
  Future<void> updateTrackTitle(String trackId, String? title) async {
    await _dao.updateTrackTitle(trackId, title);
  }

  @override
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
  }) async {
    await _dao.updateTrackQuality(
      trackId,
      arStatus: arStatus,
      arConfidence: arConfidence,
      arCrcV1: arCrcV1,
      arCrcV2: arCrcV2,
      peakLevel: peakLevel,
      trackQuality: trackQuality,
      copyCrc: copyCrc,
      clickCount: clickCount,
      popCount: popCount,
      clippingCount: clippingCount,
      dropoutCount: dropoutCount,
      defectConfidence: defectConfidence,
      ripLogSource: ripLogSource,
      qualityCheckedAt: qualityCheckedAt,
    );
  }

  RipTrack _trackFromRow(RipTracksTableData row) => RipTrack(
        id: row.id,
        ripAlbumId: row.ripAlbumId,
        discNumber: row.discNumber,
        trackNumber: row.trackNumber,
        title: row.title,
        filePath: row.filePath,
        durationMs: row.durationMs,
        fileSizeBytes: row.fileSizeBytes,
        updatedAt: row.updatedAt,
        accurateRipStatus: row.accurateripStatus,
        accurateRipConfidence: row.accurateripConfidence,
        accurateRipCrcV1: row.accurateripCrcV1,
        accurateRipCrcV2: row.accurateripCrcV2,
        peakLevel: row.peakLevel,
        trackQuality: row.trackQuality,
        copyCrc: row.copyCrc,
        clickCount: row.clickCount,
        popCount: row.popCount,
        clippingCount: row.clippingCount,
        dropoutCount: row.dropoutCount,
        defectConfidence: row.defectConfidence,
        ripLogSource: row.ripLogSource,
        qualityCheckedAt: row.qualityCheckedAt,
      );
}
