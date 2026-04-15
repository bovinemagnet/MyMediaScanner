import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/series_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';
import 'package:uuid/uuid.dart';

class SeriesRepositoryImpl implements ISeriesRepository {
  SeriesRepositoryImpl({required SeriesDao dao}) : _dao = dao;

  final SeriesDao _dao;
  static const _uuid = Uuid();

  @override
  Stream<List<SeriesWithCounts>> watchAllWithCounts() {
    return _dao.watchSeriesWithCounts().map(
          (rows) => rows
              .map((r) => SeriesWithCounts(
                    series: _fromRow(r.series),
                    ownedCount: r.ownedCount,
                  ))
              .toList(),
        );
  }

  @override
  Future<Series?> getById(String id) async {
    final row = await _dao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<Series?> findByExternalId(String externalId) async {
    final row = await _dao.findByExternalId(externalId);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<String> upsert({
    required String externalId,
    required String name,
    required MediaType mediaType,
    required String source,
    int? totalCount,
  }) async {
    final existing = await _dao.findByExternalId(externalId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = existing?.id ?? _uuid.v7();
    await _dao.upsert(SeriesTableCompanion(
      id: Value(id),
      externalId: Value(externalId),
      name: Value(name),
      mediaType: Value(mediaType.name),
      source: Value(source),
      totalCount: Value(totalCount ?? existing?.totalCount),
      updatedAt: Value(now),
      deleted: const Value(0),
    ));
    return id;
  }

  @override
  Future<void> softDelete(String id) {
    return _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<String>> getMediaItemIds(String seriesId) {
    return _dao.getMediaItemIdsForSeries(seriesId);
  }

  Series _fromRow(SeriesTableData row) => Series(
        id: row.id,
        externalId: row.externalId,
        name: row.name,
        mediaType: MediaType.fromString(row.mediaType),
        source: row.source,
        totalCount: row.totalCount,
        updatedAt: row.updatedAt,
        deleted: row.deleted == 1,
      );
}
