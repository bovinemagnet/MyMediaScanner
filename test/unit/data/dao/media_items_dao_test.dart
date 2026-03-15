import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';

void main() {
  late AppDatabase db;
  late MediaItemsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.mediaItemsDao;
  });

  tearDown(() => db.close());

  group('MediaItemsDao', () {
    MediaItemsTableCompanion createTestItem({
      String id = 'test-id',
      String barcode = '9780141036144',
      int deleted = 0,
    }) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return MediaItemsTableCompanion(
        id: Value(id),
        barcode: Value(barcode),
        barcodeType: const Value('isbn13'),
        mediaType: const Value('book'),
        title: const Value('Test Book'),
        dateAdded: Value(now),
        dateScanned: Value(now),
        updatedAt: Value(now),
        deleted: Value(deleted),
      );
    }

    test('insertItem and getById returns item', () async {
      await dao.insertItem(createTestItem());
      final result = await dao.getById('test-id');
      expect(result, isNotNull);
      expect(result!.title, 'Test Book');
    });

    test('barcodeExists returns true for existing barcode', () async {
      await dao.insertItem(createTestItem());
      expect(await dao.barcodeExists('9780141036144'), isTrue);
    });

    test('barcodeExists returns false for missing barcode', () async {
      expect(await dao.barcodeExists('0000000000000'), isFalse);
    });

    test('softDelete sets deleted flag', () async {
      await dao.insertItem(createTestItem());
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.softDelete('test-id', now);
      final result = await dao.getById('test-id');
      expect(result!.deleted, 1);
    });

    test('watchAll excludes deleted items by default', () async {
      await dao.insertItem(createTestItem(id: 'a'));
      await dao.insertItem(createTestItem(id: 'b', barcode: '1234567890123', deleted: 1));

      final items = await dao.watchAll().first;
      expect(items.length, 1);
      expect(items.first.id, 'a');
    });

    test('watchAll includes deleted when requested', () async {
      await dao.insertItem(createTestItem(id: 'a'));
      await dao.insertItem(createTestItem(id: 'b', barcode: '1234567890123', deleted: 1));

      final items = await dao.watchAll(includeDeleted: true).first;
      expect(items.length, 2);
    });
  });
}
