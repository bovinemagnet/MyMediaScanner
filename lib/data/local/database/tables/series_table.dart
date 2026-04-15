import 'package:drift/drift.dart';

/// A franchise / collection / series grouping multiple media items.
///
/// `externalId` is qualified by source (e.g. `tmdb:131635`,
/// `mb:abc-123`, `gbooks:HARRYPOTTER`) so the same logical series can
/// appear across providers without colliding. `totalCount` captures the
/// number of known entries from the upstream provider when available;
/// `null` means "unknown" and the UI falls back to "owned-only" counts.
class SeriesTable extends Table {
  @override
  String get tableName => 'series';

  TextColumn get id => text()();
  TextColumn get externalId => text()();
  TextColumn get name => text()();
  TextColumn get mediaType => text()();
  TextColumn get source => text()();
  IntColumn get totalCount => integer().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {externalId},
      ];
}
