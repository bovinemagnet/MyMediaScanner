import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late DeleteMediaItemUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = DeleteMediaItemUseCase(repository: mockRepo);
  });

  test('soft deletes item by id', () async {
    when(() => mockRepo.softDelete('item-1')).thenAnswer((_) async {});

    await useCase.execute('item-1');

    verify(() => mockRepo.softDelete('item-1')).called(1);
  });
}
