import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/rip_library_repository_impl.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

void main() {
  group('RipStatus', () {
    test('has expected values', () {
      expect(RipStatus.values, [
        RipStatus.noRip,
        RipStatus.ripped,
        RipStatus.verified,
        RipStatus.qualityIssues,
      ]);
    });

    test('noRip is first value', () {
      expect(RipStatus.values.first, RipStatus.noRip);
    });

    test('verified is distinct from ripped', () {
      expect(RipStatus.verified, isNot(RipStatus.ripped));
    });

    test('qualityIssues is distinct from verified', () {
      expect(RipStatus.qualityIssues, isNot(RipStatus.verified));
    });
  });

  group('RipStatusFilter', () {
    test('has expected values', () {
      expect(RipStatusFilter.values, [
        RipStatusFilter.all,
        RipStatusFilter.hasRip,
        RipStatusFilter.noRip,
        RipStatusFilter.verified,
        RipStatusFilter.qualityIssues,
      ]);
    });

    test('all is first value', () {
      expect(RipStatusFilter.values.first, RipStatusFilter.all);
    });

    test('hasRip is distinct from noRip', () {
      expect(RipStatusFilter.hasRip, isNot(RipStatusFilter.noRip));
    });

    test('verified is distinct from qualityIssues', () {
      expect(RipStatusFilter.verified, isNot(RipStatusFilter.qualityIssues));
    });
  });

  group('RipStatusFilterNotifier', () {
    test('initial state is all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(ripStatusFilterProvider), RipStatusFilter.all);
    });

    test('setFilter updates state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(ripStatusFilterProvider.notifier)
          .setFilter(RipStatusFilter.hasRip);
      expect(container.read(ripStatusFilterProvider), RipStatusFilter.hasRip);
    });

    test('setFilter to same value is idempotent', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(ripStatusFilterProvider.notifier)
          .setFilter(RipStatusFilter.noRip);
      container
          .read(ripStatusFilterProvider.notifier)
          .setFilter(RipStatusFilter.noRip);
      expect(container.read(ripStatusFilterProvider), RipStatusFilter.noRip);
    });

    test('setFilter cycles through all values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      for (final filter in RipStatusFilter.values) {
        container.read(ripStatusFilterProvider.notifier).setFilter(filter);
        expect(container.read(ripStatusFilterProvider), filter);
      }
    });
  });

  group('ripQualityStatusCacheProvider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(overrides: [
        ripLibraryRepositoryProvider.overrideWithValue(
          RipLibraryRepositoryImpl(ripLibraryDao: db.ripLibraryDao),
        ),
      ]);
      addTearDown(container.dispose);
      addTearDown(() async => db.close());
    });

    Future<void> insertMediaItem(String id) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.mediaItemsTable).insert(MediaItemsTableCompanion(
            id: Value(id),
            barcode: Value('barcode-$id'),
            barcodeType: const Value('ean13'),
            mediaType: const Value('music'),
            title: Value('Item $id'),
            dateAdded: Value(now),
            dateScanned: Value(now),
            updatedAt: Value(now),
          ));
    }

    Future<void> insertAlbum(String id, String mediaItemId) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.ripLibraryDao.insertAlbum(RipAlbumsTableCompanion(
        id: Value(id),
        libraryPath: Value('Artist/$id'),
        trackCount: const Value(2),
        totalSizeBytes: const Value(1000),
        mediaItemId: Value(mediaItemId),
        lastScannedAt: Value(now),
        updatedAt: Value(now),
      ));
    }

    Future<void> insertTrack(String id, String albumId, int trackNumber) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return db.ripLibraryDao.insertTracks([
        RipTracksTableCompanion(
          id: Value(id),
          ripAlbumId: Value(albumId),
          trackNumber: Value(trackNumber),
          filePath: Value('/music/$id.flac'),
          fileSizeBytes: const Value(100),
          updatedAt: Value(now),
        ),
      ]);
    }

    /// Fixture: one verified album, one with quality issues, one with no
    /// quality data yet.
    Future<void> seedFixture() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await insertMediaItem('item-verified');
      await insertMediaItem('item-issues');
      await insertMediaItem('item-ripped');

      await insertAlbum('rip-verified', 'item-verified');
      await insertTrack('tv1', 'rip-verified', 1);
      await insertTrack('tv2', 'rip-verified', 2);
      await db.ripLibraryDao.updateTrackQuality('tv1',
          arStatus: 'verified', qualityCheckedAt: now);
      await db.ripLibraryDao.updateTrackQuality('tv2',
          arStatus: 'verified', qualityCheckedAt: now);

      await insertAlbum('rip-issues', 'item-issues');
      await insertTrack('ti1', 'rip-issues', 1);
      await db.ripLibraryDao.updateTrackQuality('ti1',
          arStatus: 'verified', clickCount: 3, qualityCheckedAt: now);

      await insertAlbum('rip-ripped', 'item-ripped');
      await insertTrack('tr1', 'rip-ripped', 1);
      // No quality data on tr1.
    }

    Future<Map<String, RipStatus>> readCache() async {
      // Riverpod 3 pauses the inner stream subscriptions of providers with
      // no active listeners, so listen before awaiting their futures.
      container.listen(rippedItemIdsProvider, (_, _) {});
      await container.read(rippedItemIdsProvider.future);
      container.listen(ripQualityStatusCacheProvider, (_, _) {});
      return container.read(ripQualityStatusCacheProvider.future);
    }

    test('classifies verified, quality-issues, and unanalysed items',
        () async {
      await seedFixture();

      final cache = await readCache();

      expect(cache, {
        'item-verified': RipStatus.verified,
        'item-issues': RipStatus.qualityIssues,
        'item-ripped': RipStatus.ripped,
      });
    });

    test('mismatched AccurateRip status counts as quality issue', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await insertMediaItem('item-1');
      await insertAlbum('rip-1', 'item-1');
      await insertTrack('t1', 'rip-1', 1);
      await db.ripLibraryDao.updateTrackQuality('t1',
          arStatus: 'mismatch', qualityCheckedAt: now);

      final cache = await readCache();

      expect(cache, {'item-1': RipStatus.qualityIssues});
    });

    test('matches the old per-item album + tracks derivation', () async {
      await seedFixture();

      final cache = await readCache();

      // Replicate the previous N+1 derivation exactly: per ripped item,
      // resolve the album, fetch its tracks, classify.
      final rippedIds = await container.read(rippedItemIdsProvider.future);
      final expected = <String, RipStatus>{};
      for (final itemId in rippedIds) {
        container.listen(ripAlbumForItemProvider(itemId), (_, _) {});
        final album =
            await container.read(ripAlbumForItemProvider(itemId).future);
        if (album == null) {
          expected[itemId] = RipStatus.ripped;
          continue;
        }
        container.listen(ripTracksProvider(album.id), (_, _) {});
        final tracks =
            await container.read(ripTracksProvider(album.id).future);
        final tracksWithData =
            tracks.where((t) => t.qualityCheckedAt != null).toList();
        if (tracksWithData.isEmpty) {
          expected[itemId] = RipStatus.ripped;
          continue;
        }
        final hasIssues = tracksWithData.any((t) =>
            (t.accurateRipStatus != null &&
                t.accurateRipStatus != 'verified') ||
            t.totalDefects > 0);
        expected[itemId] =
            hasIssues ? RipStatus.qualityIssues : RipStatus.verified;
      }

      expect(cache, expected);
    });
  });

  group('CollectionRipStats', () {
    test('coveragePercentage (noRip getter) is 0 when no items', () {
      const stats = CollectionRipStats(
        total: 0,
        ripped: 0,
        verified: 0,
        qualityIssues: 0,
      );
      expect(stats.noRip, 0);
    });

    test('noRip calculates correctly', () {
      const stats = CollectionRipStats(
        total: 10,
        ripped: 3,
        verified: 2,
        qualityIssues: 1,
      );
      expect(stats.noRip, 7);
    });

    test('noRip is 0 when all items are ripped', () {
      const stats = CollectionRipStats(
        total: 5,
        ripped: 5,
        verified: 5,
        qualityIssues: 0,
      );
      expect(stats.noRip, 0);
    });

    test('default constructor sets all fields to 0', () {
      const stats = CollectionRipStats();
      expect(stats.total, 0);
      expect(stats.ripped, 0);
      expect(stats.verified, 0);
      expect(stats.qualityIssues, 0);
      expect(stats.noRip, 0);
    });

    test('fields are accessible and correct', () {
      const stats = CollectionRipStats(
        total: 20,
        ripped: 12,
        verified: 8,
        qualityIssues: 4,
      );
      expect(stats.total, 20);
      expect(stats.ripped, 12);
      expect(stats.verified, 8);
      expect(stats.qualityIssues, 4);
      expect(stats.noRip, 8);
    });
  });
}
