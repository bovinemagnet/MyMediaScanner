// Single source of truth for where the live SQLite database lives.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the live database file. [AppDatabase] opens exactly this
/// path and the backup service reads and stages restores against it,
/// so the two can never disagree about which file holds the data.
class DatabaseLocation {
  const DatabaseLocation._();

  /// drift_flutter stores `name: X` as `X.sqlite`, which is where the
  /// app has always kept its data. Keep this name stable: changing it
  /// would open an empty database for every existing install.
  static const fileName = '${AppConstants.databaseName}.sqlite';

  /// The live database file inside the application documents
  /// directory. [docsDir] is overridable for tests.
  static Future<File> liveDatabaseFile({
    Future<Directory> Function()? docsDir,
  }) async {
    final dir = await (docsDir ?? getApplicationDocumentsDirectory)();
    return File(p.join(dir.path, fileName));
  }

  /// The path [AppDatabase] opens. Applies a staged restore first, so
  /// the swap always happens before any connection to the file exists.
  static Future<String> openPath() async {
    final live = await liveDatabaseFile();
    await applyPendingRestore(live);
    return live.path;
  }

  /// A validated backup waiting to be swapped in on the next launch.
  static File pendingRestoreFile(File live) =>
      File('${live.path}.restore-pending');

  /// The database that the last applied restore replaced. Its WAL, if
  /// any, sits beside it as `<rollback>-wal`, so it opens complete.
  static File rollbackFile(File live) => File('${live.path}.pre-restore');

  /// Swaps a staged restore into place. Must run before [live] is
  /// opened. Returns true when a restore was applied.
  ///
  /// The replaced database moves to [rollbackFile] together with its
  /// WAL and SHM, so no committed transaction is lost from it.
  static Future<bool> applyPendingRestore(File live) async {
    final pending = pendingRestoreFile(live);
    if (!await pending.exists()) return false;

    final rollback = rollbackFile(live);
    for (final suffix in ['', '-wal', '-shm']) {
      final previous = File('${rollback.path}$suffix');
      if (await previous.exists()) await previous.delete();
    }
    for (final suffix in ['', '-wal', '-shm']) {
      final current = File('${live.path}$suffix');
      if (await current.exists()) {
        await current.rename('${rollback.path}$suffix');
      }
    }
    await pending.rename(live.path);
    return true;
  }
}
