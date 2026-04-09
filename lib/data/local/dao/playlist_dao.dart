import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/playlist_tracks_table.dart';
import 'package:mymediascanner/data/local/database/tables/playlists_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [PlaylistsTable, PlaylistTracksTable, RipTracksTable])
class PlaylistDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  Stream<List<PlaylistsTableData>> watchAll() {
    return (select(playlistsTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<PlaylistsTableData?> getById(String id) {
    return (select(playlistsTable)
          ..where((t) => t.id.equals(id) & t.deleted.equals(0)))
        .getSingleOrNull();
  }

  Future<void> insertPlaylist(PlaylistsTableCompanion companion) {
    return into(playlistsTable).insert(companion);
  }

  Future<void> updatePlaylist(PlaylistsTableCompanion companion) {
    return (update(playlistsTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  Future<void> softDeletePlaylist(String id, int updatedAt) {
    return (update(playlistsTable)..where((t) => t.id.equals(id))).write(
      PlaylistsTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<List<PlaylistTracksTableData>> getTracksForPlaylist(
      String playlistId) {
    return (select(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> insertPlaylistTracks(
      List<PlaylistTracksTableCompanion> companions) {
    return batch((b) {
      b.insertAll(playlistTracksTable, companions);
    });
  }

  Future<void> removeTrackFromPlaylist(String playlistTrackId) {
    return (delete(playlistTracksTable)
          ..where((t) => t.id.equals(playlistTrackId)))
        .go();
  }

  Future<void> clearPlaylistTracks(String playlistId) {
    return (delete(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId)))
        .go();
  }

  /// Atomically reorders tracks in a playlist by clearing and re-inserting
  /// within a single transaction.
  Future<void> reorderTracks(
      String playlistId, List<PlaylistTracksTableCompanion> companions) {
    return transaction(() async {
      await (delete(playlistTracksTable)
            ..where((t) => t.playlistId.equals(playlistId)))
          .go();
      await batch((b) {
        b.insertAll(playlistTracksTable, companions);
      });
    });
  }

  /// Get rip tracks for a playlist via join, ordered by sort order.
  Future<List<RipTracksTableData>> getRipTracksForPlaylist(String playlistId) {
    final query = select(ripTracksTable).join([
      innerJoin(
        playlistTracksTable,
        playlistTracksTable.ripTrackId.equalsExp(ripTracksTable.id),
      ),
    ])
      ..where(playlistTracksTable.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistTracksTable.sortOrder)]);
    return query.map((row) => row.readTable(ripTracksTable)).get();
  }
}
