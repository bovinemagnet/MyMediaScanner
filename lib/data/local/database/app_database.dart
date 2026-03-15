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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
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
          if (from < 5) {
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
        },
      );
}
