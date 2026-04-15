import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/dao/borrowers_dao.dart';
import 'package:mymediascanner/data/local/dao/loans_dao.dart';
import 'package:mymediascanner/data/local/dao/rip_library_dao.dart';
import 'package:mymediascanner/data/local/dao/batch_session_dao.dart';
import 'package:mymediascanner/data/local/dao/locations_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final mediaItemsDaoProvider = Provider<MediaItemsDao>((ref) {
  return ref.watch(databaseProvider).mediaItemsDao;
});

final tagsDaoProvider = Provider<TagsDao>((ref) {
  return ref.watch(databaseProvider).tagsDao;
});

final shelvesDaoProvider = Provider<ShelvesDao>((ref) {
  return ref.watch(databaseProvider).shelvesDao;
});

final barcodeCacheDaoProvider = Provider<BarcodeCacheDao>((ref) {
  return ref.watch(databaseProvider).barcodeCacheDao;
});

final syncLogDaoProvider = Provider<SyncLogDao>((ref) {
  return ref.watch(databaseProvider).syncLogDao;
});

final borrowersDaoProvider = Provider<BorrowersDao>((ref) {
  return ref.watch(databaseProvider).borrowersDao;
});

final loansDaoProvider = Provider<LoansDao>((ref) {
  return ref.watch(databaseProvider).loansDao;
});

final ripLibraryDaoProvider = Provider<RipLibraryDao>((ref) {
  return ref.watch(databaseProvider).ripLibraryDao;
});

final batchSessionDaoProvider = Provider<BatchSessionDao>((ref) {
  return ref.watch(databaseProvider).batchSessionDao;
});

final locationsDaoProvider = Provider<LocationsDao>((ref) {
  return ref.watch(databaseProvider).locationsDao;
});
