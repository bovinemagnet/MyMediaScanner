// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_dao.dart';

// ignore_for_file: type=lint
mixin _$SeriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SeriesTableTable get seriesTable => attachedDatabase.seriesTable;
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  SeriesDaoManager get managers => SeriesDaoManager(this);
}

class SeriesDaoManager {
  final _$SeriesDaoMixin _db;
  SeriesDaoManager(this._db);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db.attachedDatabase, _db.seriesTable);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
}
