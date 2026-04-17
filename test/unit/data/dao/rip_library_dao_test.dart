import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/rip_library_dao.dart';

void main() {
  late AppDatabase db;
  late RipLibraryDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.ripLibraryDao;
  });

  tearDown(() => db.close());

  /// Helper to insert a media item (required by foreign key).
  Future<void> insertMediaItem(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.mediaItemsTable).insert(MediaItemsTableCompanion(
          id: Value(id),
          barcode: Value('barcode-$id'),
          barcodeType: const Value('ean13'),
          mediaType: const Value('music'),
          title: Value('Item $id'),
          dateAdded: Value(now),
          dateScanned: Value(now),
          updatedAt: Value(now),
        ));
  }

  group('RipLibraryDao', () {
    test('insert album and query by mediaItemId', () async {
      await insertMediaItem('item-1');

      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist/Album'),
        artist: const Value('Test Artist'),
        albumTitle: const Value('Test Album'),
        trackCount: const Value(10),
        totalSizeBytes: const Value(500000000),
        mediaItemId: const Value('item-1'),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      final result = await dao.watchByMediaItemId('item-1').first;
      expect(result, isNotNull);
      expect(result!.id, 'rip-1');
      expect(result.artist, 'Test Artist');
      expect(result.albumTitle, 'Test Album');
      expect(result.trackCount, 10);
      expect(result.mediaItemId, 'item-1');
    });

    test('insert album and tracks, then query tracks', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist/Album'),
        trackCount: const Value(2),
        totalSizeBytes: const Value(100000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.insertTracks([
        RipTracksTableCompanion(
          id: const Value('track-1'),
          ripAlbumId: const Value('rip-1'),
          trackNumber: const Value(1),
          title: const Value('Track One'),
          filePath: const Value('/music/track1.flac'),
          fileSizeBytes: const Value(50000000),
          updatedAt: Value(now),
        ),
        RipTracksTableCompanion(
          id: const Value('track-2'),
          ripAlbumId: const Value('rip-1'),
          trackNumber: const Value(2),
          title: const Value('Track Two'),
          filePath: const Value('/music/track2.flac'),
          fileSizeBytes: const Value(50000000),
          updatedAt: Value(now),
        ),
      ]);

      final tracks = await dao.getTracksForAlbum('rip-1');
      expect(tracks.length, 2);
      expect(tracks[0].title, 'Track One');
      expect(tracks[1].title, 'Track Two');
    });

    test('updateAlbum persists new artist and album title', () async {
      await insertMediaItem('item-1');
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-edit'),
        libraryPath: const Value('Old Artist/Old Album'),
        artist: const Value('Old Artist'),
        albumTitle: const Value('Old Album'),
        barcode: const Value('00001'),
        trackCount: const Value(10),
        discCount: const Value(1),
        totalSizeBytes: const Value(100),
        mediaItemId: const Value('item-1'),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      // Mirrors what RipLibraryRepositoryImpl.updateAlbum builds.
      await dao.updateAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-edit'),
        libraryPath: const Value('Old Artist/Old Album'),
        artist: const Value('New Artist'),
        albumTitle: const Value('New Album'),
        barcode: const Value('00001'),
        trackCount: const Value(10),
        discCount: const Value(1),
        totalSizeBytes: const Value(100),
        mediaItemId: const Value('item-1'),
        cueFilePath: const Value(null),
        gnudbDiscId: const Value(null),
        lastScannedAt: Value(now),
        updatedAt: Value(now + 1000),
      ));

      final result =
          await (db.select(db.ripAlbumsTable)
                ..where((t) => t.id.equals('rip-edit')))
              .getSingleOrNull();
      expect(result, isNotNull);
      expect(result!.artist, 'New Artist');
      expect(result.albumTitle, 'New Album');
      expect(result.updatedAt, now + 1000);
    });

    test('updateAlbum clears artist and album title when set to null',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-clear'),
        libraryPath: const Value('Artist/Album'),
        artist: const Value('Some Artist'),
        albumTitle: const Value('Some Album'),
        trackCount: const Value(3),
        totalSizeBytes: const Value(50),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.updateAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-clear'),
        libraryPath: const Value('Artist/Album'),
        artist: const Value(null),
        albumTitle: const Value(null),
        barcode: const Value(null),
        trackCount: const Value(3),
        discCount: const Value(1),
        totalSizeBytes: const Value(50),
        mediaItemId: const Value(null),
        cueFilePath: const Value(null),
        gnudbDiscId: const Value(null),
        lastScannedAt: Value(now),
        updatedAt: Value(now + 500),
      ));

      final result =
          await (db.select(db.ripAlbumsTable)
                ..where((t) => t.id.equals('rip-clear')))
              .getSingleOrNull();
      expect(result, isNotNull);
      expect(result!.artist, isNull);
      expect(result.albumTitle, isNull);
    });

    test('updateAlbum works when the album has no linked media item',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-orphan'),
        libraryPath: const Value('Artist/Orphan'),
        artist: const Value('Orphan'),
        albumTitle: const Value('Orphan Album'),
        trackCount: const Value(1),
        totalSizeBytes: const Value(10),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
        // No mediaItemId — common case for freshly scanned rips.
      ));

      await dao.updateAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-orphan'),
        libraryPath: const Value('Artist/Orphan'),
        artist: const Value('Edited'),
        albumTitle: const Value('Edited Album'),
        barcode: const Value(null),
        trackCount: const Value(1),
        discCount: const Value(1),
        totalSizeBytes: const Value(10),
        mediaItemId: const Value(null),
        cueFilePath: const Value(null),
        gnudbDiscId: const Value(null),
        lastScannedAt: Value(now),
        updatedAt: Value(now + 250),
      ));

      final result =
          await (db.select(db.ripAlbumsTable)
                ..where((t) => t.id.equals('rip-orphan')))
              .getSingleOrNull();
      expect(result, isNotNull);
      expect(result!.artist, 'Edited');
      expect(result.albumTitle, 'Edited Album');
    });

    test('updateTrackTitle persists a new title and clears it for null',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-trk'),
        libraryPath: const Value('Artist/Track Album'),
        trackCount: const Value(1),
        totalSizeBytes: const Value(10),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));
      await dao.insertTracks([
        RipTracksTableCompanion(
          id: const Value('trk-1'),
          ripAlbumId: const Value('rip-trk'),
          trackNumber: const Value(1),
          title: const Value('Old Track Title'),
          filePath: const Value('/music/trk.flac'),
          fileSizeBytes: const Value(10),
          updatedAt: Value(now),
        ),
      ]);

      await dao.updateTrackTitle('trk-1', 'New Track Title');
      var row = await (db.select(db.ripTracksTable)
            ..where((t) => t.id.equals('trk-1')))
          .getSingleOrNull();
      expect(row?.title, 'New Track Title');

      await dao.updateTrackTitle('trk-1', null);
      row = await (db.select(db.ripTracksTable)
            ..where((t) => t.id.equals('trk-1')))
          .getSingleOrNull();
      expect(row?.title, isNull);
    });

    test('soft-delete album filters it from watchAll', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist/Album'),
        trackCount: const Value(5),
        totalSizeBytes: const Value(250000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      // Before soft delete
      var albums = await dao.watchAll().first;
      expect(albums.length, 1);

      // After soft delete
      await dao.softDeleteAlbum('rip-1', now + 1000);
      albums = await dao.watchAll().first;
      expect(albums, isEmpty);
    });

    test('track hard-delete on re-scan', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist/Album'),
        trackCount: const Value(1),
        totalSizeBytes: const Value(50000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      await dao.insertTracks([
        RipTracksTableCompanion(
          id: const Value('track-old'),
          ripAlbumId: const Value('rip-1'),
          trackNumber: const Value(1),
          title: const Value('Old Track'),
          filePath: const Value('/music/old.flac'),
          fileSizeBytes: const Value(50000000),
          updatedAt: Value(now),
        ),
      ]);

      // Verify old track exists
      var tracks = await dao.getTracksForAlbum('rip-1');
      expect(tracks.length, 1);
      expect(tracks.first.id, 'track-old');

      // Hard-delete old tracks and insert new ones (re-scan)
      await dao.deleteTracksForAlbum('rip-1');
      await dao.insertTracks([
        RipTracksTableCompanion(
          id: const Value('track-new'),
          ripAlbumId: const Value('rip-1'),
          trackNumber: const Value(1),
          title: const Value('New Track'),
          filePath: const Value('/music/new.flac'),
          fileSizeBytes: const Value(50000000),
          updatedAt: Value(now + 1000),
        ),
      ]);

      tracks = await dao.getTracksForAlbum('rip-1');
      expect(tracks.length, 1);
      expect(tracks.first.id, 'track-new');
      expect(tracks.first.title, 'New Track');
    });

    test('watchRippedMediaItemIds returns linked item IDs', () async {
      await insertMediaItem('item-1');
      await insertMediaItem('item-2');

      final now = DateTime.now().millisecondsSinceEpoch;

      // Album linked to item-1
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist1/Album1'),
        trackCount: const Value(5),
        totalSizeBytes: const Value(250000000),
        mediaItemId: const Value('item-1'),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      // Album not linked
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-2'),
        libraryPath: const Value('Artist2/Album2'),
        trackCount: const Value(8),
        totalSizeBytes: const Value(400000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      final ids = await dao.watchRippedMediaItemIds().first;
      expect(ids, contains('item-1'));
      expect(ids, isNot(contains('item-2')));
      expect(ids.length, 1);
    });

    test('linkToMediaItem and unlinkFromMediaItem', () async {
      await insertMediaItem('item-1');

      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Artist/Album'),
        trackCount: const Value(5),
        totalSizeBytes: const Value(250000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      // Link
      await dao.linkToMediaItem('rip-1', 'item-1');
      var result = await dao.watchByMediaItemId('item-1').first;
      expect(result, isNotNull);
      expect(result!.mediaItemId, 'item-1');

      // Unlink
      await dao.unlinkFromMediaItem('rip-1');
      result = await dao.watchByMediaItemId('item-1').first;
      expect(result, isNull);
    });

    test('getByLibraryPath returns album matching path', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.insertAlbum(RipAlbumsTableCompanion(
        id: const Value('rip-1'),
        libraryPath: const Value('Pink Floyd/DSOTM'),
        trackCount: const Value(10),
        totalSizeBytes: const Value(500000000),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));

      final result = await dao.getByLibraryPath('Pink Floyd/DSOTM');
      expect(result, isNotNull);
      expect(result!.id, 'rip-1');

      final noResult = await dao.getByLibraryPath('Nonexistent/Path');
      expect(noResult, isNull);
    });

    group('getUnanalysedAlbumIds', () {
      test('returns albums with at least one unchecked track', () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // Album with one unchecked track
        await dao.insertAlbum(RipAlbumsTableCompanion(
          id: const Value('rip-1'),
          libraryPath: const Value('Artist/Album1'),
          trackCount: const Value(1),
          totalSizeBytes: const Value(50000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
        await dao.insertTracks([
          RipTracksTableCompanion(
            id: const Value('track-1'),
            ripAlbumId: const Value('rip-1'),
            trackNumber: const Value(1),
            filePath: const Value('/music/track1.flac'),
            fileSizeBytes: const Value(50000000),
            updatedAt: Value(now),
            // qualityCheckedAt not set — null
          ),
        ]);

        final ids = await dao.getUnanalysedAlbumIds();
        expect(ids, contains('rip-1'));
        expect(ids.length, 1);
      });

      test('excludes albums where all tracks are quality-checked', () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        await dao.insertAlbum(RipAlbumsTableCompanion(
          id: const Value('rip-1'),
          libraryPath: const Value('Artist/Album1'),
          trackCount: const Value(1),
          totalSizeBytes: const Value(50000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
        await dao.insertTracks([
          RipTracksTableCompanion(
            id: const Value('track-1'),
            ripAlbumId: const Value('rip-1'),
            trackNumber: const Value(1),
            filePath: const Value('/music/track1.flac'),
            fileSizeBytes: const Value(50000000),
            updatedAt: Value(now),
          ),
        ]);

        // Mark the track as quality-checked
        await dao.updateTrackQuality('track-1', qualityCheckedAt: now);

        final ids = await dao.getUnanalysedAlbumIds();
        expect(ids, isEmpty);
      });

      test('excludes soft-deleted albums', () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        await dao.insertAlbum(RipAlbumsTableCompanion(
          id: const Value('rip-1'),
          libraryPath: const Value('Artist/Album1'),
          trackCount: const Value(1),
          totalSizeBytes: const Value(50000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
        await dao.insertTracks([
          RipTracksTableCompanion(
            id: const Value('track-1'),
            ripAlbumId: const Value('rip-1'),
            trackNumber: const Value(1),
            filePath: const Value('/music/track1.flac'),
            fileSizeBytes: const Value(50000000),
            updatedAt: Value(now),
          ),
        ]);

        // Soft-delete the album
        await dao.softDeleteAlbum('rip-1', now + 1000);

        final ids = await dao.getUnanalysedAlbumIds();
        expect(ids, isEmpty);
      });

      test('returns only albums with at least one unchecked track when mixed',
          () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // Album with one unchecked track
        await dao.insertAlbum(RipAlbumsTableCompanion(
          id: const Value('rip-unanalysed'),
          libraryPath: const Value('Artist/Unanalysed'),
          trackCount: const Value(1),
          totalSizeBytes: const Value(50000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
        await dao.insertTracks([
          RipTracksTableCompanion(
            id: const Value('track-unchecked'),
            ripAlbumId: const Value('rip-unanalysed'),
            trackNumber: const Value(1),
            filePath: const Value('/music/unchecked.flac'),
            fileSizeBytes: const Value(50000000),
            updatedAt: Value(now),
          ),
        ]);

        // Album fully analysed
        await dao.insertAlbum(RipAlbumsTableCompanion(
          id: const Value('rip-analysed'),
          libraryPath: const Value('Artist/Analysed'),
          trackCount: const Value(1),
          totalSizeBytes: const Value(50000000),
          lastScannedAt: Value(now),
          updatedAt: Value(now),
        ));
        await dao.insertTracks([
          RipTracksTableCompanion(
            id: const Value('track-checked'),
            ripAlbumId: const Value('rip-analysed'),
            trackNumber: const Value(1),
            filePath: const Value('/music/checked.flac'),
            fileSizeBytes: const Value(50000000),
            updatedAt: Value(now),
          ),
        ]);
        await dao.updateTrackQuality('track-checked', qualityCheckedAt: now);

        final ids = await dao.getUnanalysedAlbumIds();
        expect(ids, contains('rip-unanalysed'));
        expect(ids, isNot(contains('rip-analysed')));
        expect(ids.length, 1);
      });
    });
  });
}
