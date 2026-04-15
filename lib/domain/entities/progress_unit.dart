/// Unit of progress tracking, chosen per-media-type at start time.
enum ProgressUnit {
  page,
  chapter,
  episode,
  minute;

  String get dbValue => name;

  String get label => switch (this) {
        ProgressUnit.page => 'Page',
        ProgressUnit.chapter => 'Chapter',
        ProgressUnit.episode => 'Episode',
        ProgressUnit.minute => 'Minute',
      };

  static ProgressUnit? fromString(String? value) {
    if (value == null) return null;
    for (final v in ProgressUnit.values) {
      if (v.name == value) return v;
    }
    return null;
  }
}
