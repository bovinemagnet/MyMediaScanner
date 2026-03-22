// Author: Paul Snow

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/manage_rips_usecase.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  late ManageRipsUseCase useCase;
  late MockRipLibraryRepository mockRepo;

  setUp(() {
    mockRepo = MockRipLibraryRepository();
    useCase = ManageRipsUseCase(repository: mockRepo);
  });

  group('linkToMediaItem', () {
    test(
        'linkToMediaItem_withValidIds_delegatesToRepositoryWithCorrectArguments',
        () async {
      when(() => mockRepo.linkToMediaItem('rip-abc', 'item-xyz'))
          .thenAnswer((_) async {});

      await useCase.linkToMediaItem('rip-abc', 'item-xyz');

      verify(() => mockRepo.linkToMediaItem('rip-abc', 'item-xyz')).called(1);
    });

    test(
        'linkToMediaItem_whenRepositoryThrows_propagatesException',
        () async {
      when(() => mockRepo.linkToMediaItem(any(), any()))
          .thenThrow(Exception('Database error'));

      expect(
        () => useCase.linkToMediaItem('rip-abc', 'item-xyz'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('unlinkFromMediaItem', () {
    test(
        'unlinkFromMediaItem_withValidId_delegatesToRepositoryWithCorrectArgument',
        () async {
      when(() => mockRepo.unlinkFromMediaItem('rip-abc'))
          .thenAnswer((_) async {});

      await useCase.unlinkFromMediaItem('rip-abc');

      verify(() => mockRepo.unlinkFromMediaItem('rip-abc')).called(1);
    });
  });
}
