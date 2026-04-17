import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/services/recommendation_scorer.dart';
import 'package:mymediascanner/domain/services/taste_profile_builder.dart';

/// Ranks items the user already owns but has not consumed, suggesting
/// "what to read/watch next" with explainable reasons.
///
/// Inputs the full owned slice; filters out:
///   * items currently in progress (`startedAt != null && completedAt == null`)
///   * items already consumed (`consumed == true`)
///   * items the user has marked with userRating <= 1 (won't suggest dislikes)
///
/// The taste profile is built from the same owned slice, so the scorer
/// is calibrated against the user's actual collection.
class RecommendNextUseCase {
  const RecommendNextUseCase({
    RecommendationScorer? scorer,
    TasteProfileBuilder? profileBuilder,
  })  : _scorer = scorer ?? const RecommendationScorer(),
        _profileBuilder = profileBuilder ?? const TasteProfileBuilder();

  final RecommendationScorer _scorer;
  final TasteProfileBuilder _profileBuilder;

  /// Returns up to [limit] recommendations ordered by descending score.
  ///
  /// Returns an empty list when the taste profile carries no real
  /// signal — i.e. the user has neither rated anything highly nor shown
  /// series-collecting behaviour. A recency-only recommendation isn't
  /// useful and just echoes the collection chronology.
  List<Recommendation> rank(List<MediaItem> ownedItems, {int limit = 5}) {
    if (ownedItems.isEmpty) return const [];

    final profile = _profileBuilder.build(ownedItems);
    final hasSignal = profile.lovedGenres.isNotEmpty ||
        profile.lovedTags.isNotEmpty ||
        profile.collectedSeriesIds.isNotEmpty;
    if (!hasSignal) return const [];

    final candidates = ownedItems.where((item) {
      if (item.deleted) return false;
      if (item.ownershipStatus != OwnershipStatus.owned) return false;
      if (item.consumed) return false;
      if (item.startedAt != null && item.completedAt == null) return false;
      if (item.userRating != null && item.userRating! <= 1) return false;
      return true;
    });

    final scored = <Recommendation>[];
    for (final item in candidates) {
      final result = _scorer.score(item, profile);
      if (result.score <= 0) continue;
      scored.add(Recommendation(
        item: item,
        score: result.score,
        reasons: result.reasons,
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.length <= limit) return scored;
    return scored.sublist(0, limit);
  }
}
