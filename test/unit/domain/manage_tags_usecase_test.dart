import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/domain/usecases/manage_tags_usecase.dart';

class MockTagRepository extends Mock implements ITagRepository {}

void main() {
  late ManageTagsUseCase useCase;
  late MockTagRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const Tag(id: '', name: '', updatedAt: 0));
  });

  setUp(() {
    mockRepo = MockTagRepository();
    useCase = ManageTagsUseCase(repository: mockRepo);
  });

  test('createTag generates id and saves', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    final tag = await useCase.createTag(name: 'Favourites', colour: '#FF0000');

    expect(tag.name, 'Favourites');
    expect(tag.colour, '#FF0000');
    expect(tag.id, isNotEmpty);
    verify(() => mockRepo.save(any())).called(1);
  });

  test('assignTag delegates to repository', () async {
    when(() => mockRepo.assignToMediaItem('tag-1', 'item-1'))
        .thenAnswer((_) async {});

    await useCase.assignTag(tagId: 'tag-1', mediaItemId: 'item-1');

    verify(() => mockRepo.assignToMediaItem('tag-1', 'item-1')).called(1);
  });
}
