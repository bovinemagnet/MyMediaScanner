// Seed data helpers for integration tests.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final _mediaTypes = ['film', 'book', 'music', 'game', 'tv'];

final _sampleAlbums = [
  ('Miles Davis', 'Kind of Blue'),
  ('Dave Brubeck', 'Time Out'),
  ('John Coltrane', 'A Love Supreme'),
];

final _sampleTitles = [
  'The Shawshank Redemption',
  'To Kill a Mockingbird',
  'Abbey Road',
  'The Last of Us',
  'Breaking Bad',
];

Future<List<String>> seedMediaItems(
  AppDatabase db, {
  int count = 5,
}) async {
  final ids = <String>[];
  for (var i = 0; i < count; i++) {
    final id = await seedSingleItem(
      db,
      title: _sampleTitles[i % _sampleTitles.length],
      mediaType: _mediaTypes[i % _mediaTypes.length],
      barcode: '978014103${6144 + i}',
    );
    ids.add(id);
  }
  return ids;
}

Future<String> seedSingleItem(
  AppDatabase db, {
  String? id,
  String title = 'Test Item',
  String mediaType = 'film',
  String barcode = '9780141036144',
  String barcodeType = 'ean13',
  int? year,
}) async {
  final itemId = id ?? _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.mediaItemsDao.insertItem(
    MediaItemsTableCompanion(
      id: Value(itemId),
      barcode: Value(barcode),
      barcodeType: Value(barcodeType),
      mediaType: Value(mediaType),
      title: Value(title),
      dateAdded: Value(now),
      dateScanned: Value(now),
      updatedAt: Value(now),
      deleted: const Value(0),
      year: year != null ? Value(year) : const Value.absent(),
    ),
  );
  return itemId;
}

Future<List<String>> seedShelves(
  AppDatabase db, {
  int count = 2,
}) async {
  final ids = <String>[];
  final names = ['Favourites', 'To Watch', 'Classics', 'Lent Out'];
  for (var i = 0; i < count; i++) {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.shelvesDao.insertShelf(
      ShelvesTableCompanion(
        id: Value(id),
        name: Value(names[i % names.length]),
        sortOrder: Value(i),
        updatedAt: Value(now),
        deleted: const Value(0),
      ),
    );
    ids.add(id);
  }
  return ids;
}

/// Seed a rip album with tracks. Returns the album ID.
Future<String> seedRipAlbum(
  AppDatabase db, {
  String? artist,
  String? albumTitle,
  int trackCount = 3,
  String? mediaItemId,
}) async {
  final albumId = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;
  final a = artist ?? _sampleAlbums[0].$1;
  final t = albumTitle ?? _sampleAlbums[0].$2;

  await db.ripLibraryDao.insertAlbum(
    RipAlbumsTableCompanion.insert(
      id: albumId,
      libraryPath: '/test/music/$a/$t',
      artist: Value(a),
      albumTitle: Value(t),
      trackCount: trackCount,
      totalSizeBytes: trackCount * 30000000,
      lastScannedAt: now,
      updatedAt: now,
      mediaItemId: Value(mediaItemId),
    ),
  );

  final trackCompanions = List.generate(trackCount, (i) {
    return RipTracksTableCompanion.insert(
      id: _uuid.v4(),
      ripAlbumId: albumId,
      trackNumber: i + 1,
      title: Value('Track ${i + 1}'),
      filePath: '/test/music/$a/$t/track${i + 1}.flac',
      fileSizeBytes: 30000000,
      updatedAt: now,
    );
  });
  await db.ripLibraryDao.insertTracks(trackCompanions);

  return albumId;
}

/// Seed a playlist with tracks from a rip album. Returns the playlist ID.
Future<String> seedPlaylist(
  AppDatabase db, {
  required String name,
  required String ripAlbumId,
}) async {
  final playlistId = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;

  await db.playlistDao.insertPlaylist(
    PlaylistsTableCompanion.insert(
      id: playlistId,
      name: name,
      createdAt: now,
      updatedAt: now,
    ),
  );

  final tracks = await db.ripLibraryDao.getTracksForAlbum(ripAlbumId);
  final ptCompanions = tracks.asMap().entries.map((entry) {
    return PlaylistTracksTableCompanion.insert(
      id: _uuid.v4(),
      playlistId: playlistId,
      ripTrackId: entry.value.id,
      sortOrder: entry.key,
      addedAt: now,
    );
  }).toList();
  await db.playlistDao.insertPlaylistTracks(ptCompanions);

  return playlistId;
}
