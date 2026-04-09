import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late PlaylistDao dao;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.playlistDao;
  });

  tearDown(() => db.close());

  /// Helper to insert a rip album (no media item FK required).
  Future<void> insertRipAlbum(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.ripAlbumsTable).insert(RipAlbumsTableCompanion(
          id: Value(id),
          libraryPath: Value('Artist/$id'),
          trackCount: const Value(2),
          totalSizeBytes: const Value(100000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  /// Helper to insert a rip track linked to an album.
  Future<void> insertRipTrack(String id, String albumId, int trackNumber) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.ripTracksTable).insert(RipTracksTableCompanion(
          id: Value(id),
          ripAlbumId: Value(albumId),
          trackNumber: Value(trackNumber),
          title: Value('Track $trackNumber'),
          filePath: Value('/music/$id.flac'),
          fileSizeBytes: const Value(50000000),
          updatedAt: Value(now),
        ));
  }

  group('PlaylistDao', () {
    test('watchAll returns empty list initially', () async {
      final playlists = await dao.watchAll().first;
      expect(playlists, isEmpty);
    });

    test('insertPlaylist and watchAll returns inserted playlist', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = uuid.v4();

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(id),
        name: const Value('My Favourites'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final playlists = await dao.watchAll().first;
      expect(playlists.length, 1);
      expect(playlists.first.id, id);
      expect(playlists.first.name, 'My Favourites');
    });

    test('softDeletePlaylist excludes from watchAll', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = uuid.v4();

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(id),
        name: const Value('To Delete'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Verify it appears before deletion.
      var playlists = await dao.watchAll().first;
      expect(playlists.length, 1);

      await dao.softDeletePlaylist(id, now + 1000);

      playlists = await dao.watchAll().first;
      expect(playlists, isEmpty);
    });

    test('insertPlaylistTracks and getTracksForPlaylist returns ordered tracks',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final albumId = uuid.v4();
      final track1Id = uuid.v4();
      final track2Id = uuid.v4();
      final playlistId = uuid.v4();
      final pt1Id = uuid.v4();
      final pt2Id = uuid.v4();

      await insertRipAlbum(albumId);
      await insertRipTrack(track1Id, albumId, 1);
      await insertRipTrack(track2Id, albumId, 2);

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(playlistId),
        name: const Value('Test Playlist'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.insertPlaylistTracks([
        PlaylistTracksTableCompanion(
          id: Value(pt2Id),
          playlistId: Value(playlistId),
          ripTrackId: Value(track2Id),
          sortOrder: const Value(2),
          addedAt: Value(now),
        ),
        PlaylistTracksTableCompanion(
          id: Value(pt1Id),
          playlistId: Value(playlistId),
          ripTrackId: Value(track1Id),
          sortOrder: const Value(1),
          addedAt: Value(now),
        ),
      ]);

      final tracks = await dao.getTracksForPlaylist(playlistId);
      expect(tracks.length, 2);
      // Should be sorted by sort_order ascending.
      expect(tracks[0].ripTrackId, track1Id);
      expect(tracks[1].ripTrackId, track2Id);
    });

    test('updatePlaylist updates name', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = uuid.v4();

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(id),
        name: const Value('Original Name'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.updatePlaylist(PlaylistsTableCompanion(
        id: Value(id),
        name: const Value('Updated Name'),
        updatedAt: Value(now + 1000),
      ));

      final playlist = await dao.getById(id);
      expect(playlist, isNotNull);
      expect(playlist!.name, 'Updated Name');
    });

    test('reorderTracks atomically clears and re-inserts', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final albumId = uuid.v4();
      final trackAId = uuid.v4();
      final trackBId = uuid.v4();
      final trackCId = uuid.v4();
      final playlistId = uuid.v4();
      final ptAId = uuid.v4();
      final ptBId = uuid.v4();
      final ptCId = uuid.v4();

      await insertRipAlbum(albumId);
      await insertRipTrack(trackAId, albumId, 1);
      await insertRipTrack(trackBId, albumId, 2);
      await insertRipTrack(trackCId, albumId, 3);

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(playlistId),
        name: const Value('Reorder Test'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Insert tracks in order A, B, C.
      await dao.insertPlaylistTracks([
        PlaylistTracksTableCompanion(
          id: Value(ptAId),
          playlistId: Value(playlistId),
          ripTrackId: Value(trackAId),
          sortOrder: const Value(1),
          addedAt: Value(now),
        ),
        PlaylistTracksTableCompanion(
          id: Value(ptBId),
          playlistId: Value(playlistId),
          ripTrackId: Value(trackBId),
          sortOrder: const Value(2),
          addedAt: Value(now),
        ),
        PlaylistTracksTableCompanion(
          id: Value(ptCId),
          playlistId: Value(playlistId),
          ripTrackId: Value(trackCId),
          sortOrder: const Value(3),
          addedAt: Value(now),
        ),
      ]);

      // Reorder to C, B, A.
      final reordered = [
        PlaylistTracksTableCompanion.insert(
          id: ptCId,
          playlistId: playlistId,
          ripTrackId: trackCId,
          sortOrder: 1,
          addedAt: now,
        ),
        PlaylistTracksTableCompanion.insert(
          id: ptBId,
          playlistId: playlistId,
          ripTrackId: trackBId,
          sortOrder: 2,
          addedAt: now,
        ),
        PlaylistTracksTableCompanion.insert(
          id: ptAId,
          playlistId: playlistId,
          ripTrackId: trackAId,
          sortOrder: 3,
          addedAt: now,
        ),
      ];

      await dao.reorderTracks(playlistId, reordered);

      final tracks = await dao.getTracksForPlaylist(playlistId);
      expect(tracks.length, 3);
      // Verify new order: C, B, A.
      expect(tracks[0].ripTrackId, trackCId);
      expect(tracks[1].ripTrackId, trackBId);
      expect(tracks[2].ripTrackId, trackAId);
    });

    test('removeTrackFromPlaylist removes specific track', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final albumId = uuid.v4();
      final track1Id = uuid.v4();
      final track2Id = uuid.v4();
      final playlistId = uuid.v4();
      final pt1Id = uuid.v4();
      final pt2Id = uuid.v4();

      await insertRipAlbum(albumId);
      await insertRipTrack(track1Id, albumId, 1);
      await insertRipTrack(track2Id, albumId, 2);

      await dao.insertPlaylist(PlaylistsTableCompanion(
        id: Value(playlistId),
        name: const Value('Remove Test'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.insertPlaylistTracks([
        PlaylistTracksTableCompanion(
          id: Value(pt1Id),
          playlistId: Value(playlistId),
          ripTrackId: Value(track1Id),
          sortOrder: const Value(1),
          addedAt: Value(now),
        ),
        PlaylistTracksTableCompanion(
          id: Value(pt2Id),
          playlistId: Value(playlistId),
          ripTrackId: Value(track2Id),
          sortOrder: const Value(2),
          addedAt: Value(now),
        ),
      ]);

      await dao.removeTrackFromPlaylist(pt1Id);

      final tracks = await dao.getTracksForPlaylist(playlistId);
      expect(tracks.length, 1);
      expect(tracks.first.id, pt2Id);
    });
  });
}
