import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_wishlist_suggestions_source.dart';
import 'package:mymediascanner/domain/services/recommendation_scorer.dart';
import 'package:mymediascanner/domain/services/taste_profile_builder.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';

/// Suggests items the user does NOT yet own, ranked against their taste
/// profile. Uses TMDB's weekly trending list as a candidate pool, then
/// reuses [RecommendationScorer] for ranking — keeps the scoring story
/// consistent between owned-recommendations and wishlist-suggestions.
class WishlistSuggestionsUseCase {
  WishlistSuggestionsUseCase({
    required IMediaItemRepository mediaRepository,
    IWishlistSuggestionsSource? source,
    RecommendationScorer? scorer,
    TasteProfileBuilder? profileBuilder,
  })  : _mediaRepo = mediaRepository,
        _source = source,
        _scorer = scorer ?? const RecommendationScorer(),
        _profileBuilder = profileBuilder ?? const TasteProfileBuilder();

  final IMediaItemRepository _mediaRepo;
  final IWishlistSuggestionsSource? _source;
  final RecommendationScorer _scorer;
  final TasteProfileBuilder _profileBuilder;

  /// Returns up to [limit] suggestions. Empty when no TMDB key is
  /// configured or the collection is too thin to build a profile.
  Future<List<WishlistSuggestion>> suggest({int limit = 10}) async {
    final source = _source;
    if (source == null) return const [];

    final ownedStream = _mediaRepo.watchByStatus(OwnershipStatus.owned);
    final owned = await ownedStream.first;
    if (owned.isEmpty) return const [];

    final profile = _profileBuilder.build(owned);
    final ownedTmdbIds = <String>{
      for (final item in owned)
        if (item.extraMetadata['tmdb_id'] != null)
          item.extraMetadata['tmdb_id'].toString(),
    };

    final candidates = await source.trendingCandidates();

    final suggestions = <WishlistSuggestion>[];
    for (final candidate in candidates) {
      final tmdbId = candidate.sourceId;
      if (ownedTmdbIds.contains(tmdbId)) continue;
      final metadata = candidate.metadata;

      // Build a synthetic MediaItem so we can reuse the scorer.
      final synthetic = MediaItem(
        id: 'suggest-$tmdbId',
        barcode: 'tmdb:$tmdbId',
        barcodeType: 'TMDB',
        mediaType: metadata.mediaType ?? MediaType.unknown,
        title: metadata.title ?? '',
        coverUrl: metadata.coverUrl,
        year: metadata.year,
        genres: metadata.genres,
        extraMetadata: metadata.extraMetadata,
        dateAdded: DateTime.now().millisecondsSinceEpoch,
        dateScanned: 0,
        updatedAt: 0,
      );
      final result = _scorer.score(synthetic, profile);
      if (result.score <= 0) continue;
      suggestions.add(WishlistSuggestion(
        externalId: 'tmdb:$tmdbId',
        title: synthetic.title,
        coverUrl: synthetic.coverUrl,
        year: synthetic.year,
        genres: synthetic.genres,
        source: 'tmdb',
        score: result.score,
        reasons: result.reasons,
      ));
    }

    suggestions.sort((a, b) => b.score.compareTo(a.score));
    if (suggestions.length <= limit) return suggestions;
    return suggestions.sublist(0, limit);
  }
}
