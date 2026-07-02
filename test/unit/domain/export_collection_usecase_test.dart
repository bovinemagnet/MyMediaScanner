import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late ExportCollectionUseCase useCase;
  late MockMediaItemRepository mockRepo;

  final testItems = [
    const MediaItem(
      id: 'id-1',
      barcode: '9780141036144',
      barcodeType: 'ISBN-13',
      mediaType: MediaType.book,
      title: '1984',
      subtitle: 'A Novel',
      year: 1949,
      publisher: 'Penguin',
      format: 'Paperback',
      genres: ['Fiction', 'Dystopian'],
      userRating: 4.5,
      userReview: 'A masterpiece',
      dateAdded: 1700000000,
      dateScanned: 1700000000,
      updatedAt: 1700000000,
    ),
    const MediaItem(
      id: 'id-2',
      barcode: '5051892002196',
      barcodeType: 'EAN-13',
      mediaType: MediaType.film,
      title: 'Inception',
      year: 2010,
      publisher: 'Warner Bros',
      format: 'Blu-ray',
      genres: ['Sci-Fi', 'Thriller'],
      dateAdded: 1700100000,
      dateScanned: 1700100000,
      updatedAt: 1700100000,
    ),
  ];

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = ExportCollectionUseCase(repository: mockRepo);

    when(() => mockRepo.watchAll(
          mediaType: any(named: 'mediaType'),
          searchQuery: any(named: 'searchQuery'),
          tagIds: any(named: 'tagIds'),
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) => Stream.value(testItems));
  });

  group('ExportCollectionUseCase', () {
    test('CSV export produces correct header and data rows', () async {
      final content = await useCase.generateContent(ExportFormat.csv);
      final lines = content.split('\n');

      expect(lines.length, equals(3)); // header + 2 data rows

      expect(
        lines[0],
        equals(
          'barcode,barcodeType,mediaType,title,subtitle,year,publisher,'
          'format,genres,userRating,userReview,dateAdded,dateScanned,'
          'condition,pricePaid,retailer,acquiredAt',
        ),
      );

      // First item
      expect(lines[1], contains('9780141036144'));
      expect(lines[1], contains('ISBN-13'));
      expect(lines[1], contains('book'));
      expect(lines[1], contains('1984'));
      expect(lines[1], contains('A Novel'));
      expect(lines[1], contains('1949'));
      expect(lines[1], contains('Penguin'));
      expect(lines[1], contains('Paperback'));
      expect(lines[1], contains('Fiction;Dystopian'));
      expect(lines[1], contains('4.5'));
      expect(lines[1], contains('A masterpiece'));

      // Second item
      expect(lines[2], contains('5051892002196'));
      expect(lines[2], contains('Inception'));
      expect(lines[2], contains('film'));
    });

    test('JSON export produces valid JSON array', () async {
      final content = await useCase.generateContent(ExportFormat.json);

      final decoded = jsonDecode(content);
      expect(decoded, isA<List>());

      final list = decoded as List<dynamic>;
      expect(list.length, equals(2));

      final first = list[0] as Map<String, dynamic>;
      expect(first['barcode'], equals('9780141036144'));
      expect(first['title'], equals('1984'));
      expect(first['mediaType'], equals('book'));
      expect(first['genres'], equals(['Fiction', 'Dystopian']));
      expect(first['year'], equals(1949));
      expect(first['userRating'], equals(4.5));

      final second = list[1] as Map<String, dynamic>;
      expect(second['barcode'], equals('5051892002196'));
      expect(second['title'], equals('Inception'));
      expect(second['mediaType'], equals('film'));
    });

    test('CSV escapes fields containing commas', () async {
      final itemWithComma = [
        const MediaItem(
          id: 'id-3',
          barcode: '1234567890',
          barcodeType: 'UPC-A',
          mediaType: MediaType.music,
          title: 'Greatest Hits, Vol. 1',
          genres: [],
          dateAdded: 1700200000,
          dateScanned: 1700200000,
          updatedAt: 1700200000,
        ),
      ];

      when(() => mockRepo.watchAll(
            mediaType: any(named: 'mediaType'),
            searchQuery: any(named: 'searchQuery'),
            tagIds: any(named: 'tagIds'),
            sortBy: any(named: 'sortBy'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) => Stream.value(itemWithComma));

      final content = await useCase.generateContent(ExportFormat.csv);
      final lines = content.split('\n');

      expect(lines[1], contains('"Greatest Hits, Vol. 1"'));
    });

    test('CSV neutralises cells starting with formula characters', () async {
      final maliciousItems = [
        const MediaItem(
          id: 'id-formula',
          barcode: '2222222222222',
          barcodeType: 'EAN-13',
          mediaType: MediaType.music,
          title: '=HYPERLINK("http://evil.example")',
          subtitle: '-Sides and Rarities',
          userReview: '@mention',
          retailer: '+SUM(A1:A9)',
          genres: [],
          dateAdded: 1700400000,
          dateScanned: 1700400000,
          updatedAt: 1700400000,
        ),
      ];

      when(() => mockRepo.watchAll(
            mediaType: any(named: 'mediaType'),
            searchQuery: any(named: 'searchQuery'),
            tagIds: any(named: 'tagIds'),
            sortBy: any(named: 'sortBy'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) => Stream.value(maliciousItems));

      final content = await useCase.generateContent(ExportFormat.csv);
      final lines = content.split('\n');

      // Formula-leading cells are prefixed with a single quote so
      // spreadsheet applications treat them as text.
      expect(lines[1], contains('"\'=HYPERLINK(""http://evil.example"")"'));
      expect(lines[1], contains("'-Sides and Rarities"));
      expect(lines[1], contains("'@mention"));
      expect(lines[1], contains("'+SUM(A1:A9)"));
      expect(lines[1], isNot(contains(',=')));
      expect(lines[1], isNot(contains(',-Sides')));
    });

    test('CSV export includes purchase info fields in header and rows',
        () async {
      final itemWithPurchase = [
        const MediaItem(
          id: 'id-purchase',
          barcode: '1111111111111',
          barcodeType: 'EAN-13',
          mediaType: MediaType.music,
          title: 'Test Album',
          genres: [],
          condition: ItemCondition.nearMint,
          pricePaid: 24.99,
          retailer: 'Local Record Shop',
          acquiredAt: 1701000000,
          dateAdded: 1700000000,
          dateScanned: 1700000000,
          updatedAt: 1700000000,
        ),
      ];

      when(() => mockRepo.watchAll(
            mediaType: any(named: 'mediaType'),
            searchQuery: any(named: 'searchQuery'),
            tagIds: any(named: 'tagIds'),
            sortBy: any(named: 'sortBy'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) => Stream.value(itemWithPurchase));

      final content = await useCase.generateContent(ExportFormat.csv);
      final lines = content.split('\n');

      expect(lines[0], contains('condition'));
      expect(lines[0], contains('pricePaid'));
      expect(lines[0], contains('retailer'));
      expect(lines[0], contains('acquiredAt'));

      expect(lines[1], contains('nearMint'));
      expect(lines[1], contains('24.99'));
      expect(lines[1], contains('Local Record Shop'));
      expect(lines[1], contains('1701000000'));
    });

    test('JSON export includes purchase info fields', () async {
      final itemWithPurchase = [
        const MediaItem(
          id: 'id-purchase',
          barcode: '1111111111111',
          barcodeType: 'EAN-13',
          mediaType: MediaType.music,
          title: 'Test Album',
          genres: [],
          condition: ItemCondition.good,
          pricePaid: 12.50,
          retailer: 'Discogs',
          acquiredAt: 1701000000,
          dateAdded: 1700000000,
          dateScanned: 1700000000,
          updatedAt: 1700000000,
        ),
      ];

      when(() => mockRepo.watchAll(
            mediaType: any(named: 'mediaType'),
            searchQuery: any(named: 'searchQuery'),
            tagIds: any(named: 'tagIds'),
            sortBy: any(named: 'sortBy'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) => Stream.value(itemWithPurchase));

      final content = await useCase.generateContent(ExportFormat.json);
      final decoded = jsonDecode(content) as List<dynamic>;
      final first = decoded.first as Map<String, dynamic>;

      expect(first['condition'], equals('good'));
      expect(first['pricePaid'], equals(12.50));
      expect(first['retailer'], equals('Discogs'));
      expect(first['acquiredAt'], equals(1701000000));
    });

    test('JSON export serialises null purchase fields as null', () async {
      // testItems intentionally do not set purchase fields.
      final content = await useCase.generateContent(ExportFormat.json);
      final decoded = jsonDecode(content) as List<dynamic>;
      final first = decoded.first as Map<String, dynamic>;

      expect(first.containsKey('condition'), isTrue);
      expect(first.containsKey('pricePaid'), isTrue);
      expect(first.containsKey('retailer'), isTrue);
      expect(first.containsKey('acquiredAt'), isTrue);
      expect(first['condition'], isNull);
      expect(first['pricePaid'], isNull);
      expect(first['retailer'], isNull);
      expect(first['acquiredAt'], isNull);
    });

    test('excludes deleted items from export', () async {
      final itemsWithDeleted = [
        ...testItems,
        const MediaItem(
          id: 'id-deleted',
          barcode: '0000000000',
          barcodeType: 'EAN-13',
          mediaType: MediaType.unknown,
          title: 'Deleted Item',
          genres: [],
          dateAdded: 1700300000,
          dateScanned: 1700300000,
          updatedAt: 1700300000,
          deleted: true,
        ),
      ];

      when(() => mockRepo.watchAll(
            mediaType: any(named: 'mediaType'),
            searchQuery: any(named: 'searchQuery'),
            tagIds: any(named: 'tagIds'),
            sortBy: any(named: 'sortBy'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) => Stream.value(itemsWithDeleted));

      final csvContent = await useCase.generateContent(ExportFormat.csv);
      expect(csvContent.split('\n').length, equals(3)); // header + 2 active

      final jsonContent = await useCase.generateContent(ExportFormat.json);
      final decoded = jsonDecode(jsonContent) as List;
      expect(decoded.length, equals(2));
    });
  });
}
