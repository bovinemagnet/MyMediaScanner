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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createFts5Table(m);
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
          if (from == 4) {
            // Only add columns for databases created at schema 4, where
            // rip_tracks exists but lacks the Phase B quality columns.
            // Databases created at schema >= 5 already have these columns
            // because createTable uses the current table definition.
            await m.addColumn(
                ripTracksTable, ripTracksTable.accurateripStatus);
            await m.addColumn(
                ripTracksTable, ripTracksTable.accurateripConfidence);
            await m.addColumn(
                ripTracksTable, ripTracksTable.accurateripCrc);
            await m.addColumn(ripTracksTable, ripTracksTable.peakLevel);
            await m.addColumn(ripTracksTable, ripTracksTable.trackQuality);
            await m.addColumn(ripTracksTable, ripTracksTable.copyCrc);
            await m.addColumn(ripTracksTable, ripTracksTable.clickCount);
            await m.addColumn(ripTracksTable, ripTracksTable.ripLogSource);
            await m.addColumn(
                ripTracksTable, ripTracksTable.qualityCheckedAt);
          }
          if (from < 6) {
            await _createFts5Table(m);
          }
          if (from < 7) {
            await m.createTable(batchSessionsTable);
            await m.createTable(batchQueueItemsTable);
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
}
