import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/entities/taste_profile.dart';

/// Pure, deterministic scorer. Given a [TasteProfile] derived from the
/// user's collection and a candidate [MediaItem], returns a normalised
/// score in `[0, 1]` plus the structured [RecommendationReason]s that
/// contributed.
///
/// Scoring recipe:
///   * **Genre overlap** (weight 0.45): sum of `lovedGenres[g]` for each
///     genre `g` on the candidate, capped at 1.0.
///   * **Tag overlap**   (weight 0.20): same shape, over `lovedTags`.
///   * **Series collecting** (weight 0.20): full weight when the
///     candidate's `seriesId` is in `collectedSeriesIds`.
///   * **Recency** (weight 0.10): linear decay over the last 90 days
///     from `dateAdded`. Items older than 90 days contribute 0.
///   * **High personal rating** (weight 0.05): `userRating / 5.0` when
///     present. Lets the user's own marks lift their favourites without
///     dominating discovery.
///
/// Items that are completed, currently in-progress, or marked
/// `consumed` score 0 (the caller filters them out). The scorer itself
/// does not inspect those fields — see `RecommendNextUseCase`.
class RecommendationScorer {
  const RecommendationScorer({
    DateTime Function()? clock,
    Duration recencyWindow = const Duration(days: 90),
  })  : _clock = clock ?? DateTime.now,
        _recencyWindow = recencyWindow;

  final DateTime Function() _clock;
  final Duration _recencyWindow;

  static const double _wGenre = 0.45;
  static const double _wTag = 0.20;
  static const double _wSeries = 0.20;
  static const double _wRecency = 0.10;
  static const double _wRating = 0.05;

  /// Score [item] against [profile]. Always returns a value in `[0, 1]`.
  ({double score, List<RecommendationReason> reasons}) score(
    MediaItem item,
    TasteProfile profile,
  ) {
    final reasons = <RecommendationReason>[];
    var total = 0.0;

    // ── Genre overlap ────────────────────────────────────────────────
    final genreHits = <String>[];
    var genreScore = 0.0;
    for (final g in item.genres) {
      final w = profile.lovedGenres[g];
      if (w != null) {
        genreScore += w;
        genreHits.add(g);
      }
    }
    if (genreScore > 1.0) genreScore = 1.0;
    if (genreScore > 0) {
      total += _wGenre * genreScore;
      reasons.add(RecommendationReason(
        label: 'Matches genres you like: ${genreHits.join(', ')}',
        weight: _wGenre * genreScore,
      ));
    }

    // ── Tag overlap ──────────────────────────────────────────────────
    // (Tags live in a separate table; pass them on the item if/when the
    // scorer is fed enriched items. For now this branch is a no-op when
    // extraMetadata['tags'] is absent.)
    final tags = (item.extraMetadata['tags'] is List)
        ? List<String>.from(item.extraMetadata['tags'] as List)
        : const <String>[];
    final tagHits = <String>[];
    var tagScore = 0.0;
    for (final t in tags) {
      final w = profile.lovedTags[t];
      if (w != null) {
        tagScore += w;
        tagHits.add(t);
      }
    }
    if (tagScore > 1.0) tagScore = 1.0;
    if (tagScore > 0) {
      total += _wTag * tagScore;
      reasons.add(RecommendationReason(
        label: 'Tagged ${tagHits.join(', ')}',
        weight: _wTag * tagScore,
      ));
    }

    // ── Series the user is collecting ────────────────────────────────
    if (item.seriesId != null &&
        profile.collectedSeriesIds.contains(item.seriesId)) {
      total += _wSeries;
      reasons.add(const RecommendationReason(
        label: 'Part of a series you collect',
        weight: _wSeries,
      ));
    }

    // ── Recency ──────────────────────────────────────────────────────
    final ageMs =
        _clock().millisecondsSinceEpoch - item.dateAdded;
    final windowMs = _recencyWindow.inMilliseconds;
    if (ageMs >= 0 && ageMs < windowMs) {
      final freshness = 1.0 - (ageMs / windowMs);
      total += _wRecency * freshness;
      reasons.add(RecommendationReason(
        label: 'Recently added',
        weight: _wRecency * freshness,
      ));
    }

    // ── Personal rating ──────────────────────────────────────────────
    final r = item.userRating;
    if (r != null && r > 0) {
      final norm = (r / 5.0).clamp(0.0, 1.0);
      total += _wRating * norm;
      reasons.add(RecommendationReason(
        label: 'You rated this ${r.toStringAsFixed(1)}',
        weight: _wRating * norm,
      ));
    }

    if (total > 1.0) total = 1.0;
    return (score: total, reasons: reasons);
  }
}
