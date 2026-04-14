// Unit tests for insights data computation.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/statistics_provider.dart';

void main() {
  group('computeInsightsData', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyOneDaysAgo =
        DateTime.now().subtract(const Duration(days: 31)).millisecondsSinceEpoch;
    final tenDaysAgo =
        DateTime.now().subtract(const Duration(days: 10)).millisecondsSinceEpoch;

    MediaItem makeItem({
      required String id,
      MediaType mediaType = MediaType.film,
      int? dateAdded,
      int? year,
      List<String> genres = const [],
      double? userRating,
      double? pricePaid,
      OwnershipStatus ownershipStatus = OwnershipStatus.owned,
    }) {
      return MediaItem(
        id: id,
        barcode: '123$id',
        barcodeType: 'ean13',
        mediaType: mediaType,
        title: 'Item $id',
        dateAdded: dateAdded ?? now,
        dateScanned: now,
        updatedAt: now,
        year: year,
        genres: genres,
        userRating: userRating,
        pricePaid: pricePaid,
        ownershipStatus: ownershipStatus,
      );
    }

    test('monthly growth groups items by yyyy-MM', () {
      final jan = DateTime(2026, 1, 15).millisecondsSinceEpoch;
      final feb = DateTime(2026, 2, 10).millisecondsSinceEpoch;
      final items = [
        makeItem(id: '1', dateAdded: jan),
        makeItem(id: '2', dateAdded: jan),
        makeItem(id: '3', dateAdded: feb),
      ];

      final result = computeInsightsData(
        items: items,
        activeLoans: [],
        allLoans: [],
        borrowers: [],
        ripAlbums: [],
        rippedItemIds: {},
      );

      expect(result.monthlyGrowth['2026-01'], 2);
      expect(result.monthlyGrowth['2026-02'], 1);
    });

    test('overdue loan detection with custom threshold', () {
      final overdueLoan = Loan(
        id: 'l1',
        mediaItemId: 'i1',
        borrowerId: 'b1',
        lentAt: thirtyOneDaysAgo,
        updatedAt: now,
      );
      final recentLoan = Loan(
        id: 'l2',
        mediaItemId: 'i2',
        borrowerId: 'b1',
        lentAt: tenDaysAgo,
        updatedAt: now,
      );

      final result = computeInsightsData(
        items: [makeItem(id: 'i1'), makeItem(id: 'i2')],
        activeLoans: [overdueLoan, recentLoan],
        allLoans: [overdueLoan, recentLoan],
        borrowers: [
          Borrower(id: 'b1', name: 'Alice', updatedAt: now),
        ],
        ripAlbums: [],
        rippedItemIds: {},
        overdueThreshold: 30,
      );

      expect(result.overdueCount, 1);
      expect(result.activeLoansCount, 2);
    });

    test('top borrowers ranked by active loan count', () {
      final loans = [
        Loan(
            id: 'l1',
            mediaItemId: 'i1',
            borrowerId: 'b1',
            lentAt: now,
            updatedAt: now),
        Loan(
            id: 'l2',
            mediaItemId: 'i2',
            borrowerId: 'b1',
            lentAt: now,
            updatedAt: now),
        Loan(
            id: 'l3',
            mediaItemId: 'i3',
            borrowerId: 'b2',
            lentAt: now,
            updatedAt: now),
      ];
      final borrowers = [
        Borrower(id: 'b1', name: 'Alice', updatedAt: now),
        Borrower(id: 'b2', name: 'Bob', updatedAt: now),
      ];

      final result = computeInsightsData(
        items: [
          makeItem(id: 'i1'),
          makeItem(id: 'i2'),
          makeItem(id: 'i3'),
        ],
        activeLoans: loans,
        allLoans: loans,
        borrowers: borrowers,
        ripAlbums: [],
        rippedItemIds: {},
      );

      expect(result.topBorrowers.keys.first, 'Alice');
      expect(result.topBorrowers['Alice'], 2);
      expect(result.topBorrowers['Bob'], 1);
    });

    test('most borrowed items ranked by total loan count', () {
      final activeLoan = Loan(
          id: 'l1',
          mediaItemId: 'i1',
          borrowerId: 'b1',
          lentAt: now,
          updatedAt: now);
      final returnedLoan = Loan(
          id: 'l2',
          mediaItemId: 'i1',
          borrowerId: 'b1',
          lentAt: thirtyOneDaysAgo,
          returnedAt: tenDaysAgo,
          updatedAt: now);
      final otherLoan = Loan(
          id: 'l3',
          mediaItemId: 'i2',
          borrowerId: 'b1',
          lentAt: now,
          updatedAt: now);

      final result = computeInsightsData(
        items: [makeItem(id: 'i1'), makeItem(id: 'i2')],
        activeLoans: [activeLoan, otherLoan],
        allLoans: [activeLoan, returnedLoan, otherLoan],
        borrowers: [Borrower(id: 'b1', name: 'Alice', updatedAt: now)],
        ripAlbums: [],
        rippedItemIds: {},
      );

      expect(result.mostBorrowedItems.keys.first, 'Item i1');
      expect(result.mostBorrowedItems['Item i1'], 2);
      expect(result.mostBorrowedItems['Item i2'], 1);
    });

    test('rip coverage counts matched vs unmatched', () {
      final rips = [
        RipAlbum(
          id: 'r1',
          libraryPath: '/music/album1',
          trackCount: 10,
          totalSizeBytes: 500000000,
          mediaItemId: 'i1',
          lastScannedAt: now,
          updatedAt: now,
        ),
        RipAlbum(
          id: 'r2',
          libraryPath: '/music/album2',
          trackCount: 8,
          totalSizeBytes: 300000000,
          mediaItemId: null,
          lastScannedAt: now,
          updatedAt: now,
        ),
      ];

      final result = computeInsightsData(
        items: [
          makeItem(id: 'i1', mediaType: MediaType.music),
          makeItem(id: 'i2', mediaType: MediaType.music),
        ],
        activeLoans: [],
        allLoans: [],
        borrowers: [],
        ripAlbums: rips,
        rippedItemIds: {'i1'},
      );

      expect(result.totalRipAlbums, 2);
      expect(result.matchedRipAlbums, 1);
      expect(result.unmatchedRipAlbums, 1);
      expect(result.totalRipSizeBytes, 800000000);
      expect(result.musicItemsWithRips, 1);
      expect(result.totalMusicItems, 2);
    });

    test('empty collection edge case', () {
      final result = computeInsightsData(
        items: [],
        activeLoans: [],
        allLoans: [],
        borrowers: [],
        ripAlbums: [],
        rippedItemIds: {},
      );

      expect(result.totalItems, 0);
      expect(result.byMediaType, isEmpty);
      expect(result.monthlyGrowth, isEmpty);
      expect(result.activeLoansCount, 0);
      expect(result.overdueCount, 0);
      expect(result.totalLoansAllTime, 0);
      expect(result.topBorrowers, isEmpty);
      expect(result.mostBorrowedItems, isEmpty);
      expect(result.totalRipAlbums, 0);
      expect(result.matchedRipAlbums, 0);
      expect(result.unmatchedRipAlbums, 0);
      expect(result.musicItemsWithRips, 0);
      expect(result.totalMusicItems, 0);
      expect(result.averageRating, isNull);
    });

    test('deleted items are excluded from statistics', () {
      final items = [
        makeItem(id: 'i1'),
        MediaItem(
          id: 'i2',
          barcode: '456',
          barcodeType: 'ean13',
          mediaType: MediaType.film,
          title: 'Deleted Item',
          dateAdded: now,
          dateScanned: now,
          updatedAt: now,
          deleted: true,
        ),
      ];

      final result = computeInsightsData(
        items: items,
        activeLoans: [],
        allLoans: [],
        borrowers: [],
        ripAlbums: [],
        rippedItemIds: {},
      );

      expect(result.totalItems, 1);
    });

    group('totalValue', () {
      test('sums pricePaid over owned items, ignoring nulls', () {
        final items = [
          makeItem(id: 'i1', pricePaid: 10.5),
          makeItem(id: 'i2', pricePaid: 4.25),
          makeItem(id: 'i3'), // null pricePaid
        ];

        final result = computeInsightsData(
          items: items,
          activeLoans: [],
          allLoans: [],
          borrowers: [],
          ripAlbums: [],
          rippedItemIds: {},
        );

        expect(result.totalValue, closeTo(14.75, 1e-9));
      });

      test('excludes wishlist items from total value', () {
        final items = [
          makeItem(id: 'i1', pricePaid: 10.0),
          makeItem(
              id: 'i2',
              pricePaid: 99.0,
              ownershipStatus: OwnershipStatus.wishlist),
        ];

        final result = computeInsightsData(
          items: items,
          activeLoans: [],
          allLoans: [],
          borrowers: [],
          ripAlbums: [],
          rippedItemIds: {},
        );

        expect(result.totalValue, 10.0);
      });

      test('returns null when no owned item has a price', () {
        final items = [
          makeItem(id: 'i1'),
          makeItem(id: 'i2'),
        ];

        final result = computeInsightsData(
          items: items,
          activeLoans: [],
          allLoans: [],
          borrowers: [],
          ripAlbums: [],
          rippedItemIds: {},
        );

        expect(result.totalValue, isNull);
      });
    });

    test('deleted rip albums are excluded', () {
      final rips = [
        RipAlbum(
          id: 'r1',
          libraryPath: '/music/album1',
          trackCount: 10,
          totalSizeBytes: 500000000,
          mediaItemId: null,
          lastScannedAt: now,
          updatedAt: now,
        ),
        RipAlbum(
          id: 'r2',
          libraryPath: '/music/album2',
          trackCount: 8,
          totalSizeBytes: 300000000,
          mediaItemId: null,
          lastScannedAt: now,
          updatedAt: now,
          deleted: true,
        ),
      ];

      final result = computeInsightsData(
        items: [],
        activeLoans: [],
        allLoans: [],
        borrowers: [],
        ripAlbums: rips,
        rippedItemIds: {},
      );

      expect(result.totalRipAlbums, 1);
      expect(result.totalRipSizeBytes, 500000000);
    });
  });
}
