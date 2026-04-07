// Drift table for batch scanning sessions.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';

class BatchSessionsTable extends Table {
  @override
  String get tableName => 'batch_sessions';

  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
