import 'package:drift/drift.dart';

class SyncLogTable extends Table {
  @override
  String get tableName => 'sync_log';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt => integer()();
  IntColumn get attemptedAt => integer().nullable()();
  IntColumn get synced => integer().withDefault(const Constant(0))();

  // New columns added in schema version 7
  TextColumn get errorMessage => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get direction => text().nullable()(); // 'push' or 'pull'
  TextColumn get resolvedBy => text().nullable()(); // 'auto' or 'user'

  @override
  Set<Column> get primaryKey => {id};
}
