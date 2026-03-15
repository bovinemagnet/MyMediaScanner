// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelves_dao.dart';

// ignore_for_file: type=lint
mixin _$ShelvesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShelvesTableTable get shelvesTable => attachedDatabase.shelvesTable;
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $ShelfItemsTableTable get shelfItemsTable => attachedDatabase.shelfItemsTable;
  ShelvesDaoManager get managers => ShelvesDaoManager(this);
}

class ShelvesDaoManager {
  final _$ShelvesDaoMixin _db;
  ShelvesDaoManager(this._db);
  $$ShelvesTableTableTableManager get shelvesTable =>
      $$ShelvesTableTableTableManager(_db.attachedDatabase, _db.shelvesTable);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
  $$ShelfItemsTableTableTableManager get shelfItemsTable =>
      $$ShelfItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.shelfItemsTable,
      );
}
