import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/rip_albums_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';

part 'rip_library_dao.g.dart';

@DriftAccessor(tables: [RipAlbumsTable, RipTracksTable])
class RipLibraryDao extends DatabaseAccessor<AppDatabase>
    with _$RipLibraryDaoMixin {
  RipLibraryDao(super.db);

  /// Stream of all non-deleted rip albums.
  Stream<List<RipAlbumsTableData>> watchAll() {
    return (select(ripAlbumsTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.albumTitle)]))
        .watch();
  }

  /// Stream of a single rip album linked to a media item.
  Stream<RipAlbumsTableData?> watchByMediaItemId(String mediaItemId) {
    return (select(ripAlbumsTable)
          ..where((t) =>
              t.mediaItemId.equals(mediaItemId) & t.deleted.equals(0)))
        .watchSingleOrNull();
  }

  /// Get a rip album by its library path (for re-scan matching).
  Future<RipAlbumsTableData?> getByLibraryPath(String path) {
    return (select(ripAlbumsTable)
          ..where((t) => t.libraryPath.equals(path))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Insert a new rip album.
  Future<void> insertAlbum(RipAlbumsTableCompanion companion) {
    return into(ripAlbumsTable).insert(companion);
  }

  /// Update an existing rip album.
  Future<void> updateAlbum(RipAlbumsTableCompanion companion) {
    return (update(ripAlbumsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  /// Soft-delete a rip album.
  Future<void> softDeleteAlbum(String id, int updatedAt) {
    return (update(ripAlbumsTable)..where((t) => t.id.equals(id))).write(
      RipAlbumsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Get tracks for a non-deleted rip album.
  Future<List<RipTracksTableData>> getTracksForAlbum(String ripAlbumId) {
    return (select(ripTracksTable)
          ..where((t) => t.ripAlbumId.equals(ripAlbumId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.discNumber),
            (t) => OrderingTerm.asc(t.trackNumber),
          ]))
        .get();
  }

  /// Insert multiple tracks.
  Future<void> insertTracks(List<RipTracksTableCompanion> companions) {
    return batch((b) {
      b.insertAll(ripTracksTable, companions);
    });
  }

  /// Hard-delete all tracks for a rip album (used on re-scan).
  Future<void> deleteTracksForAlbum(String ripAlbumId) {
    return (delete(ripTracksTable)
          ..where((t) => t.ripAlbumId.equals(ripAlbumId)))
        .go();
  }

  /// Stream of media item IDs that have linked rip albums.
  Stream<Set<String>> watchRippedMediaItemIds() {
    final query = selectOnly(ripAlbumsTable)
      ..addColumns([ripAlbumsTable.mediaItemId])
      ..where(ripAlbumsTable.deleted.equals(0) &
          ripAlbumsTable.mediaItemId.isNotNull());
    return query.watch().map((rows) =>
        rows.map((row) => row.read(ripAlbumsTable.mediaItemId)!).toSet());
  }

  /// Link a rip album to a media item.
  Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(ripAlbumsTable)..where((t) => t.id.equals(ripAlbumId)))
        .write(RipAlbumsTableCompanion(
      mediaItemId: Value(mediaItemId),
      updatedAt: Value(now),
    ));
  }

  /// Unlink a rip album from a media item.
  Future<void> unlinkFromMediaItem(String ripAlbumId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(ripAlbumsTable)..where((t) => t.id.equals(ripAlbumId)))
        .write(RipAlbumsTableCompanion(
      mediaItemId: const Value(null),
      updatedAt: Value(now),
    ));
  }

  /// Update quality-related columns for a single track.
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
  }) {
    return (update(ripTracksTable)..where((t) => t.id.equals(trackId))).write(
      RipTracksTableCompanion(
        accurateripStatus: Value(arStatus),
        accurateripConfidence: Value(arConfidence),
        accurateripCrc: Value(arCrc),
        peakLevel: Value(peakLevel),
        trackQuality: Value(trackQuality),
        copyCrc: Value(copyCrc),
        clickCount: Value(clickCount),
        ripLogSource: Value(ripLogSource),
        qualityCheckedAt: Value(qualityCheckedAt),
      ),
    );
  }

  /// Update the title of a single track.
  Future<void> updateTrackTitle(String trackId, String? title) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(ripTracksTable)..where((t) => t.id.equals(trackId))).write(
      RipTracksTableCompanion(
        title: Value(title),
        updatedAt: Value(now),
      ),
    );
  }

  /// Get all non-deleted rip albums (for matching).
  Future<List<RipAlbumsTableData>> getAllNonDeleted() {
    return (select(ripAlbumsTable)..where((t) => t.deleted.equals(0))).get();
  }

  /// Returns IDs of non-deleted albums that have at least one track
  /// without a quality check.
  Future<List<String>> getUnanalysedAlbumIds() async {
    final query = customSelect(
      'SELECT DISTINCT ra.id FROM rip_albums ra '
      'INNER JOIN rip_tracks rt ON rt.rip_album_id = ra.id '
      'WHERE ra.deleted = 0 AND rt.quality_checked_at IS NULL',
    );
    final rows = await query.get();
    return rows.map((row) => row.read<String>('id')).toList();
  }
}
