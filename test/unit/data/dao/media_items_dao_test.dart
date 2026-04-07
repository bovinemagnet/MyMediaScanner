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
      String title = 'Test Book',
      String mediaType = 'book',
      int? dateAdded,
      int deleted = 0,
    }) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return MediaItemsTableCompanion(
        id: Value(id),
        barcode: Value(barcode),
        barcodeType: const Value('isbn13'),
        mediaType: Value(mediaType),
        title: Value(title),
        dateAdded: Value(dateAdded ?? now),
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

    test('watchAll returns items sorted by title ascending', () async {
      await dao.insertItem(createTestItem(
        id: 'z',
        barcode: '1111111111111',
        title: 'Zebra',
      ));
      await dao.insertItem(createTestItem(
        id: 'a',
        barcode: '2222222222222',
        title: 'Apple',
      ));
      await dao.insertItem(createTestItem(
        id: 'm',
        barcode: '3333333333333',
        title: 'Mango',
      ));

      final items = await dao
          .watchAll(sortBy: 'title', ascending: true)
          .first;
      expect(items.map((e) => e.title).toList(), ['Apple', 'Mango', 'Zebra']);
    });

    test('watchAll returns items sorted by dateAdded descending', () async {
      final baseTime = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      await dao.insertItem(createTestItem(
        id: 'old',
        barcode: '1111111111111',
        title: 'Old Item',
        dateAdded: baseTime,
      ));
      await dao.insertItem(createTestItem(
        id: 'mid',
        barcode: '2222222222222',
        title: 'Mid Item',
        dateAdded: baseTime + 1000,
      ));
      await dao.insertItem(createTestItem(
        id: 'new',
        barcode: '3333333333333',
        title: 'New Item',
        dateAdded: baseTime + 2000,
      ));

      final items = await dao
          .watchAll(sortBy: 'dateAdded', ascending: false)
          .first;
      expect(items.map((e) => e.id).toList(), ['new', 'mid', 'old']);
    });

    test('watchAll filters by mediaType', () async {
      await dao.insertItem(createTestItem(
        id: 'book1',
        barcode: '1111111111111',
        title: 'A Book',
        mediaType: 'book',
      ));
      await dao.insertItem(createTestItem(
        id: 'dvd1',
        barcode: '2222222222222',
        title: 'A DVD',
        mediaType: 'dvd',
      ));
      await dao.insertItem(createTestItem(
        id: 'book2',
        barcode: '3333333333333',
        title: 'Another Book',
        mediaType: 'book',
      ));

      final items = await dao.watchAll(mediaType: 'book').first;
      expect(items.length, 2);
      expect(items.every((e) => e.mediaType == 'book'), isTrue);
    });
  });
}
