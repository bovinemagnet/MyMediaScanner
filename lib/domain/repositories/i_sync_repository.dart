abstract interface class ISyncRepository {
  Future<void> pushChanges();
  Future<void> pullChanges();
  Future<bool> testConnection();
  Future<void> resetLocalDatabase();
  Stream<SyncStatus> watchSyncStatus();
}

class SyncStatus {
  const SyncStatus({
    required this.pendingCount,
    this.lastSyncedAt,
    this.isSyncing = false,
    this.error,
  });

  final int pendingCount;
  final int? lastSyncedAt;
  final bool isSyncing;
  final String? error;
}
