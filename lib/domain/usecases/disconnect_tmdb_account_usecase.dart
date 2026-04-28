import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class DisconnectTmdbAccountUseCase {
  DisconnectTmdbAccountUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<void> call() => repo.disconnect();
}
