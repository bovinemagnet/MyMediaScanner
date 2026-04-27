import 'package:drift/drift.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/barcode_cache_table.dart';

part 'barcode_cache_dao.g.dart';

@DriftAccessor(tables: [BarcodeCacheTable])
class BarcodeCacheDao extends DatabaseAccessor<AppDatabase>
    with _$BarcodeCacheDaoMixin {
  BarcodeCacheDao(super.db);

  Future<BarcodeCacheTableData?> getByBarcode(String barcode) {
    final key = BarcodeUtils.normaliseForCache(barcode);
    return (select(barcodeCacheTable)
          ..where((t) => t.barcode.equals(key)))
        .getSingleOrNull();
  }

  Future<void> upsert(BarcodeCacheTableCompanion entry) {
    // Normalise the cache primary key on write so duplicate captures of
    // the same physical product (hyphenated ISBN, leading-zero-dropped
    // UPC-A, mixed casing) collapse to a single row instead of competing.
    final raw = entry.barcode;
    final normalised = raw.present
        ? Value(BarcodeUtils.normaliseForCache(raw.value))
        : raw;
    return into(barcodeCacheTable)
        .insertOnConflictUpdate(entry.copyWith(barcode: normalised));
  }

  Future<void> deleteExpired(int maxAgeMillis) {
    final cutoff = DateTime.now().millisecondsSinceEpoch - maxAgeMillis;
    return (delete(barcodeCacheTable)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Removes a specific cached barcode. Used when deserialisation of the
  /// cached payload fails so the poisoned row does not keep rethrowing on
  /// every subsequent lookup.
  Future<void> deleteByBarcode(String barcode) {
    final key = BarcodeUtils.normaliseForCache(barcode);
    return (delete(barcodeCacheTable)
          ..where((t) => t.barcode.equals(key)))
        .go();
  }
}
