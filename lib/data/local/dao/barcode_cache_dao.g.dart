// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$BarcodeCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $BarcodeCacheTableTable get barcodeCacheTable =>
      attachedDatabase.barcodeCacheTable;
  BarcodeCacheDaoManager get managers => BarcodeCacheDaoManager(this);
}

class BarcodeCacheDaoManager {
  final _$BarcodeCacheDaoMixin _db;
  BarcodeCacheDaoManager(this._db);
  $$BarcodeCacheTableTableTableManager get barcodeCacheTable =>
      $$BarcodeCacheTableTableTableManager(
        _db.attachedDatabase,
        _db.barcodeCacheTable,
      );
}
