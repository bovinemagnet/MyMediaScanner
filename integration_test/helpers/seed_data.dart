// Seed data helpers for integration tests.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final _mediaTypes = ['film', 'book', 'music', 'game', 'tv'];

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
