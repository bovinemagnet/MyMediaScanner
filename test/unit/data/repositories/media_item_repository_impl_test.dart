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

  test('countByBarcode counts non-deleted matches', () async {
    await repo.save(baseItem(id: '1').copyWith(barcode: '123'));
    await repo.save(baseItem(id: '2').copyWith(barcode: '123'));
    await repo.save(baseItem(id: '3').copyWith(barcode: '456'));
    await repo.softDelete('2');
    expect(await repo.countByBarcode('123'), 1);
  });

  test('findByBarcode returns non-deleted matches', () async {
    await repo.save(baseItem(id: '1').copyWith(barcode: '999'));
    await repo.save(baseItem(id: '2').copyWith(barcode: '999'));
    await repo.softDelete('1');
    final m = await repo.findByBarcode('999');
    expect(m.map((e) => e.id).toList(), ['2']);
  });

  test('findByTitleYear returns candidates with same year', () async {
    await repo.save(baseItem(id: '1').copyWith(title: 'Dune', year: 1984));
    await repo.save(baseItem(id: '2').copyWith(title: 'Dune', year: 2021));
    await repo.save(baseItem(id: '3').copyWith(title: 'Other', year: 2021));
    final m = await repo.findByTitleYear('Dune', 2021);
    expect(m.map((e) => e.id).toList(), ['2']);
  });

  test('findByTitleYear ignores deleted items', () async {
    await repo.save(baseItem(id: '1').copyWith(title: 'Foo', year: 2000));
    await repo.softDelete('1');
    final m = await repo.findByTitleYear('Foo', 2000);
    expect(m, isEmpty);
  });
}
