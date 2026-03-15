import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/barcode_cache_table.dart';

part 'barcode_cache_dao.g.dart';

@DriftAccessor(tables: [BarcodeCacheTable])
class BarcodeCacheDao extends DatabaseAccessor<AppDatabase>
    with _$BarcodeCacheDaoMixin {
  BarcodeCacheDao(super.db);

  Future<BarcodeCacheTableData?> getByBarcode(String barcode) {
    return (select(barcodeCacheTable)
          ..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  Future<void> upsert(BarcodeCacheTableCompanion entry) {
    return into(barcodeCacheTable).insertOnConflictUpdate(entry);
  }

  Future<void> deleteExpired(int maxAgeMillis) {
    final cutoff = DateTime.now().millisecondsSinceEpoch - maxAgeMillis;
    return (delete(barcodeCacheTable)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
