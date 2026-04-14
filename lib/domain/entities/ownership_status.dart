enum OwnershipStatus {
  owned,
  wishlist;

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
