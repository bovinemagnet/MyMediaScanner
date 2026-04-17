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
  int get schemaVersion => 15;

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

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_insert
      AFTER INSERT ON media_items BEGIN
        INSERT INTO media_items_fts(rowid, title, subtitle, description, publisher, genres)
        VALUES (new.rowid, new.title, new.subtitle, new.description, new.publisher, new.genres);
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS media_items_fts_update
      AFTER UPDATE ON media_items BEGIN
        INSERT INTO media_items_fts(media_items_fts, rowid, title, subtitle, description, publisher, genres)
        VALUES ('delete', old.rowid, old.title, old.subtitle, old.description, old.publisher, old.genres);
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

    // Rebuild index from existing data (for upgrades from previous versions).
    await customStatement(
      "INSERT INTO media_items_fts(media_items_fts) VALUES('rebuild')",
    );
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
