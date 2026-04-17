import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

/// Regression test for schema v16.
///
/// The GnuDB feature (commit 9060213) bumped the schema to v16 and added
/// `rip_albums.gnudb_disc_id` to the table definition, but never wrote an
/// `onUpgrade` branch. Fresh installs via `createAll()` get the column;
/// older databases upgrading from v15 silently did not — surfacing later
/// as "no such column: gnudb_disc_id" when saving through
/// `RipLibraryRepositoryImpl.updateAlbum`. The app is unpublished, so the
/// agreed fix is drop-and-recreate rather than a new migration branch.
/// This test just locks the fresh-install invariant so it cannot regress.
void main() {
  test('fresh v16 schema exposes rip_albums.gnudb_disc_id', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = (await db.customSelect(
      "SELECT name FROM pragma_table_info('rip_albums')",
    ).get())
        .map((r) => r.data['name'] as String)
        .toSet();

    expect(cols, contains('gnudb_disc_id'));
  });

  test('fresh v16 schema exposes rip_albums.cue_file_path', () async {
    // Guards the sibling column that shares the update-album companion.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = (await db.customSelect(
      "SELECT name FROM pragma_table_info('rip_albums')",
    ).get())
        .map((r) => r.data['name'] as String)
        .toSet();

    expect(cols, contains('cue_file_path'));
  });
}
