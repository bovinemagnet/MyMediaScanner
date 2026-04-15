/// A summary of the user's collection from which the recommendation
/// scorer derives its signal.
///
/// All fields are derived purely from existing data — no preferences UI,
/// no remote calls. Built once per recommendation pass, then read many
/// times by the scorer.
class TasteProfile {
  const TasteProfile({
    required this.lovedGenres,
    required this.lovedTags,
    required this.collectedSeriesIds,
    required this.averageRating,
    required this.totalRatedItems,
  });

  /// Genres weighted by how often they appear on items rated >= 4.0.
  /// Map values are normalised to `[0, 1]` (relative frequency).
  final Map<String, double> lovedGenres;

  /// Tags weighted by how often they appear on items rated >= 4.0.
  final Map<String, double> lovedTags;

  /// Series the user is actively collecting (>= 2 owned items in a
  /// series). Items belonging to these series get a boost.
  final Set<String> collectedSeriesIds;

  /// Mean of every non-null user rating in the collection.
  final double? averageRating;

  /// Number of items contributing to [averageRating]. The scorer can use
  /// this as a confidence proxy.
  final int totalRatedItems;

  /// Empty profile — used as a safe fallback when the user has no rated
  /// items yet.
  static const TasteProfile empty = TasteProfile(
    lovedGenres: {},
    lovedTags: {},
    collectedSeriesIds: {},
    averageRating: null,
    totalRatedItems: 0,
  );
}
