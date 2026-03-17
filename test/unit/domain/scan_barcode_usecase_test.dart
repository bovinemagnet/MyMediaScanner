import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}
class MockMetadataRepository extends Mock implements IMetadataRepository {}

void main() {
  group('ScanResult sealed class', () {
    test('ScanResult.single holds metadata and duplicate flag', () {
      const result = ScanResult.single(
        metadata: MetadataResult(
          barcode: '123',
          barcodeType: 'ean13',
          title: 'Test',
        ),
        isDuplicate: false,
      );

      expect(result, isA<SingleScanResult>());
      const single = result as SingleScanResult;
      expect(single.metadata.title, 'Test');
      expect(single.isDuplicate, isFalse);
    });

    test('ScanResult.multiMatch holds candidates', () {
      const result = ScanResult.multiMatch(
        candidates: [
          MetadataCandidate(
            sourceApi: 'discogs',
            sourceId: '1',
            title: 'Album A',
          ),
          MetadataCandidate(
            sourceApi: 'discogs',
            sourceId: '2',
            title: 'Album B',
          ),
        ],
        barcode: '123',
        barcodeType: 'ean13',
      );

      expect(result, isA<MultiMatchScanResult>());
      const multi = result as MultiMatchScanResult;
      expect(multi.candidates.length, 2);
      expect(multi.barcode, '123');
    });

    test('ScanResult.notFound holds barcode info', () {
      const result = ScanResult.notFound(
        barcode: '123',
        barcodeType: 'ean13',
      );

      expect(result, isA<NotFoundScanResult>());
      const notFound = result as NotFoundScanResult;
      expect(notFound.barcode, '123');
    });
  });

  group('ScanBarcodeUseCase', () {
    late ScanBarcodeUseCase useCase;
    late MockMediaItemRepository mockMediaItemRepo;
    late MockMetadataRepository mockMetadataRepo;

    setUp(() {
      mockMediaItemRepo = MockMediaItemRepository();
      mockMetadataRepo = MockMetadataRepository();
      useCase = ScanBarcodeUseCase(
        mediaItemRepository: mockMediaItemRepo,
        metadataRepository: mockMetadataRepo,
      );
    });

    test('returns single result for new barcode with metadata', () async {
      const barcode = '9780141036144';
      const lookupResult = ScanResult.single(
        metadata: MetadataResult(
          barcode: barcode,
          barcodeType: 'isbn13',
          title: '1984',
          mediaType: MediaType.book,
        ),
        isDuplicate: false,
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => false);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => lookupResult);

      final result = await useCase.execute(barcode);

      expect(result, isA<SingleScanResult>());
      final single = result as SingleScanResult;
      expect(single.metadata.title, '1984');
      expect(single.isDuplicate, isFalse);
    });

    test('sets isDuplicate true when barcode already exists', () async {
      const barcode = '9780141036144';
      const lookupResult = ScanResult.single(
        metadata: MetadataResult(
          barcode: barcode,
          barcodeType: 'isbn13',
          title: '1984',
        ),
        isDuplicate: false,
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => true);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => lookupResult);

      final result = await useCase.execute(barcode);

      expect(result, isA<SingleScanResult>());
      expect((result as SingleScanResult).isDuplicate, isTrue);
    });

    test('passes through multiMatch result from repository', () async {
      const barcode = '5099902894225';
      const lookupResult = ScanResult.multiMatch(
        candidates: [
          MetadataCandidate(
            sourceApi: 'discogs',
            sourceId: '1',
            title: 'Album A',
          ),
        ],
        barcode: barcode,
        barcodeType: 'ean13',
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => false);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => lookupResult);

      final result = await useCase.execute(barcode);

      expect(result, isA<MultiMatchScanResult>());
    });

    test('passes through notFound result from repository', () async {
      const barcode = '0000000000000';
      const lookupResult = ScanResult.notFound(
        barcode: barcode,
        barcodeType: 'ean13',
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => false);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => lookupResult);

      final result = await useCase.execute(barcode);

      expect(result, isA<NotFoundScanResult>());
    });
  });
}
