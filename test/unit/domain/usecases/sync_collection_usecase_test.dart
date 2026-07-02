import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/sync_collection_usecase.dart';

class _MockSyncRepository extends Mock implements ISyncRepository {}

void main() {
  test('execute pulls before pushing so conflicts surface first', () async {
    final repo = _MockSyncRepository();
    when(repo.pullChanges).thenAnswer((_) async {});
    when(repo.pushChanges).thenAnswer((_) async {});

    await SyncCollectionUseCase(repository: repo).execute();

    verifyInOrder([repo.pullChanges, repo.pushChanges]);
  });
}
