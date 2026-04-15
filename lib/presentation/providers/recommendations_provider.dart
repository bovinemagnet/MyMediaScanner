import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/domain/usecases/recommend_next_usecase.dart';
import 'package:mymediascanner/domain/usecases/wishlist_suggestions_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

final recommendNextUseCaseProvider = Provider<RecommendNextUseCase>((ref) {
  return const RecommendNextUseCase();
});

/// Top-N "recommended next" items derived from the live owned-items
/// stream. Recomputes whenever the owned set changes.
final recommendedNextProvider =
    StreamProvider.family<List<Recommendation>, int>((ref, limit) {
  final repo = ref.watch(mediaItemRepositoryProvider);
  final usecase = ref.watch(recommendNextUseCaseProvider);
  return repo
      .watchByStatus(OwnershipStatus.owned)
      .map((items) => usecase.rank(items, limit: limit));
});

/// Convenience: top 5.
final topRecommendationsProvider =
    Provider<AsyncValue<List<Recommendation>>>((ref) {
  return ref.watch(recommendedNextProvider(5));
});

/// Source of owned items if other widgets need them without rescoring.
final ownedItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref
      .watch(mediaItemRepositoryProvider)
      .watchByStatus(OwnershipStatus.owned);
});

final wishlistSuggestionsUseCaseProvider =
    Provider<WishlistSuggestionsUseCase>((ref) {
  final apiKeys = ref.watch(apiKeysProvider).value ?? {};
  final tmdbKey = apiKeys['tmdb'];
  final tmdb = tmdbKey != null
      ? TmdbApi(DioFactory.createWithBearerToken(
          baseUrl: ApiConstants.tmdbBaseUrl,
          token: tmdbKey,
        ))
      : null;
  return WishlistSuggestionsUseCase(
    mediaRepository: ref.watch(mediaItemRepositoryProvider),
    tmdbApi: tmdb,
  );
});

final wishlistSuggestionsProvider =
    FutureProvider<List<WishlistSuggestion>>((ref) {
  return ref.watch(wishlistSuggestionsUseCaseProvider).suggest();
});
