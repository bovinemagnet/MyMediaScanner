import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

/// Cluster-3 MED-3 regression: the FTS5 sync triggers must skip
/// soft-deleted rows, otherwise the index bloats with retired items and
/// any future caller that queries `media_items_fts` without joining back
/// to `media_items WHERE deleted = 0` would surface ghost matches.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.mediaItemsDao.insertItem(MediaItemsTableCompanion.insert(
      id: 'm1',
      barcode: 'bc',
      barcodeType: 'ean13',
      mediaType: 'film',
      title: 'Neuromancer',
      ownershipStatus: const Value('owned'),
      consumed: const Value(0),
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      deleted: const Value(0),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> ftsRowCount(String matchTerm) async {
    final rows = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM media_items_fts '
          'WHERE media_items_fts MATCH ?',
          variables: [Variable.withString(matchTerm)],
        )
        .get();
    return (rows.first.data['c'] as int);
  }

  test('newly-inserted non-deleted row is indexed', () async {
    expect(await ftsRowCount('Neuromancer'), 1);
  });

  test('soft-deleting a row removes it from the FTS index', () async {
    await db.mediaItemsDao.softDelete('m1', 2);
    expect(await ftsRowCount('Neuromancer'), 0);
  });

  test('un-deleting a soft-deleted row restores it to the FTS index',
      () async {
    await db.mediaItemsDao.softDelete('m1', 2);
    expect(await ftsRowCount('Neuromancer'), 0);
    // Clear deleted flag to "un-delete" — same row, deleted=0.
    await (db.update(db.mediaItemsTable)
          ..where((t) => t.id.equals('m1')))
        .write(const MediaItemsTableCompanion(deleted: Value(0)));
    expect(await ftsRowCount('Neuromancer'), 1);
  });

  test(
      'an item inserted as already deleted does not enter the FTS index',
      () async {
    await db.mediaItemsDao.insertItem(MediaItemsTableCompanion.insert(
      id: 'm2',
      barcode: 'bc2',
      barcodeType: 'ean13',
      mediaType: 'film',
      title: 'Hyperion',
      ownershipStatus: const Value('owned'),
      consumed: const Value(0),
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      deleted: const Value(1),
    ));
    expect(await ftsRowCount('Hyperion'), 0);
  });
}
