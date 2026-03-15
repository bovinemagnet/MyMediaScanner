/// Last-write-wins per-field conflict resolution.
abstract final class SyncStrategy {
  /// Merge local and remote records field-by-field.
  /// The record with the newer `updated_at` wins per field.
  /// On tie, local wins.
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
}
