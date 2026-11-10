import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';

/// The static export's private filter needs every item's assigned tag
/// names in one query (#131). Assignments live in `media_item_tags`;
/// removed assignments and deleted tags are soft-deleted and must not
/// count.
void main() {
  late AppDatabase db;
  late TagRepositoryImpl tagRepo;

  Future<void> insertTag(String id, String name, {int deleted = 0}) =>
      db.tagsDao.insertTag(TagsTableCompanion(
        id: Value(id),
        name: Value(name),
        updatedAt: const Value(1),
        deleted: Value(deleted),
      ));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tagRepo = TagRepositoryImpl(
      tagsDao: db.tagsDao,
      syncLogDao: db.syncLogDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('maps each media item to the names of its assigned tags', () async {
    await insertTag('t1', 'private');
    await insertTag('t2', 'favourite');
    await tagRepo.assignToMediaItem('t1', 'm1');
    await tagRepo.assignToMediaItem('t2', 'm1');
    await tagRepo.assignToMediaItem('t2', 'm2');

    final names = await tagRepo.getTagNamesByMediaItemId();

    expect(names.keys, unorderedEquals(['m1', 'm2']));
    expect(names['m1'], unorderedEquals(['private', 'favourite']));
    expect(names['m2'], ['favourite']);
  });

  test('skips removed assignments and deleted tags', () async {
    await insertTag('t1', 'private');
    await insertTag('t2', 'gone', deleted: 1);
    await tagRepo.assignToMediaItem('t1', 'm1');
    await tagRepo.removeFromMediaItem('t1', 'm1');
    await tagRepo.assignToMediaItem('t2', 'm2');

    expect(await tagRepo.getTagNamesByMediaItemId(), isEmpty);
  });
}
