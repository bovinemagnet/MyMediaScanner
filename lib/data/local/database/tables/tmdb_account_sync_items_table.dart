import 'package:drift/drift.dart';

class TmdbAccountSyncItemsTable extends Table {
  @override
  String get tableName => 'tmdb_account_sync_items';

  TextColumn get id => text()();
  TextColumn get mediaItemId => text().nullable()();
  IntColumn get tmdbId => integer()();
  TextColumn get tmdbMediaType => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get titleSnapshot => text().nullable()();
  TextColumn get posterPathSnapshot => text().nullable()();
  RealColumn get tmdbRating => real().nullable()();
  RealColumn get localRatingSnapshot => real().nullable()();
  BoolColumn get watchlist => boolean().withDefault(const Constant(false))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get listIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get accountStateJson => text().withDefault(const Constant('{}'))();
  BoolColumn get localDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get remoteDirty => boolean().withDefault(const Constant(false))();
  IntColumn get lastPulledAt => integer().nullable()();
  IntColumn get lastPushedAt => integer().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {tmdbId, tmdbMediaType},
      ];
}
