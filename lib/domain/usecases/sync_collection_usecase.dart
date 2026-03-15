import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';

class SyncCollectionUseCase {
  const SyncCollectionUseCase({required ISyncRepository repository})
      : _repo = repository;

  final ISyncRepository _repo;

  Future<void> execute() async {
    await _repo.pushChanges();
    await _repo.pullChanges();
  }

  Future<bool> testConnection() => _repo.testConnection();

  Future<void> fullReset() => _repo.resetLocalDatabase();
}
