// Drift table for batch queue items (persisted across app restarts).
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart';

class BatchQueueItemsTable extends Table {
  @override
  String get tableName => 'batch_queue_items';

  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get barcode => text()();
  TextColumn get barcodeType => text()();
  TextColumn get status => text()();
  IntColumn get scannedAt => integer()();
  TextColumn get metadataJson => text().nullable()();
  TextColumn get scanResultJson => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
