import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';

void main() {
  group('PostgresSyncClient', () {
    test('buildBatchUpsertSql generates correct SQL for multiple records', () {
      final records = [
        {'id': '1', 'title': 'A', 'updated_at': 100},
        {'id': '2', 'title': 'B', 'updated_at': 200},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      expect(result.sql, contains('INSERT INTO media_items'));
      expect(result.sql, contains('ON CONFLICT (id) DO UPDATE'));
      expect(result.params.length, 6); // 3 columns × 2 records
    });

    test('buildBatchUpsertSql handles single record', () {
      final records = [
        {'id': '1', 'title': 'A'},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      expect(result.sql, contains('INSERT INTO media_items'));
      expect(result.params.length, 2);
    });

    test('buildBatchUpsertSql generates correct value placeholders', () {
      final records = [
        {'id': '1', 'title': 'A'},
        {'id': '2', 'title': 'B'},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      // Should have two value clauses with sequential placeholders
      expect(result.sql, contains(r'($1, $2)'));
      expect(result.sql, contains(r'($3, $4)'));
    });

    test('buildBatchUpsertSql excludes id from update clause', () {
      final records = [
        {'id': '1', 'title': 'A', 'updated_at': 100},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      expect(result.sql, contains('title = EXCLUDED.title'));
      expect(result.sql, contains('updated_at = EXCLUDED.updated_at'));
      // id should not appear in the SET clause
      expect(result.sql, isNot(contains('id = EXCLUDED.id')));
    });

    test('buildBatchUpsertSql preserves parameter order', () {
      final records = [
        {'id': '1', 'title': 'First', 'updated_at': 100},
        {'id': '2', 'title': 'Second', 'updated_at': 200},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      expect(result.params, [
        '1', 'First', 100,
        '2', 'Second', 200,
      ]);
    });

    test('buildBatchUpsertSql throws on empty records list', () {
      // records.first is called immediately, so an empty list should throw
      expect(
        () => PostgresSyncClient.buildBatchUpsertSql('media_items', []),
        throwsA(isA<StateError>()),
      );
    });

    test('buildBatchUpsertSql produces single statement for exactly 50 records',
        () {
      final records = List.generate(
        50,
        (i) => {'id': '$i', 'title': 'Item $i', 'updated_at': i * 100},
      );

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      // Should contain 50 value rows (one per record)
      final valueMatches = RegExp(r'\(\$\d+, \$\d+, \$\d+\)').allMatches(result.sql);
      expect(valueMatches.length, 50);
      // Total params: 50 records × 3 columns
      expect(result.params.length, 150);
    });

    test('buildBatchUpsertSql produces correct param count for 51 records', () {
      final records = List.generate(
        51,
        (i) => {'id': '$i', 'title': 'Item $i', 'updated_at': i * 100},
      );

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      // buildBatchUpsertSql does not split — that is upsertRecords' job.
      // So we expect all 51 records in one statement.
      final valueMatches = RegExp(r'\(\$\d+, \$\d+, \$\d+\)').allMatches(result.sql);
      expect(valueMatches.length, 51);
      // Total params: 51 records × 3 columns
      expect(result.params.length, 153);
    });

    test('buildBatchUpsertSql with single column record (only id)', () {
      final records = [
        {'id': '1'},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      // The UPDATE SET clause excludes 'id', leaving it empty.
      // This produces invalid SQL: "ON CONFLICT (id) DO UPDATE SET "
      // but buildBatchUpsertSql does not validate — it simply builds the string.
      expect(result.sql, contains('INSERT INTO media_items (id)'));
      expect(result.sql, contains(r'($1)'));
      expect(result.params, ['1']);
      // The SET clause should be empty (only 'id' was present, and it is excluded)
      expect(result.sql, contains('DO UPDATE SET '));
      expect(result.sql, isNot(contains('id = EXCLUDED.id')));
    });
  });
}
