import 'package:mymediascanner/domain/entities/sync_conflict.dart';

/// Record-level last-write-wins merging with per-field conflict
/// DETECTION for close-in-time edits.
///
/// Note the asymmetry: conflicts are detected and resolved per field
/// (see [detectConflicts] / [mergeWithResolutions]), but the automatic
/// merge itself ([mergeFields]) is record-level — whichever side has the
/// newer `updated_at` contributes ALL of its fields. There are no
/// per-field timestamps in the schema.
abstract final class SyncStrategy {
  /// Default threshold in milliseconds within which concurrent edits
  /// are flagged as conflicts (60 seconds).
  static const int defaultConflictThresholdMs = 60000;

  /// Fields that are internal bookkeeping and should never surface as
  /// user-visible conflicts.
  static const _metaFields = {
    'id',
    'updated_at',
    'synced_at',
    'created_at',
    'date_added',
    'date_scanned',
    'deleted',
  };

  /// Merge local and remote records using record-level last-write-wins:
  /// the record with the newer `updated_at` wins as a whole and every
  /// field it carries is taken from it. On tie, local wins. Fields
  /// present on only one side are preserved regardless of which side
  /// wins.
  ///
  /// This is NOT a per-field merge — when the records were edited far
  /// enough apart that [detectConflicts] surfaces nothing, the older
  /// side's edits are discarded wholesale. Concurrent edits within the
  /// conflict threshold are routed through the user-facing conflict UI
  /// instead of reaching this silent path.
  static Map<String, dynamic> mergeFields(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final localUpdatedAt = local['updated_at'] as int? ?? 0;
    final remoteUpdatedAt = remote['updated_at'] as int? ?? 0;

    if (remoteUpdatedAt > localUpdatedAt) {
      // Remote is newer — use remote values, preserving local-only fields
      return {...local, ...remote};
    }
    // Local is newer or equal — local wins
    return {...remote, ...local};
  }

  /// Detect per-field conflicts between local and remote records.
  ///
  /// A conflict is surfaced when:
  ///   1. The field value differs between local and remote.
  ///   2. Both records have been modified within [thresholdMs] of each
  ///      other (i.e. genuinely concurrent edits).
  ///
  /// Outside the threshold window, record-level last-write-wins applies
  /// silently (the older record's edits are discarded wholesale by
  /// [mergeFields]) and no conflicts are returned.
  static List<SyncConflict> detectConflicts(
    Map<String, dynamic> local,
    Map<String, dynamic> remote, {
    required String entityType,
    required String entityId,
    int thresholdMs = defaultConflictThresholdMs,
  }) {
    final localUpdatedAt = local['updated_at'] as int? ?? 0;
    final remoteUpdatedAt = remote['updated_at'] as int? ?? 0;

    // If timestamps are far apart, no conflicts — LWW handles it.
    if ((localUpdatedAt - remoteUpdatedAt).abs() > thresholdMs) {
      return const [];
    }

    final conflicts = <SyncConflict>[];
    final allKeys = {...local.keys, ...remote.keys};

    for (final key in allKeys) {
      if (_metaFields.contains(key)) continue;

      final localVal = local[key];
      final remoteVal = remote[key];

      // Skip fields present in only one side (no conflict).
      if (!local.containsKey(key) || !remote.containsKey(key)) continue;

      if (localVal != remoteVal) {
        conflicts.add(SyncConflict(
          entityType: entityType,
          entityId: entityId,
          fieldName: key,
          localValue: localVal,
          remoteValue: remoteVal,
          localUpdatedAt: localUpdatedAt,
          remoteUpdatedAt: remoteUpdatedAt,
        ));
      }
    }

    return conflicts;
  }

  /// Merge two records applying the user's conflict resolutions.
  ///
  /// Starts with a standard [mergeFields] result, then overrides each
  /// conflicted field according to the chosen [ConflictResolution].
  static Map<String, dynamic> mergeWithResolutions(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
    List<SyncConflict> resolutions,
  ) {
    final merged = mergeFields(local, remote);

    for (final conflict in resolutions) {
      switch (conflict.resolution) {
        case ConflictResolution.keepLocal:
          merged[conflict.fieldName] = conflict.localValue;
        case ConflictResolution.keepRemote:
          merged[conflict.fieldName] = conflict.remoteValue;
        case ConflictResolution.keepBoth:
          // For keepBoth, concatenate string values or prefer local.
          final localVal = conflict.localValue;
          final remoteVal = conflict.remoteValue;
          if (localVal is String && remoteVal is String) {
            merged[conflict.fieldName] = '$localVal | $remoteVal';
          } else {
            merged[conflict.fieldName] = localVal;
          }
      }
    }

    return merged;
  }
}
