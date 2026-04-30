import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/tables/rip_albums_table.dart';

class RipTracksTable extends Table {
  @override
  String get tableName => 'rip_tracks';

  TextColumn get id => text()();
  TextColumn get ripAlbumId =>
      text().references(RipAlbumsTable, #id)();
  IntColumn get discNumber => integer().withDefault(const Constant(1))();
  IntColumn get trackNumber => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get filePath => text()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get fileSizeBytes => integer()();
  IntColumn get updatedAt => integer()();

  // Audio quality analysis columns (Phase B)
  TextColumn get accurateripStatus => text().nullable()();
  IntColumn get accurateripConfidence => integer().nullable()();
  TextColumn get accurateripCrcV1 => text().nullable()();
  TextColumn get accurateripCrcV2 => text().nullable()();
  RealColumn get peakLevel => real().nullable()();
  RealColumn get trackQuality => real().nullable()();
  TextColumn get copyCrc => text().nullable()();
  IntColumn get clickCount => integer().nullable()();
  // Per-DefectType counts from audio_defect_detector >= 0.2.0. clickCount
  // continues to track the `click` type so existing read sites keep working;
  // these three sit alongside it for `pop`, `clipping`, and `dropout`.
  IntColumn get popCount => integer().nullable()();
  IntColumn get clippingCount => integer().nullable()();
  IntColumn get dropoutCount => integer().nullable()();
  // AnalysisResult.aggregateConfidence (0.0–1.0) from the detector run.
  RealColumn get defectConfidence => real().nullable()();
  TextColumn get ripLogSource => text().nullable()();
  IntColumn get qualityCheckedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
