import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';

class SyncCollectionUseCase {
  const SyncCollectionUseCase({required ISyncRepository repository})
      : _repo = repository;

  final ISyncRepository _repo;

  Future<void> execute() async {
    // Pull first so concurrent remote edits surface as conflicts before
    // any pending local edit can overwrite them on the server; the push
    // then holds back entities whose conflicts are still unresolved.
    await _repo.pullChanges();
    await _repo.pushChanges();
  }

  Future<bool> testConnection() => _repo.testConnection();

  Future<void> fullReset() => _repo.resetLocalDatabase();
}
