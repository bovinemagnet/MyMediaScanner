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
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';

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
  ],
  daos: [
    MediaItemsDao,
    TagsDao,
    ShelvesDao,
    BarcodeCacheDao,
    SyncLogDao,
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
  int get schemaVersion => 1;
}
