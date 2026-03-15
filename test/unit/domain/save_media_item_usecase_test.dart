import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late SaveMediaItemUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MediaItem(
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
    mockRepo = MockMediaItemRepository();
    useCase = SaveMediaItemUseCase(repository: mockRepo);
  });

  group('SaveMediaItemUseCase', () {
    test('creates MediaItem from MetadataResult and saves', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final metadata = MetadataResult(
        barcode: '9780141036144',
        barcodeType: 'isbn13',
        title: '1984',
        mediaType: MediaType.book,
        year: 1949,
      );

      final saved = await useCase.execute(metadata);

      expect(saved.title, '1984');
      expect(saved.barcode, '9780141036144');
      expect(saved.mediaType, MediaType.book);
      expect(saved.id, isNotEmpty);
      verify(() => mockRepo.save(any())).called(1);
    });
  });
}
