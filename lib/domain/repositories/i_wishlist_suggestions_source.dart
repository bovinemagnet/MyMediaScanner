import 'package:mymediascanner/domain/entities/metadata_result.dart';

/// A single trending title from an external suggestions source, already
/// mapped to domain metadata.
class SuggestionCandidate {
  const SuggestionCandidate({
    required this.sourceId,
    required this.metadata,
  });

  /// Source-native identifier (e.g. the TMDB numeric id as a string).
  final String sourceId;

  /// Mapped metadata for the candidate title.
  final MetadataResult metadata;
}

/// Supplies a pool of trending candidate titles for wishlist
/// suggestions. Implemented in the data layer against TMDB.
abstract interface class IWishlistSuggestionsSource {
  /// Fetches the current trending candidate pool (movies and TV).
  Future<List<SuggestionCandidate>> trendingCandidates();
}
