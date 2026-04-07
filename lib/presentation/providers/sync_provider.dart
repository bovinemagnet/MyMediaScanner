import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/sync_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

// ── Sync status stream ──────────────────────────────────────────────

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchSyncStatus();
});

// ── Sync progress stream ────────────────────────────────────────────

final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  if (repo == null) return Stream.value(SyncProgress.idle);
  return repo.watchSyncProgress();
});

// ── Pending conflicts ───────────────────────────────────────────────

final syncConflictsProvider =
    AsyncNotifierProvider<SyncConflictsNotifier, List<SyncConflict>>(
  SyncConflictsNotifier.new,
);

class SyncConflictsNotifier extends AsyncNotifier<List<SyncConflict>> {
  @override
  Future<List<SyncConflict>> build() async {
    final repo = ref.watch(syncRepositoryProvider);
    if (repo == null) return const [];
    return repo.getConflicts();
  }

  Future<void> resolveConflicts(List<SyncConflict> resolutions) async {
    final repo = ref.read(syncRepositoryProvider);
    if (repo == null) return;
    await repo.resolveConflicts(resolutions);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ── Sync history (paginated) ────────────────────────────────────────

final syncHistoryProvider =
    FutureProvider.family<List<SyncLogEntry>, int>((ref, page) async {
  final repo = ref.watch(syncRepositoryProvider);
  if (repo == null) return const [];
  return repo.getSyncHistory(limit: 50, offset: page * 50);
});

// ── Manual sync trigger ─────────────────────────────────────────────

/// Summary of a completed sync operation.
class SyncSummary {
  const SyncSummary({
    this.pushed = 0,
    this.pulled = 0,
    this.conflicts = 0,
    this.error,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final String? error;

  bool get hasError => error != null;
}

final syncTriggerProvider =
    AsyncNotifierProvider<SyncTriggerNotifier, SyncSummary?>(
  SyncTriggerNotifier.new,
);

class SyncTriggerNotifier extends AsyncNotifier<SyncSummary?> {
  @override
  Future<SyncSummary?> build() async => null;

  Future<SyncSummary> triggerSync() async {
    final repo = ref.read(syncRepositoryProvider);
    if (repo == null) {
      const summary = SyncSummary(error: 'Sync not configured');
      state = const AsyncData(summary);
      return summary;
    }

    state = const AsyncLoading();

    try {
      final useCase = SyncCollectionUseCase(repository: repo);
      await useCase.execute();

      final conflicts = await repo.getConflicts();
      final summary = SyncSummary(
        conflicts: conflicts.length,
      );
      state = AsyncData(summary);

      // Refresh conflicts provider
      ref.invalidate(syncConflictsProvider);

      return summary;
    } on Exception catch (e, st) {
      final summary = SyncSummary(error: e.toString());
      state = AsyncError(e, st);
      return summary;
    }
  }
}
