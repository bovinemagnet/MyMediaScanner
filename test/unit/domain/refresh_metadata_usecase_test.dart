import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/refresh_metadata_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

class MockMetadataRepository extends Mock implements IMetadataRepository {}

void main() {
  late RefreshMetadataUseCase useCase;
  late MockMediaItemRepository mockMediaItemRepo;
  late MockMetadataRepository mockMetadataRepo;

  setUpAll(() {
    registerFallbackValue(const MediaItem(
      id: '',
      barcode: '',
      barcodeType: '',
      mediaType: MediaType.unknown,
      title: '',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  setUp(() {
    mockMediaItemRepo = MockMediaItemRepository();
    mockMetadataRepo = MockMetadataRepository();
    useCase = RefreshMetadataUseCase(
      metadataRepository: mockMetadataRepo,
      mediaItemRepository: mockMediaItemRepo,
    );
  });

  group('RefreshMetadataUseCase', () {
    const barcode = '9780141036144';
    const existingItem = MediaItem(
      id: 'item-1',
      barcode: barcode,
      barcodeType: 'isbn13',
      mediaType: MediaType.book,
      title: 'Old Title',
      subtitle: 'Old Subtitle',
      description: 'Old description',
      coverUrl: 'https://example.com/old.jpg',
      userRating: 4.5,
      userReview: 'Great book!',
      dateAdded: 1000,
      dateScanned: 1000,
      updatedAt: 1000,
    );

    test('calls lookupBarcode with the item barcode and media type', () async {
      const metadata = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: 'New Title',
        mediaType: MediaType.book,
      );

      when(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
              const ScanResult.single(metadata: metadata, isDuplicate: false));
      when(() => mockMediaItemRepo.update(any()))
          .thenAnswer((_) async => {});

      await useCase.execute(existingItem);

      verify(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).called(1);
    });

    test('preserves userRating and userReview from original item', () async {
      const metadata = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: 'New Title',
        description: 'New description',
        coverUrl: 'https://example.com/new.jpg',
        mediaType: MediaType.book,
      );

      when(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
              const ScanResult.single(metadata: metadata, isDuplicate: false));
      when(() => mockMediaItemRepo.update(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(existingItem);

      expect(result.userRating, 4.5);
      expect(result.userReview, 'Great book!');
      expect(result.dateAdded, 1000);
    });

    test('updates title, description, and coverUrl from new metadata',
        () async {
      const metadata = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: 'Updated Title',
        description: 'Updated description',
        coverUrl: 'https://example.com/updated.jpg',
        mediaType: MediaType.book,
      );

      when(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
              const ScanResult.single(metadata: metadata, isDuplicate: false));
      when(() => mockMediaItemRepo.update(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(existingItem);

      expect(result.title, 'Updated Title');
      expect(result.description, 'Updated description');
      expect(result.coverUrl, 'https://example.com/updated.jpg');
      expect(result.updatedAt, greaterThan(1000));
    });

    test('keeps original values when metadata fields are null', () async {
      const metadata = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
      );

      when(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
              const ScanResult.single(metadata: metadata, isDuplicate: false));
      when(() => mockMediaItemRepo.update(any()))
          .thenAnswer((_) async => {});

      final result = await useCase.execute(existingItem);

      expect(result.title, 'Old Title');
      expect(result.subtitle, 'Old Subtitle');
      expect(result.description, 'Old description');
      expect(result.coverUrl, 'https://example.com/old.jpg');
    });

    test('calls update on the media item repository', () async {
      const metadata = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: 'New Title',
      );

      when(() => mockMetadataRepo.lookupBarcode(
            barcode,
            typeHint: MediaType.book,
          )).thenAnswer((_) async =>
              const ScanResult.single(metadata: metadata, isDuplicate: false));
      when(() => mockMediaItemRepo.update(any()))
          .thenAnswer((_) async => {});

      await useCase.execute(existingItem);

      verify(() => mockMediaItemRepo.update(any())).called(1);
    });
  });
}
