import 'package:drift/drift.dart';

class MediaItemsTable extends Table {
  @override
  String get tableName => 'media_items';

  TextColumn get id => text()();
  TextColumn get barcode => text()();
  TextColumn get barcodeType => text()();
  TextColumn get mediaType => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get genres => text().withDefault(const Constant('[]'))();
  TextColumn get extraMetadata => text().withDefault(const Constant('{}'))();
  TextColumn get sourceApis => text().withDefault(const Constant('[]'))();
  RealColumn get userRating => real().nullable()();
  TextColumn get userReview => text().nullable()();
  RealColumn get criticScore => real().nullable()();
  TextColumn get criticSource => text().nullable()();
  IntColumn get dateAdded => integer()();
  IntColumn get dateScanned => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();
  TextColumn get ownershipStatus =>
      text().withDefault(const Constant('owned'))();
  TextColumn get condition => text().nullable()();
  RealColumn get pricePaid => real().nullable()();
  IntColumn get acquiredAt => integer().nullable()();
  TextColumn get retailer => text().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get seriesId => text().nullable()();
  IntColumn get seriesPosition => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
