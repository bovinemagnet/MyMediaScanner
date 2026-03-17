import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/upc_mapper.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('UpcMapper', () {
    test('maps item with correct basic fields', () {
      const dto = UpcItemDto(
        ean: '0123456789012',
        title: 'Some Product',
        description: 'A test product',
        brand: 'TestBrand',
        category: 'Electronics',
        images: ['https://example.com/img.jpg'],
      );

      final result = UpcMapper.fromItem(dto, '0123456789012', 'ean13');

      expect(result.title, 'Some Product');
      expect(result.description, 'A test product');
      expect(result.publisher, 'TestBrand');
      expect(result.coverUrl, 'https://example.com/img.jpg');
      expect(result.sourceApis, ['upcitemdb']);
    });

    test('"book" category maps to MediaType.book', () {
      const dto = UpcItemDto(
        title: 'A Great Book',
        category: 'Books & Magazines',
      );

      final result = UpcMapper.fromItem(dto, '1111', 'isbn13');
      expect(result.mediaType, MediaType.book);
    });

    test('"music" category maps to MediaType.music', () {
      const dto = UpcItemDto(
        title: 'A CD',
        category: 'Music CDs',
      );

      final result = UpcMapper.fromItem(dto, '2222', 'ean13');
      expect(result.mediaType, MediaType.music);
    });

    test('"cd" category maps to MediaType.music', () {
      const dto = UpcItemDto(
        title: 'Another CD',
        category: 'CD & Vinyl',
      );

      final result = UpcMapper.fromItem(dto, '3333', 'ean13');
      expect(result.mediaType, MediaType.music);
    });

    test('"vinyl" category maps to MediaType.music', () {
      const dto = UpcItemDto(
        title: 'A Vinyl Record',
        category: 'Vinyl Records',
      );

      final result = UpcMapper.fromItem(dto, '4444', 'ean13');
      expect(result.mediaType, MediaType.music);
    });

    test('"movie" category maps to MediaType.film', () {
      const dto = UpcItemDto(
        title: 'A Movie',
        category: 'Movies & TV',
      );

      final result = UpcMapper.fromItem(dto, '5555', 'upc_a');
      expect(result.mediaType, MediaType.film);
    });

    test('"dvd" category maps to MediaType.film', () {
      const dto = UpcItemDto(
        title: 'A DVD',
        category: 'DVD',
      );

      final result = UpcMapper.fromItem(dto, '6666', 'upc_a');
      expect(result.mediaType, MediaType.film);
    });

    test('"blu-ray" category maps to MediaType.film', () {
      const dto = UpcItemDto(
        title: 'A Blu-ray',
        category: 'Blu-ray Discs',
      );

      final result = UpcMapper.fromItem(dto, '7777', 'ean13');
      expect(result.mediaType, MediaType.film);
    });

    test('"game" category maps to MediaType.game', () {
      const dto = UpcItemDto(
        title: 'A Game',
        category: 'Console Game Software',
      );

      final result = UpcMapper.fromItem(dto, '8888', 'ean13');
      expect(result.mediaType, MediaType.game);
    });

    test('unknown category maps to MediaType.unknown', () {
      const dto = UpcItemDto(
        title: 'Mystery Product',
        category: 'Household Appliances',
      );

      final result = UpcMapper.fromItem(dto, '9999', 'ean13');
      expect(result.mediaType, MediaType.unknown);
    });

    test('null category maps to MediaType.unknown', () {
      const dto = UpcItemDto(
        title: 'No Category',
      );

      final result = UpcMapper.fromItem(dto, '0000', 'ean13');
      expect(result.mediaType, MediaType.unknown);
    });
  });

  group('UpcMapper.toCandidate', () {
    test('maps item to MetadataCandidate', () {
      const dto = UpcItemDto(
        ean: '0123456789012',
        title: 'Some Product',
        category: 'Music > CDs',
        images: ['https://example.com/img.jpg'],
      );

      final candidate = UpcMapper.toCandidate(dto, '0123456789012');

      expect(candidate.sourceApi, 'upcitemdb');
      expect(candidate.sourceId, '0123456789012');
      expect(candidate.title, 'Some Product');
      expect(candidate.coverUrl, 'https://example.com/img.jpg');
      expect(candidate.mediaType, MediaType.music);
    });

    test('uses barcode as sourceId when ean is null', () {
      const dto = UpcItemDto(title: 'Item');
      final candidate = UpcMapper.toCandidate(dto, '999');
      expect(candidate.sourceId, '999');
    });
  });
}
