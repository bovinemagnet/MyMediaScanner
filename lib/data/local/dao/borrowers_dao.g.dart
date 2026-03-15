// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrowers_dao.dart';

// ignore_for_file: type=lint
mixin _$BorrowersDaoMixin on DatabaseAccessor<AppDatabase> {
  $BorrowersTableTable get borrowersTable => attachedDatabase.borrowersTable;
  BorrowersDaoManager get managers => BorrowersDaoManager(this);
}

class BorrowersDaoManager {
  final _$BorrowersDaoMixin _db;
  BorrowersDaoManager(this._db);
  $$BorrowersTableTableTableManager get borrowersTable =>
      $$BorrowersTableTableTableManager(
        _db.attachedDatabase,
        _db.borrowersTable,
      );
}
