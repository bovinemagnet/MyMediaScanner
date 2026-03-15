import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';

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
