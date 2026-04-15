import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';

part 'recommendation.freezed.dart';

/// A single contributing factor to a recommendation's score.
///
/// `weight` is the unscaled contribution (positive or negative) as returned
/// by the scorer. The UI displays [label] and may use [weight] to sort or
/// emphasise reasons.
@freezed
sealed class RecommendationReason with _$RecommendationReason {
  const factory RecommendationReason({
    required String label,
    required double weight,
  }) = _RecommendationReason;
}

/// A single ranked recommendation: an item, a normalised [score] in
/// `[0, 1]`, and the [reasons] that contributed to it.
@freezed
sealed class Recommendation with _$Recommendation {
  const factory Recommendation({
    required MediaItem item,
    required double score,
    required List<RecommendationReason> reasons,
  }) = _Recommendation;
}

/// A "wishlist suggestion" — an external candidate (not yet in the
/// collection) the user might want to add.
@freezed
sealed class WishlistSuggestion with _$WishlistSuggestion {
  const factory WishlistSuggestion({
    required String externalId,
    required String title,
    String? subtitle,
    String? coverUrl,
    int? year,
    @Default([]) List<String> genres,
    required String source,
    required double score,
    required List<RecommendationReason> reasons,
  }) = _WishlistSuggestion;
}
