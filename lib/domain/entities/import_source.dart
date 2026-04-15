/// External collection export formats supported by the import pipeline.
enum ImportSource {
  goodreads,
  discogs,
  letterboxd,
  trakt;

  String get displayName => switch (this) {
        ImportSource.goodreads => 'Goodreads',
        ImportSource.discogs => 'Discogs',
        ImportSource.letterboxd => 'Letterboxd',
        ImportSource.trakt => 'Trakt',
      };

  /// File extension used in the source's export format.
  String get fileExtension => switch (this) {
        ImportSource.goodreads => 'csv',
        ImportSource.discogs => 'csv',
        ImportSource.letterboxd => 'csv',
        ImportSource.trakt => 'json',
      };
}
