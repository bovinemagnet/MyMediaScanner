// Tests for ValuationReportUseCase.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/usecases/valuation_report_usecase.dart';

void main() {
  late ValuationReportUseCase useCase;

  setUp(() {
    useCase = const ValuationReportUseCase();
  });

  MediaItem item({
    required String id,
    String title = 'Title',
    MediaType mediaType = MediaType.film,
    int? year,
    ItemCondition? condition,
    String? retailer,
    int? acquiredAt,
    double? pricePaid,
    OwnershipStatus ownershipStatus = OwnershipStatus.owned,
    bool deleted = false,
  }) {
    return MediaItem(
      id: id,
      barcode: 'b$id',
      barcodeType: 'EAN-13',
      mediaType: mediaType,
      title: title,
      year: year,
      condition: condition,
      retailer: retailer,
      acquiredAt: acquiredAt,
      pricePaid: pricePaid,
      ownershipStatus: ownershipStatus,
      deleted: deleted,
      dateAdded: 1700000000,
      dateScanned: 1700000000,
      updatedAt: 1700000000,
    );
  }

  group('computeTotals', () {
    test('sums priced owned items per media type and overall', () {
      final result = useCase.computeTotals([
        item(id: '1', mediaType: MediaType.film, pricePaid: 10.0),
        item(id: '2', mediaType: MediaType.film, pricePaid: 5.0),
        item(id: '3', mediaType: MediaType.music, pricePaid: 20.0),
      ]);

      expect(result.byMediaType[MediaType.film], 15.0);
      expect(result.byMediaType[MediaType.music], 20.0);
      expect(result.grandTotal, 35.0);
    });

    test('excludes wishlist, deleted, and unpriced items', () {
      final result = useCase.computeTotals([
        item(id: 'owned', pricePaid: 10.0),
        item(
            id: 'wish',
            pricePaid: 999.0,
            ownershipStatus: OwnershipStatus.wishlist),
        item(id: 'deleted', pricePaid: 999.0, deleted: true),
        item(id: 'unpriced'),
      ]);

      expect(result.grandTotal, 10.0);
      expect(result.byMediaType, hasLength(1));
    });

    test('returns zero totals when no items qualify', () {
      final result = useCase.computeTotals([item(id: 'a')]);

      expect(result.grandTotal, 0.0);
      expect(result.byMediaType, isEmpty);
    });
  });

  group('generateCsv', () {
    test('emits header and one row per priced owned item', () {
      final csv = useCase.generateCsv([
        item(
          id: 'a',
          title: 'A Title',
          mediaType: MediaType.book,
          year: 2024,
          condition: ItemCondition.nearMint,
          retailer: 'Bookshop',
          acquiredAt: 1701000000,
          pricePaid: 12.50,
        ),
      ]);

      final lines = csv.split('\n');
      expect(lines.first,
          equals('title,mediaType,year,condition,retailer,acquiredAt,pricePaid'));
      expect(lines[1], contains('A Title'));
      expect(lines[1], contains('book'));
      expect(lines[1], contains('2024'));
      expect(lines[1], contains('nearMint'));
      expect(lines[1], contains('Bookshop'));
      expect(lines[1], contains('1701000000'));
      expect(lines[1], contains('12.5'));
    });

    test('excludes unpriced, wishlist, and deleted items', () {
      final csv = useCase.generateCsv([
        item(id: 'priced', title: 'Keep', pricePaid: 5.0),
        item(id: 'unpriced', title: 'Skip Unpriced'),
        item(
            id: 'wish',
            title: 'Skip Wishlist',
            pricePaid: 99.0,
            ownershipStatus: OwnershipStatus.wishlist),
        item(id: 'del', title: 'Skip Deleted', pricePaid: 99.0, deleted: true),
      ]);

      expect(csv, contains('Keep'));
      expect(csv, isNot(contains('Skip Unpriced')));
      expect(csv, isNot(contains('Skip Wishlist')));
      expect(csv, isNot(contains('Skip Deleted')));
    });

    test('escapes commas, quotes, and newlines in title or retailer', () {
      final csv = useCase.generateCsv([
        item(
          id: 'a',
          title: 'Greatest, "Hits"',
          retailer: 'Local\nShop',
          pricePaid: 10.0,
        ),
      ]);

      // Title field should be quoted and embedded quotes doubled.
      expect(csv, contains('"Greatest, ""Hits"""'));
      // Newline in retailer should be quoted as well.
      expect(csv, contains('"Local\nShop"'));
    });
  });

  group('generateHtml', () {
    test('includes grand total, per-type totals and per-item rows', () {
      final html = useCase.generateHtml(
        [
          item(
            id: 'a',
            title: 'Pricey Vinyl',
            mediaType: MediaType.music,
            pricePaid: 50.0,
          ),
          item(
            id: 'b',
            title: 'Book One',
            mediaType: MediaType.book,
            pricePaid: 10.0,
          ),
        ],
        generatedAt: DateTime.utc(2026, 5, 15, 12, 30),
      );

      expect(html, contains('<html'));
      expect(html, contains('Valuation Report'));
      expect(html, contains('Pricey Vinyl'));
      expect(html, contains('Book One'));
      expect(html, contains('2026-05-15'));
      // Currency formatting is locale-dependent; check the raw numbers
      // appear somewhere in the report.
      expect(html, contains('50'));
      expect(html, contains('60'));
    });

    test('renders empty-state notice when no priced items', () {
      final html = useCase.generateHtml(
        [item(id: 'a')],
        generatedAt: DateTime.utc(2026, 5, 15),
      );

      expect(html, contains('No priced items'));
    });

    test('escapes HTML in titles and retailers', () {
      final html = useCase.generateHtml(
        [
          item(
            id: 'a',
            title: '<script>alert(1)</script>',
            retailer: 'Mom & Pop',
            pricePaid: 1.0,
          ),
        ],
        generatedAt: DateTime.utc(2026, 5, 15),
      );

      expect(html, isNot(contains('<script>alert(1)</script>')));
      expect(html, contains('&lt;script&gt;'));
      expect(html, contains('Mom &amp; Pop'));
    });
  });
}
