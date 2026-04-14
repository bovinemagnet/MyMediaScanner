import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

void main() {
  test('v12 schema exposes ownership and purchase columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    // Trigger creation via a no-op query
    await db.customSelect('SELECT 1').get();

    final rows = await db.customSelect(
      "SELECT name FROM pragma_table_info('media_items')",
    ).get();
    final names = rows.map((r) => r.data['name'] as String).toSet();
    expect(
        names,
        containsAll([
          'ownership_status',
          'condition',
          'price_paid',
          'acquired_at',
          'retailer',
        ]));
  });
}
