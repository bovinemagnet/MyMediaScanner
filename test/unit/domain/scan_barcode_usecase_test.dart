import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}
class MockMetadataRepository extends Mock implements IMetadataRepository {}

void main() {
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

  group('ScanBarcodeUseCase', () {
    test('returns metadata result for new barcode', () async {
      const barcode = '9780141036144';
      const expected = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: '1984',
        mediaType: MediaType.book,
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => false);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => expected);

      final result = await useCase.execute(barcode);

      expect(result.metadataResult.title, '1984');
      expect(result.isDuplicate, isFalse);
    });

    test('flags duplicate barcode', () async {
      const barcode = '9780141036144';

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => true);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => const MetadataResult(
                barcode: barcode,
                barcodeType: 'isbn13',
              ));

      final result = await useCase.execute(barcode);

      expect(result.isDuplicate, isTrue);
    });
  });
}
