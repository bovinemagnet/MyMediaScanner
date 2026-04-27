import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_item_tags_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelves_table.dart';
import 'package:mymediascanner/data/local/database/tables/shelf_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/barcode_cache_table.dart';
import 'package:mymediascanner/data/local/database/tables/sync_log_table.dart';
import 'package:mymediascanner/data/local/database/tables/borrowers_table.dart';
import 'package:mymediascanner/data/local/database/tables/loans_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_albums_table.dart';
import 'package:mymediascanner/data/local/database/tables/rip_tracks_table.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/dao/borrowers_dao.dart';
import 'package:mymediascanner/data/local/dao/loans_dao.dart';
import 'package:mymediascanner/data/local/dao/rip_library_dao.dart';
import 'package:mymediascanner/data/local/dao/batch_session_dao.dart';
import 'package:mymediascanner/data/local/database/tables/batch_sessions_table.dart';
import 'package:mymediascanner/data/local/database/tables/batch_queue_items_table.dart';
import 'package:mymediascanner/data/local/database/tables/playlists_table.dart';
import 'package:mymediascanner/data/local/database/tables/playlist_tracks_table.dart';
import 'package:mymediascanner/data/local/database/tables/locations_table.dart';
import 'package:mymediascanner/data/local/database/tables/series_table.dart';
import 'package:mymediascanner/data/local/dao/playlist_dao.dart';
import 'package:mymediascanner/data/local/dao/locations_dao.dart';
import 'package:mymediascanner/data/local/dao/series_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MediaItemsTable,
    TagsTable,
    MediaItemTagsTable,
    ShelvesTable,
    ShelfItemsTable,
    BarcodeCacheTable,
    SyncLogTable,
    BorrowersTable,
    LoansTable,
    RipAlbumsTable,
    RipTracksTable,
    BatchSessionsTable,
    BatchQueueItemsTable,
    PlaylistsTable,
    PlaylistTracksTable,
    LocationsTable,
    SeriesTable,
  ],
  daos: [
    MediaItemsDao,
    TagsDao,
    ShelvesDao,
    BarcodeCacheDao,
    SyncLogDao,
    BorrowersDao,
    LoansDao,
    RipLibraryDao,
    BatchSessionDao,
    PlaylistDao,
    LocationsDao,
    SeriesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: AppConstants.databaseName,
                native: const DriftNativeOptions(
                  shareAcrossIsolates: true,
                ),
              ),
        );

  /// In-memory constructor for testing.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createFts5Table(m);
          await _createIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(borrowersTable);
            await m.createTable(loansTable);
          }
          if (from < 3) {
            await m.addColumn(mediaItemsTable, mediaItemsTable.criticScore);
            await m.addColumn(mediaItemsTable, mediaItemsTable.criticSource);
          }
          if (from < 4) {
            await m.createTable(ripAlbumsTable);
            await m.createTable(ripTracksTable);
          }
          if (from < 6) {
            await _createFts5Table(m);
          }
          if (from < 7) {
            await m.addColumn(loansTable, loansTable.dueAt);
            await m.createTable(batchSessionsTable);
            await m.createTable(batchQueueItemsTable);
            await m.addColumn(syncLogTable, syncLogTable.errorMessage);
            await m.addColumn(syncLogTable, syncLogTable.durationMs);
            await m.addColumn(syncLogTable, syncLogTable.direction);
            await m.addColumn(syncLogTable, syncLogTable.resolvedBy);
          }
          if (from < 8) {
            await _createIndexes();
          }
          if (from < 9) {
            await m.addColumn(
                ripAlbumsTable, ripAlbumsTable.cueFilePath);
          }
          if (from < 10) {
            await m.createTable(playlistsTable);
            await m.createTable(playlistTracksTable);
          }
          if (from < 12) {
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.ownershipStatus);
            await m.addColumn(mediaItemsTable, mediaItemsTable.condition);
            await m.addColumn(mediaItemsTable, mediaItemsTable.pricePaid);
            await m.addColumn(mediaItemsTable, mediaItemsTable.acquiredAt);
            await m.addColumn(mediaItemsTable, mediaItemsTable.retailer);
            // Backfill acquiredAt from dateAdded where null (column defaults
            // apply to new rows; existing rows keep NULL without this).
            await customStatement(
                'UPDATE media_items '
                'SET acquired_at = date_added WHERE acquired_at IS NULL');
          }
          if (from < 13) {
            await m.createTable(locationsTable);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.locationId);
          }
          if (from < 14) {
            await m.createTable(seriesTable);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.seriesId);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.seriesPosition);
          }
          if (from < 15) {
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.progressCurrent);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.progressTotal);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.progressUnit);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.startedAt);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.completedAt);
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.consumed);
          }
          if (from < 17) {
            // Schema v16 added rip_albums.gnudb_disc_id to the table
            // definition (commit 9060213) but shipped without an
            // onUpgrade branch, so any user who upgraded from v15
            // sat at user_version=16 with the column missing. The app
            // is unpublished, so the agreed recovery is drop-and-
            // recreate the rip tables instead of carrying a one-off
            // addColumn migration. v17 retriggers this fix for the
            // window of installs that took the broken v16 build —
            // existing rip data is rebuilt by re-scanning the library.
            // rip_tracks must go first because of the FK to rip_albums.
            await customStatement('DROP TABLE IF EXISTS rip_tracks');
            await customStatement('DROP TABLE IF EXISTS rip_albums');
            await m.createTable(ripAlbumsTable);
            await m.createTable(ripTracksTable);
          }
          if (from < 18) {
            // Cluster-3 MED-3: the prior FTS5 triggers re-inserted into
            // media_items_fts on every UPDATE, including the soft-delete
            // UPDATE that sets deleted=1. Soft-deleted items therefore
            // kept matching full-text search even though every other
            // surface filters them out. Re-create the triggers with a
            // deleted=0 guard and rebuild the index from the
            // non-deleted rows so any already-soft-deleted items drop
            // out immediately.
            //
            // Production paths from v6+ already have the FTS table.
            // Some artificially-seeded migration tests start without it
            // (or even without the media_items table); skip cleanly in
            // those cases — a fresh schema setup will build it via
            // `onCreate` when it eventually opens at v18+.
            final ftsExists = await customSelect(
              'SELECT name FROM sqlite_master '
              "WHERE type='table' AND name='media_items_fts'",
            ).get();
            if (ftsExists.isNotEmpty) {
              await customStatement(
                  'DROP TRIGGER IF EXISTS media_items_fts_insert');
              await customStatement(
                  'DROP TRIGGER IF EXISTS media_items_fts_update');
              await customStatement(
                  'DROP TRIGGER IF EXISTS media_items_fts_update_insert');
              await customStatement(
                  'DROP TRIGGER IF EXISTS media_items_fts_delete');
              await _createFtsTriggers();
              await customStatement('DELETE FROM media_items_fts');
              await customStatement(
                'INSERT INTO media_items_fts(rowid, title, subtitle, '
                'description, publisher, genres) '
                'SELECT rowid, title, subtitle, description, publisher, '
                'genres FROM media_items WHERE deleted = 0',
              );
            }
          }
        },
      );

  /// Creates the FTS5 virtual table and sync triggers for full-text search.
  Future<void> _createFts5Table(Migrator m) async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS media_items_fts USING fts5(
        title,
        subtitle,
        description,
        publisher,
        genres,
        content='media_items',
        content_rowid='rowid'
      )
    ''');

    await _createFtsTriggers();

    // Seed the index from existing non-deleted rows (for fresh installs
    // this is empty; for upgrades from versions that had a populated
    // table this back-fills without including soft-deleted items).
    await customStatement(
      'INSERT INTO media_items_fts(rowid, title, subtitle, description, '
      'publisher, genres) '
      'SELECT rowid, title, subtitle, description, publisher, genres '
      'FROM media_items WHERE deleted = 0',
    );
  }

  /// (Re)creates the FTS5 sync triggers with a `deleted = 0` guard so
  /// soft-deleted media items don't surface from full-text search.
  ///
  /// Split into separate insert/delete branches because SQLite's FTS5
  /// `WHEN` clauses on triggers can't conditionally execute one of two
  /// statements within a single trigger body.
  Future<void> _createFtsTriggers() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_insert
      AFTER INSERT ON media_items WHEN new.deleted = 0 BEGIN
        INSERT INTO media_items_fts(rowid, title, subtitle, description, publisher, genres)
        VALUES (new.rowid, new.title, new.subtitle, new.description, new.publisher, new.genres);
      END
    ''');

    // The delete-side of an UPDATE only runs when the OLD row was
    // actually in the index (i.e. wasn't already soft-deleted) — issuing
    // a 'delete' command for a row that was never indexed corrupts the
    // FTS5 contentless lookup table and prevents a subsequent un-delete
    // from re-indexing the row. Re-insert runs WHEN the NEW row is
    // un-deleted, which covers both regular edits and un-deletes.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_update
      AFTER UPDATE ON media_items WHEN old.deleted = 0 BEGIN
        INSERT INTO media_items_fts(media_items_fts, rowid, title, subtitle, description, publisher, genres)
        VALUES ('delete', old.rowid, old.title, old.subtitle, old.description, old.publisher, old.genres);
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_update_insert
      AFTER UPDATE ON media_items WHEN new.deleted = 0 BEGIN
        INSERT INTO media_items_fts(rowid, title, subtitle, description, publisher, genres)
        VALUES (new.rowid, new.title, new.subtitle, new.description, new.publisher, new.genres);
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_delete
      AFTER DELETE ON media_items BEGIN
        INSERT INTO media_items_fts(media_items_fts, rowid, title, subtitle, description, publisher, genres)
        VALUES ('delete', old.rowid, old.title, old.subtitle, old.description, old.publisher, old.genres);
      END
    ''');
  }

  /// Creates indexes on commonly queried columns to improve performance.
  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_media_items_deleted '
        'ON media_items (deleted)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_media_items_type_date '
        'ON media_items (media_type, date_added)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_media_items_updated '
        'ON media_items (updated_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_media_items_barcode '
        'ON media_items (barcode)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sync_log_synced '
        'ON sync_log (synced)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_loans_borrower '
        'ON loans (borrower_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_loans_active '
        'ON loans (returned_at)');
  }
}
