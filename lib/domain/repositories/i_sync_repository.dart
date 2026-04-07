import 'package:mymediascanner/domain/entities/sync_conflict.dart';

abstract interface class ISyncRepository {
  Future<void> pushChanges();
  Future<void> pullChanges();
  Future<bool> testConnection();
  Future<void> resetLocalDatabase();
  Stream<SyncStatus> watchSyncStatus();

  /// Stream of per-record progress during push/pull operations.
  Stream<SyncProgress> watchSyncProgress();

  /// Returns any pending conflicts detected during the last pull.
  Future<List<SyncConflict>> getConflicts();

  /// Resolve pending conflicts with user-chosen resolutions.
  Future<void> resolveConflicts(List<SyncConflict> resolutions);

  /// Get paginated sync history from the log.
  Future<List<SyncLogEntry>> getSyncHistory({int limit = 50, int offset = 0});

  /// Purge sync log entries older than the given epoch timestamp.
  Future<void> purgeSyncHistory(int olderThanEpochMs);
}

class SyncStatus {
  const SyncStatus({
    required this.pendingCount,
    this.lastSyncedAt,
    this.isSyncing = false,
    this.error,
    this.conflictCount = 0,
  });

  final int pendingCount;
  final int? lastSyncedAt;
  final bool isSyncing;
  final String? error;
  final int conflictCount;
}

/// Progress reporting for individual sync operations.
class SyncProgress {
  const SyncProgress({
    required this.phase,
    required this.current,
    required this.total,
    this.currentEntityType,
  });

  static const idle = SyncProgress(
    phase: SyncPhase.idle,
    current: 0,
    total: 0,
  );

  final SyncPhase phase;
  final int current;
  final int total;
  final String? currentEntityType;

  double get fraction => total > 0 ? current / total : 0.0;
}

enum SyncPhase { idle, push, pull }

/// A lightweight representation of a sync log entry for the UI layer.
class SyncLogEntry {
  const SyncLogEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    this.attemptedAt,
    required this.synced,
    this.errorMessage,
    this.durationMs,
    this.direction,
    this.resolvedBy,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final int createdAt;
  final int? attemptedAt;
  final bool synced;
  final String? errorMessage;
  final int? durationMs;
  final String? direction;
  final String? resolvedBy;
}
