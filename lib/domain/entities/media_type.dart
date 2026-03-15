/// Media type classification.
enum MediaType {
  film('Film'),
  tv('TV'),
  music('Music'),
  book('Book'),
  game('Game'),
  unknown('Unknown');

  const MediaType(this.label);

  final String label;

  /// Parse from string, defaulting to unknown.
  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => MediaType.unknown,
    );
  }
}
