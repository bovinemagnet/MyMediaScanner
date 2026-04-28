import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ConvertBridgeToLocalItemUseCase {
  ConvertBridgeToLocalItemUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<String> call(String bridgeId) =>
      repo.convertBridgeToLocalItem(bridgeId);
}
