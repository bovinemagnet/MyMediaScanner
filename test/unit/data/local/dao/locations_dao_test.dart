import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> insertLocation(String id, String name, {String? parent}) {
    return db.locationsDao.insertLocation(LocationsTableCompanion(
      id: Value(id),
      parentId: Value(parent),
      name: Value(name),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  group('LocationsDao', () {
    test('getChildren returns roots when parentId is null', () async {
      await insertLocation('1', 'Living room');
      await insertLocation('2', 'Bedroom');
      await insertLocation('3', 'Shelf A', parent: '1');

      final roots = await db.locationsDao.getChildren(null);
      expect(roots.map((r) => r.id), unorderedEquals(['1', '2']));
    });

    test('getChildren returns direct children only', () async {
      await insertLocation('1', 'Room');
      await insertLocation('2', 'Shelf', parent: '1');
      await insertLocation('3', 'Box', parent: '2');

      final children = await db.locationsDao.getChildren('1');
      expect(children.map((r) => r.id), ['2']);
    });

    test('getAncestors returns root-first path', () async {
      await insertLocation('room', 'Living');
      await insertLocation('shelf', 'Shelf A', parent: 'room');
      await insertLocation('box', 'Box 3', parent: 'shelf');

      final path = await db.locationsDao.getAncestors('box');
      expect(path.map((r) => r.id), ['room', 'shelf', 'box']);
    });

    test('getAncestors returns empty when id missing', () async {
      final path = await db.locationsDao.getAncestors('missing');
      expect(path, isEmpty);
    });

    test('softDelete excludes from watchAll', () async {
      await insertLocation('1', 'Room');
      await db.locationsDao.softDelete('1', 1);

      final all = await db.locationsDao.watchAll().first;
      expect(all, isEmpty);
    });

    test('wouldCreateCycle returns true when newParent is self', () async {
      await insertLocation('1', 'Room');
      expect(await db.locationsDao.wouldCreateCycle('1', '1'), isTrue);
    });

    test('wouldCreateCycle returns true when newParent is descendant',
        () async {
      await insertLocation('a', 'A');
      await insertLocation('b', 'B', parent: 'a');
      await insertLocation('c', 'C', parent: 'b');

      // Reparent A under C → cycle.
      expect(await db.locationsDao.wouldCreateCycle('a', 'c'), isTrue);
    });

    test('wouldCreateCycle false for unrelated parent', () async {
      await insertLocation('a', 'A');
      await insertLocation('b', 'B');
      expect(await db.locationsDao.wouldCreateCycle('a', 'b'), isFalse);
    });

    test('wouldCreateCycle false when newParent is null', () async {
      await insertLocation('a', 'A');
      expect(await db.locationsDao.wouldCreateCycle('a', null), isFalse);
    });
  });
}
