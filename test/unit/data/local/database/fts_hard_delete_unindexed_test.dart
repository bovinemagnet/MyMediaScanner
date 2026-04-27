import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

/// Cluster-7 MED-1 regression: the FTS5 hard-delete trigger must skip rows
/// that were never indexed. The insert / update triggers carry a
/// `WHEN ... deleted = 0` guard so soft-deleted rows are kept out of the
/// index. Without the same guard on the delete trigger, a hard delete of
/// a previously-soft-deleted row issues an FTS5 `('delete', ...)` for a
/// rowid that the index has never seen, which corrupts the contentless
/// shadow tables and can prevent later inserts from matching.
///
/// `resetLocalDatabase` walks every row, including soft-deleted ones, via
/// `mediaItemsDao.deleteAll()`, so this is the realistic crash path.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
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

  Future<void> insertItem({
    required String id,
    required String title,
    required int deleted,
  }) {
    return db.mediaItemsDao.insertItem(MediaItemsTableCompanion.insert(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: 'film',
      title: title,
      ownershipStatus: const Value('owned'),
      consumed: const Value(0),
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      deleted: Value(deleted),
    ));
  }

  test(
      'hard-deleting a never-indexed (soft-deleted) row leaves FTS '
      'consistent for subsequent inserts and searches', () async {
    // Indexed row.
    await insertItem(id: 'm1', title: 'Neuromancer', deleted: 0);
    // Never-indexed row (insert trigger skips because deleted=1).
    await insertItem(id: 'm2', title: 'Hyperion', deleted: 1);

    expect(await ftsRowCount('Neuromancer'), 1);
    expect(await ftsRowCount('Hyperion'), 0);

    // Hard-delete every row — mirrors `resetLocalDatabase`.
    await db.mediaItemsDao.deleteAll();

    // Index is empty.
    expect(await ftsRowCount('Neuromancer'), 0);
    expect(await ftsRowCount('Hyperion'), 0);

    // The corruption symptom: a fresh row inserted afterwards should be
    // discoverable. With the broken trigger the index can be left in a
    // state where contentless shadow rows mismatch the docsize table and
    // a subsequent insert-then-MATCH yields no result, or throws.
    await insertItem(id: 'm3', title: 'Snow Crash', deleted: 0);
    expect(await ftsRowCount('Snow Crash'), 1);
  });
}
