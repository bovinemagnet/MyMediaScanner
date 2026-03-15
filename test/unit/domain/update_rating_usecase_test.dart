import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late UpdateRatingUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MediaItem(
      id: '', barcode: '', barcodeType: '', mediaType: MediaType.unknown,
      title: '', dateAdded: 0, dateScanned: 0, updatedAt: 0,
    ));
  });

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = UpdateRatingUseCase(repository: mockRepo);
  });

  test('updates item rating and review', () async {
    final item = MediaItem(
      id: 'item-1', barcode: '123', barcodeType: 'ean13',
      mediaType: MediaType.film, title: 'Test',
      dateAdded: 1000, dateScanned: 1000, updatedAt: 1000,
    );

    when(() => mockRepo.getById('item-1')).thenAnswer((_) async => item);
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    await useCase.execute('item-1', rating: 4.5, review: 'Great film');

    final captured = verify(() => mockRepo.update(captureAny())).captured;
    final updated = captured.first as MediaItem;
    expect(updated.userRating, 4.5);
    expect(updated.userReview, 'Great film');
  });
}
