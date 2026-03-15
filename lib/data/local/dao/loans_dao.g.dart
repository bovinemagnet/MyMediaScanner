// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loans_dao.dart';

// ignore_for_file: type=lint
mixin _$LoansDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaItemsTableTable get mediaItemsTable => attachedDatabase.mediaItemsTable;
  $BorrowersTableTable get borrowersTable => attachedDatabase.borrowersTable;
  $LoansTableTable get loansTable => attachedDatabase.loansTable;
  LoansDaoManager get managers => LoansDaoManager(this);
}

class LoansDaoManager {
  final _$LoansDaoMixin _db;
  LoansDaoManager(this._db);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.mediaItemsTable,
      );
  $$BorrowersTableTableTableManager get borrowersTable =>
      $$BorrowersTableTableTableManager(
        _db.attachedDatabase,
        _db.borrowersTable,
      );
  $$LoansTableTableTableManager get loansTable =>
      $$LoansTableTableTableManager(_db.attachedDatabase, _db.loansTable);
}
