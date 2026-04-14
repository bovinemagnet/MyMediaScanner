enum OwnershipStatus {
  owned,
  wishlist;

  /// Canonical string form used for persistence and sync. Centralising this
  /// here prevents callers from drifting away from `enum.name` and silently
  /// storing values that no longer round-trip.
  String get dbValue => name;

  /// Returns the enum value matching [value], or `null` if [value] is null
  /// or does not match any known variant. Callers must choose an explicit
  /// fallback to avoid silently coercing unknowns (e.g. a future client's
  /// new value or a typo) into [OwnershipStatus.owned].
  static OwnershipStatus? fromString(String? value) {
    if (value == null) return null;
    for (final v in OwnershipStatus.values) {
      if (v.name == value) return v;
    }
    return null;
  }
}
