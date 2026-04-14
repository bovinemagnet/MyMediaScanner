import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';

void main() {
  late AppDatabase db;
  late MediaItemRepositoryImpl repo;

  MediaItem baseItem({
    required String id,
    OwnershipStatus ownership = OwnershipStatus.owned,
  }) {
    return MediaItem(
      id: id,
      barcode: 'bc-$id',
      barcodeType: 'ean13',
      mediaType: MediaType.book,
      title: 'Title $id',
      dateAdded: 1000,
      dateScanned: 1000,
      updatedAt: 1000,
      ownershipStatus: ownership,
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MediaItemRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('watchByStatus returns only wishlist items', () async {
    await repo.save(baseItem(id: 'a'));
    await repo.save(
        baseItem(id: 'b', ownership: OwnershipStatus.wishlist));
    final list =
        await repo.watchByStatus(OwnershipStatus.wishlist).first;
    expect(list.map((e) => e.id).toList(), ['b']);
  });

  test('watchByStatus excludes deleted items', () async {
    await repo.save(
        baseItem(id: 'w1', ownership: OwnershipStatus.wishlist));
    await repo.save(
        baseItem(id: 'w2', ownership: OwnershipStatus.wishlist));
    await repo.softDelete('w1');
    final list =
        await repo.watchByStatus(OwnershipStatus.wishlist).first;
    expect(list.map((e) => e.id).toList(), ['w2']);
  });
}
