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
        'test_table',
        records,
      );

      expect(result.sql, contains('INSERT INTO test_table'));
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
  });
}
