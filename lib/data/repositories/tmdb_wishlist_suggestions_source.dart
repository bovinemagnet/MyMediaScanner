import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/domain/repositories/i_wishlist_suggestions_source.dart';

/// [IWishlistSuggestionsSource] backed by TMDB's weekly trending lists.
class TmdbWishlistSuggestionsSource implements IWishlistSuggestionsSource {
  const TmdbWishlistSuggestionsSource(this._tmdb);

  final TmdbApi _tmdb;

  @override
  Future<List<SuggestionCandidate>> trendingCandidates() async {
    // Pull both movies and TV — the scorer will sort by relevance.
    final responses = await Future.wait([
      _tmdb.trending('movie'),
      _tmdb.trending('tv'),
    ]);
    return [
      for (final r in responses)
        for (final dto in r.results ?? const [])
          if (dto.id != null)
            SuggestionCandidate(
              sourceId: dto.id!.toString(),
              metadata: TmdbMapper.fromSearchResult(
                  dto, 'tmdb:${dto.id}', 'TMDB'),
            ),
    ];
  }
}
