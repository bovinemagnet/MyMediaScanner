import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchSyncStatus();
});
