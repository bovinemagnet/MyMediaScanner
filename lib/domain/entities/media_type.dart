import 'package:mymediascanner/domain/entities/progress_unit.dart';

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

/// Per-media-type progress-tracking defaults.
extension MediaTypeProgress on MediaType {
  /// The progress unit pre-selected when the user starts tracking an item
  /// of this type.
  ProgressUnit get defaultProgressUnit => switch (this) {
        MediaType.book => ProgressUnit.page,
        MediaType.tv => ProgressUnit.episode,
        _ => ProgressUnit.minute,
      };

  /// Label for the action that begins progress tracking
  /// ('Start reading' for books, 'Start watching' otherwise).
  String get progressActionLabel =>
      this == MediaType.book ? 'Start reading' : 'Start watching';
}

/// A single extra-metadata display field for a media type: a label plus an
/// extractor that pulls (and formats) the value from an item's
/// `extraMetadata` map. Extractors return `null` when the field is absent.
class MetadataFieldDescriptor {
  const MetadataFieldDescriptor({required this.label, required this.extract});

  final String label;
  final String? Function(Map<String, dynamic> extra) extract;
}

String? _extractDirector(Map<String, dynamic> extra) =>
    extra['director'] as String?;

String? _extractRuntime(Map<String, dynamic> extra) =>
    extra['runtime_minutes'] != null ? '${extra['runtime_minutes']} min' : null;

String? _extractArtists(Map<String, dynamic> extra) =>
    (extra['artists'] as List?)?.join(', ');

String? _extractLabel(Map<String, dynamic> extra) => extra['label'] as String?;

String? _extractAuthors(Map<String, dynamic> extra) =>
    (extra['authors'] as List?)?.join(', ');

String? _extractPages(Map<String, dynamic> extra) =>
    extra['page_count']?.toString();

String? _extractIsbn(Map<String, dynamic> extra) =>
    extra['isbn13'] as String? ?? extra['isbn10'] as String?;

/// Per-media-type extra-metadata display fields, in display order.
extension MediaTypeMetadataFields on MediaType {
  List<MetadataFieldDescriptor> get metadataFields => switch (this) {
        MediaType.film || MediaType.tv => const [
            MetadataFieldDescriptor(label: 'Director', extract: _extractDirector),
            MetadataFieldDescriptor(label: 'Runtime', extract: _extractRuntime),
          ],
        MediaType.music => const [
            MetadataFieldDescriptor(label: 'Artist', extract: _extractArtists),
            MetadataFieldDescriptor(label: 'Label', extract: _extractLabel),
          ],
        MediaType.book => const [
            MetadataFieldDescriptor(label: 'Author', extract: _extractAuthors),
            MetadataFieldDescriptor(label: 'Pages', extract: _extractPages),
            MetadataFieldDescriptor(label: 'ISBN', extract: _extractIsbn),
          ],
        _ => const [],
      };
}

/// Describes the API credentials a media type needs before an online
/// title search can succeed.
class SearchCredentialRequirement {
  const SearchCredentialRequirement({
    required this.requiredKeys,
    required this.credentialLabel,
    required this.searchSubject,
  });

  /// Keys into the stored API-key map that must all be non-empty.
  final List<String> requiredKeys;

  /// Human-readable name of the credential(s), e.g. 'TMDB API key'.
  final String credentialLabel;

  /// What the credential unlocks searching for, e.g. 'films and TV'.
  final String searchSubject;

  /// True when every required key is present and non-empty in [apiKeys].
  bool isSatisfiedBy(Map<String, String?> apiKeys) =>
      requiredKeys.every((key) => (apiKeys[key] ?? '').isNotEmpty);
}

/// Per-media-type API-credential requirements for online title search.
///
/// Film/TV title search only routes to TMDB; without a TMDB key the
/// repository returns `notFound` without trying anything else. Game search
/// routes to IGDB, which requires a Twitch Client ID + Secret. Music, book,
/// and unknown always have at least one key-free fallback
/// (MusicBrainz / Open Library), so they require nothing.
extension MediaTypeSearchCredentials on MediaType {
  SearchCredentialRequirement? get searchCredentialRequirement =>
      switch (this) {
        MediaType.film || MediaType.tv => const SearchCredentialRequirement(
            requiredKeys: ['tmdb'],
            credentialLabel: 'TMDB API key',
            searchSubject: 'films and TV',
          ),
        MediaType.game => const SearchCredentialRequirement(
            requiredKeys: ['twitch_client_id', 'twitch_client_secret'],
            credentialLabel: 'Twitch Client ID and Secret',
            searchSubject: 'games (IGDB)',
          ),
        _ => null,
      };
}
