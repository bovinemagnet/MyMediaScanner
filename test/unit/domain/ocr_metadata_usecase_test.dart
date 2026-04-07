import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/ocr_metadata_usecase.dart';

class MockMetadataRepository extends Mock implements IMetadataRepository {}

void main() {
  late OcrMetadataUseCase useCase;
  late MockMetadataRepository mockRepo;

  setUp(() {
    mockRepo = MockMetadataRepository();
    useCase = OcrMetadataUseCase(metadataRepository: mockRepo);
  });

  const barcode = '0000000000000';
  const barcodeType = 'ean13';

  group('OcrMetadataUseCase', () {
    test('returns notFound for empty OCR result', () async {
      const ocrResult = OcrResult(blocks: []);

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<NotFoundScanResult>());
      expect(result.confidence, 0.0);
      expect(result.searchTermUsed, '');
      verifyNever(() => mockRepo.searchByTitle(
            any(),
            any(),
            any(),
            typeHint: any(named: 'typeHint'),
          ));
    });

    test('returns notFound for low confidence OCR', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(text: 'Fuzzy', confidence: 0.30, area: 5000.0),
        OcrTextBlock(text: 'Text', confidence: 0.20, area: 3000.0),
      ]);

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<NotFoundScanResult>());
      expect(result.confidence, lessThan(0.50));
      verifyNever(() => mockRepo.searchByTitle(
            any(),
            any(),
            any(),
            typeHint: any(named: 'typeHint'),
          ));
    });

    test('searches with high-confidence single block as title', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'The Matrix', confidence: 0.92, area: 15000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: any(named: 'typeHint'),
          )).thenAnswer((_) async => const ScanResult.single(
            metadata: MetadataResult(
              barcode: barcode,
              barcodeType: barcodeType,
              title: 'The Matrix',
              mediaType: MediaType.film,
            ),
            isDuplicate: false,
          ));

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<SingleScanResult>());
      expect(result.searchTermUsed, contains('The Matrix'));
      expect(result.confidence, closeTo(0.92, 0.01));
    });

    test('searches with primary and secondary blocks', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'Dark Side of the Moon',
            confidence: 0.90,
            area: 12000.0),
        OcrTextBlock(
            text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: any(named: 'typeHint'),
          )).thenAnswer((_) async => const ScanResult.single(
            metadata: MetadataResult(
              barcode: barcode,
              barcodeType: barcodeType,
              title: 'Dark Side of the Moon',
            ),
            isDuplicate: false,
          ));

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<SingleScanResult>());
      expect(result.searchTermUsed,
          contains('Dark Side of the Moon'));
      expect(result.inferredArtist, 'Pink Floyd');
    });

    test('strips noise words before searching', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'The Matrix Blu-ray',
            confidence: 0.90,
            area: 15000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            'The Matrix',
            barcode,
            barcodeType,
            typeHint: MediaType.film,
          )).thenAnswer((_) async => const ScanResult.single(
            metadata: MetadataResult(
              barcode: barcode,
              barcodeType: barcodeType,
              title: 'The Matrix',
            ),
            isDuplicate: false,
          ));

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<SingleScanResult>());
      verify(() => mockRepo.searchByTitle(
            'The Matrix',
            barcode,
            barcodeType,
            typeHint: MediaType.film,
          )).called(1);
    });

    test('extracts year from OCR text', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'The Wall 1979', confidence: 0.88, area: 12000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: any(named: 'typeHint'),
          )).thenAnswer((_) async => const ScanResult.notFound(
            barcode: barcode,
            barcodeType: barcodeType,
          ));

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.inferredYear, 1979);
    });

    test('uses typeHint parameter over inferred type', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'Something Blu-ray',
            confidence: 0.90,
            area: 15000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: MediaType.music,
          )).thenAnswer((_) async => const ScanResult.notFound(
            barcode: barcode,
            barcodeType: barcodeType,
          ));

      await useCase.execute(
        ocrResult,
        barcode,
        barcodeType,
        typeHint: MediaType.music,
      );

      verify(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: MediaType.music,
          )).called(1);
    });

    test('handles search exception gracefully', () async {
      const ocrResult = OcrResult(blocks: [
        OcrTextBlock(
            text: 'The Matrix', confidence: 0.92, area: 15000.0),
      ]);

      when(() => mockRepo.searchByTitle(
            any(),
            barcode,
            barcodeType,
            typeHint: any(named: 'typeHint'),
          )).thenThrow(Exception('Network error'));

      final result = await useCase.execute(ocrResult, barcode, barcodeType);

      expect(result.scanResult, isA<NotFoundScanResult>());
      expect(result.searchTermUsed, contains('The Matrix'));
    });
  });
}
