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

  MediaItemsTableCompanion createTestItem({
    required String id,
    String barcode = '9780141036144',
    String title = 'Test Item',
    String? subtitle,
    String? description,
    String? publisher,
    String genres = '[]',
    int deleted = 0,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return MediaItemsTableCompanion(
      id: Value(id),
      barcode: Value(barcode),
      barcodeType: const Value('ean13'),
      mediaType: const Value('dvd'),
      title: Value(title),
      subtitle: Value.absentIfNull(subtitle),
      description: Value.absentIfNull(description),
      publisher: Value.absentIfNull(publisher),
      genres: Value(genres),
      dateAdded: Value(now),
      dateScanned: Value(now),
      updatedAt: Value(now),
      deleted: Value(deleted),
    );
  }

  group('FTS5 full-text search', () {
    test('search by title returns correct items', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'The Matrix',
      ));
      await dao.insertItem(createTestItem(
        id: '3',
        barcode: '3333333333333',
        title: 'Inception',
      ));

      final results = await dao.search('Fight Club');
      expect(results.length, 1);
      expect(results.first.title, 'Fight Club');
    });

    test('search by description works', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
        description: 'An insomniac office worker meets a soap salesman',
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'The Matrix',
        description: 'A computer hacker learns about the true nature of reality',
      ));

      final results = await dao.search('insomniac');
      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('search by publisher works', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
        publisher: 'Fox Studios',
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'The Matrix',
        publisher: 'Warner Bros',
      ));

      final results = await dao.search('Warner');
      expect(results.length, 1);
      expect(results.first.id, '2');
    });

    test('partial/prefix search works', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'The Matrix',
      ));

      final results = await dao.search('Figh');
      expect(results.length, 1);
      expect(results.first.title, 'Fight Club');
    });

    test('deleted items are excluded from search', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
        deleted: 0,
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'Fight Night',
        deleted: 1,
      ));

      final results = await dao.search('Fight');
      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('empty query returns empty list', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
      ));

      final results = await dao.search('');
      expect(results, isEmpty);
    });

    test('watchSearch emits updated results', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
      ));

      final firstResult = await dao.watchSearch('Fight').first;
      expect(firstResult.length, 1);
      expect(firstResult.first.title, 'Fight Club');
    });

    test('search with multiple words matches correctly', () async {
      await dao.insertItem(createTestItem(
        id: '1',
        barcode: '1111111111111',
        title: 'Fight Club',
      ));
      await dao.insertItem(createTestItem(
        id: '2',
        barcode: '2222222222222',
        title: 'Fight Night Round 3',
      ));

      final results = await dao.search('Fight Club');
      expect(results.length, 1);
      expect(results.first.id, '1');
    });
  });
}
