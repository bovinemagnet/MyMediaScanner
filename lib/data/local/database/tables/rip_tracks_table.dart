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
  TextColumn get ripLogSource => text().nullable()();
  IntColumn get qualityCheckedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
