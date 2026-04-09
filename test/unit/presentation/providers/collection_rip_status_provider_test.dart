import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

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
