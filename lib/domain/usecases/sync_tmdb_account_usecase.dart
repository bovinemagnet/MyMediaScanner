import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class SyncTmdbAccountUseCase {
  SyncTmdbAccountUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbSyncSummary> call() => repo.syncNow();
}
