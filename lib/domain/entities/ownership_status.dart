enum OwnershipStatus {
  owned,
  wishlist;

  static OwnershipStatus fromString(String value) =>
      OwnershipStatus.values.firstWhere(
        (v) => v.name == value,
        orElse: () => OwnershipStatus.owned,
      );
}
