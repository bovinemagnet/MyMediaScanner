import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';

class _MockMirror extends Mock implements MirrorOwnershipChangeUseCase {}

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

  group('watchAll tagIds filter (cluster-7 MED-2 regression)', () {
    Future<void> seedTag(String id, String name) async {
      await db.tagsDao.insertTag(TagsTableCompanion.insert(
        id: id,
        name: name,
        updatedAt: 1,
      ));
    }

    Future<void> assign(String tagId, String mediaItemId) async {
      await db.tagsDao.assignToMediaItem(tagId, mediaItemId);
    }

    test('null/empty tagIds returns every non-deleted row', () async {
      await repo.save(baseItem(id: 'a'));
      await repo.save(baseItem(id: 'b'));
      final all = await repo.watchAll().first;
      expect(all.map((e) => e.id).toSet(), {'a', 'b'});
      final allEmpty = await repo.watchAll(tagIds: const []).first;
      expect(allEmpty.map((e) => e.id).toSet(), {'a', 'b'});
    });

    test('single tag matches only assigned rows', () async {
      await repo.save(baseItem(id: 'a'));
      await repo.save(baseItem(id: 'b'));
      await repo.save(baseItem(id: 'c'));
      await seedTag('t1', 'Sci-Fi');
      await assign('t1', 'a');
      await assign('t1', 'c');

      final filtered = await repo.watchAll(tagIds: const ['t1']).first;
      expect(filtered.map((e) => e.id).toSet(), {'a', 'c'});
    });

    test('multiple tagIds is a UNION (any match)', () async {
      await repo.save(baseItem(id: 'a'));
      await repo.save(baseItem(id: 'b'));
      await repo.save(baseItem(id: 'c'));
      await seedTag('t1', 'A');
      await seedTag('t2', 'B');
      await assign('t1', 'a');
      await assign('t2', 'b');

      final filtered =
          await repo.watchAll(tagIds: const ['t1', 't2']).first;
      expect(filtered.map((e) => e.id).toSet(), {'a', 'b'});
    });

    test('tagIds combined with mediaType narrows correctly', () async {
      await repo.save(baseItem(id: 'a').copyWith(mediaType: MediaType.book));
      await repo.save(baseItem(id: 'b').copyWith(mediaType: MediaType.film));
      await seedTag('t1', 'Fav');
      await assign('t1', 'a');
      await assign('t1', 'b');

      final books = await repo
          .watchAll(mediaType: MediaType.book, tagIds: const ['t1'])
          .first;
      expect(books.map((e) => e.id).toSet(), {'a'});
    });

    test('tagIds with FTS searchQuery still applies tag filter', () async {
      await repo.save(baseItem(id: 'a').copyWith(title: 'Dune'));
      await repo.save(baseItem(id: 'b').copyWith(title: 'Dune Messiah'));
      await seedTag('t1', 'Owned');
      await assign('t1', 'b');

      final filtered = await repo
          .watchAll(searchQuery: 'Dune', tagIds: const ['t1'])
          .first;
      expect(filtered.map((e) => e.id).toSet(), {'b'});
    });
  });

  group('mirror auto-remove hook on update', () {
    late _MockMirror mirror;
    late bool mirrorEnabled;

    setUp(() {
      mirror = _MockMirror();
      mirrorEnabled = true;
      when(() => mirror.add(tmdbId: any(named: 'tmdbId'))).thenAnswer(
          (_) async => const TmdbPushResult(success: true));
      when(() => mirror.remove(tmdbId: any(named: 'tmdbId'))).thenAnswer(
          (_) async => const TmdbPushResult(success: true));
    });

    MediaItemRepositoryImpl makeRepo() => MediaItemRepositoryImpl(
          mediaItemsDao: db.mediaItemsDao,
          syncLogDao: db.syncLogDao,
          mirror: mirror,
          readMirrorEnabled: () => mirrorEnabled,
        );

    MediaItem movieItem({
      required String id,
      required OwnershipStatus ownership,
      int? tmdbId = 550,
      String mediaType = 'movie',
    }) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return MediaItem(
        id: id,
        title: 'Fight Club',
        mediaType: MediaType.film,
        ownershipStatus: ownership,
        barcode: '',
        barcodeType: '',
        extraMetadata: {
          'tmdb_id': tmdbId,
          'media_type': mediaType,
        }..removeWhere((_, v) => v == null),
        dateAdded: now,
        dateScanned: now,
        updatedAt: now,
      );
    }

    // Seed using repo.save — same insertion path used by all other tests in
    // this file.  We must not use repo.update here because that would invoke
    // the very hook under test.
    Future<void> seed(MediaItem item) => repo.save(item);

    test('update non-owned → owned fires mirror.add', () async {
      final r = makeRepo();
      final wishlist =
          movieItem(id: 'a', ownership: OwnershipStatus.wishlist);
      await seed(wishlist);

      await r.update(movieItem(id: 'a', ownership: OwnershipStatus.owned));

      verify(() => mirror.add(tmdbId: 550)).called(1);
      verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
    });

    test('update owned → not-owned fires mirror.remove', () async {
      final r = makeRepo();
      await seed(movieItem(id: 'b', ownership: OwnershipStatus.owned));

      await r.update(
          movieItem(id: 'b', ownership: OwnershipStatus.wishlist));

      verify(() => mirror.remove(tmdbId: 550)).called(1);
      verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('update owned → owned (rating-only) does not fire mirror', () async {
      final r = makeRepo();
      await seed(movieItem(id: 'c', ownership: OwnershipStatus.owned));

      await r.update(
        movieItem(id: 'c', ownership: OwnershipStatus.owned)
            .copyWith(userRating: 4.5),
      );

      verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
      verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
    });

    test('update with mirror disabled does not fire mirror', () async {
      mirrorEnabled = false;
      final r = makeRepo();
      await seed(movieItem(id: 'd', ownership: OwnershipStatus.wishlist));

      await r.update(
          movieItem(id: 'd', ownership: OwnershipStatus.owned));

      verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('update non-owned → owned for TV does not fire mirror', () async {
      final r = makeRepo();
      final tvItem = movieItem(
        id: 'e',
        ownership: OwnershipStatus.wishlist,
        mediaType: 'tv',
      );
      await seed(tvItem);

      await r.update(tvItem.copyWith(ownershipStatus: OwnershipStatus.owned));

      verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('update non-owned → owned without TMDB ID does not fire mirror',
        () async {
      final r = makeRepo();
      final noTmdb = movieItem(
        id: 'f',
        ownership: OwnershipStatus.wishlist,
        tmdbId: null,
      );
      await seed(noTmdb);

      await r.update(
          noTmdb.copyWith(ownershipStatus: OwnershipStatus.owned));

      verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('softDelete on owned movie fires mirror.remove', () async {
      final r = makeRepo();
      await seed(movieItem(id: 'g', ownership: OwnershipStatus.owned));

      await r.softDelete('g');

      verify(() => mirror.remove(tmdbId: 550)).called(1);
    });

    test('softDelete on non-owned item does not fire mirror', () async {
      final r = makeRepo();
      await seed(movieItem(id: 'h', ownership: OwnershipStatus.wishlist));

      await r.softDelete('h');

      verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
    });

    test('softDelete on owned TV item does not fire mirror', () async {
      final r = makeRepo();
      final tvOwned = movieItem(
        id: 'i',
        ownership: OwnershipStatus.owned,
        mediaType: 'tv',
      );
      await seed(tvOwned);

      await r.softDelete('i');

      verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
    });
  });
}
