import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/tables/series_table.dart';
import 'package:mymediascanner/data/local/database/tables/media_items_table.dart';

part 'series_dao.g.dart';

/// Aggregate row returned by [SeriesDao.watchSeriesWithCounts] — a series
/// plus the count of owned (`ownership_status='owned'`, `deleted=0`)
/// items currently assigned to it.
class SeriesWithOwnedCount {
  const SeriesWithOwnedCount({required this.series, required this.ownedCount});
  final SeriesTableData series;
  final int ownedCount;
}

@DriftAccessor(tables: [SeriesTable, MediaItemsTable])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.db);

  Stream<List<SeriesTableData>> watchAll() {
    return (select(seriesTable)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<SeriesTableData?> getById(String id) {
    return (select(seriesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<SeriesTableData?> findByExternalId(String externalId) {
    return (select(seriesTable)
          ..where((t) => t.externalId.equals(externalId) & t.deleted.equals(0)))
        .getSingleOrNull();
  }

  Future<void> upsert(SeriesTableCompanion series) {
    return into(seriesTable).insertOnConflictUpdate(series);
  }

  Future<void> softDelete(String id, int updatedAt) {
    return (update(seriesTable)..where((t) => t.id.equals(id))).write(
      SeriesTableCompanion(
        deleted: const Value(1),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Watch every series with an owned-count aggregate. Owned items are
  /// counted as `media_items.deleted=0 AND ownership_status='owned'` so
  /// wishlist entries do not inflate the completeness number.
  Stream<List<SeriesWithOwnedCount>> watchSeriesWithCounts() {
    final query = customSelect(
      '''
      SELECT s.*, (
        SELECT COUNT(*)
        FROM media_items m
        WHERE m.series_id = s.id
          AND m.deleted = 0
          AND m.ownership_status = 'owned'
      ) AS owned_count
      FROM series s
      WHERE s.deleted = 0
      ORDER BY s.name COLLATE NOCASE
      ''',
      readsFrom: {seriesTable, mediaItemsTable},
    );
    return query.watch().map((rows) {
      return rows.map((row) {
        final data = SeriesTableData(
          id: row.read<String>('id'),
          externalId: row.read<String>('external_id'),
          name: row.read<String>('name'),
          mediaType: row.read<String>('media_type'),
          source: row.read<String>('source'),
          totalCount: row.readNullable<int>('total_count'),
          updatedAt: row.read<int>('updated_at'),
          deleted: row.read<int>('deleted'),
        );
        return SeriesWithOwnedCount(
          series: data,
          ownedCount: row.read<int>('owned_count'),
        );
      }).toList();
    });
  }

  /// All media item ids assigned to [seriesId], sorted by series_position.
  Future<List<String>> getMediaItemIdsForSeries(String seriesId) async {
    final rows = await (select(mediaItemsTable)
          ..where((t) => t.deleted.equals(0))
          ..where((t) => t.seriesId.equals(seriesId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.seriesPosition),
            (t) => OrderingTerm.asc(t.title),
          ]))
        .get();
    return rows.map((r) => r.id).toList();
  }
}
