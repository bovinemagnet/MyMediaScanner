/// User-selectable conflict resolution policy for TMDB account sync.
enum TmdbConflictPolicy {
  preferLatestTimestamp,
  preferLocal,
  preferTmdb,
  askUser;

  static TmdbConflictPolicy fromName(String? name) {
    return TmdbConflictPolicy.values.firstWhere(
      (p) => p.name == name,
      orElse: () => TmdbConflictPolicy.preferLatestTimestamp,
    );
  }
}
