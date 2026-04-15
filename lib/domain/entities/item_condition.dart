enum ItemCondition {
  mint,
  nearMint,
  good,
  fair,
  poor;

  static ItemCondition? fromString(String? value) {
    if (value == null) return null;
    for (final c in ItemCondition.values) {
      if (c.name == value) return c;
    }
    return null;
  }

  String get label => switch (this) {
        mint => 'Mint',
        nearMint => 'Near Mint',
        good => 'Good',
        fair => 'Fair',
        poor => 'Poor',
      };
}
