import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/tmdb_account_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_state_dto.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';

void main() {
  group('TmdbAccountMapper.tmdbToLocalRating', () {
    test('halves the TMDB rating', () {
      expect(TmdbAccountMapper.tmdbToLocalRating(8.0), 4.0);
      expect(TmdbAccountMapper.tmdbToLocalRating(0.5), 0.25);
      expect(TmdbAccountMapper.tmdbToLocalRating(10.0), 5.0);
    });

    test('returns null for null input', () {
      expect(TmdbAccountMapper.tmdbToLocalRating(null), isNull);
    });
  });

  group('TmdbAccountMapper.localToTmdbRating', () {
    test('doubles the local rating', () {
      expect(TmdbAccountMapper.localToTmdbRating(4.0), 8.0);
      expect(TmdbAccountMapper.localToTmdbRating(0.5), 1.0);
      expect(TmdbAccountMapper.localToTmdbRating(5.0), 10.0);
    });

    test('clamps to TMDB legal range 0.5–10', () {
      expect(TmdbAccountMapper.localToTmdbRating(0.0), 0.5);
      expect(TmdbAccountMapper.localToTmdbRating(6.0), 10.0);
    });
  });

  group('TmdbAccountMapper.fromAccountStateDto', () {
    test('extracts rating from `rated: { value: 7.5 }`', () {
      const dto = TmdbAccountStateDto(
        id: 550,
        favorite: true,
        watchlist: false,
        rated: {'value': 7.5},
      );

      final state =
          TmdbAccountMapper.fromAccountStateDto(dto, mediaType: 'movie');

      expect(state.tmdbId, 550);
      expect(state.mediaType, 'movie');
      expect(state.favorite, isTrue);
      expect(state.watchlist, isFalse);
      expect(state.rating, 7.5);
    });

    test('treats `rated: false` as no rating', () {
      const dto = TmdbAccountStateDto(
        id: 1,
        favorite: false,
        watchlist: true,
        rated: false,
      );

      final state =
          TmdbAccountMapper.fromAccountStateDto(dto, mediaType: 'tv');

      expect(state.rating, isNull);
      expect(state.watchlist, isTrue);
    });
  });

  group('TmdbAccountMapper.bucketCompanion', () {
    test('builds a watchlist companion with title/poster snapshot', () {
      const dto = TmdbAccountListItemDto(
        id: 42,
        title: 'The Hitchhikers Guide',
        releaseDate: '2005-04-28',
        posterPath: '/poster.jpg',
      );

      final companion = TmdbAccountMapper.bucketCompanion(
        dto,
        bucket: TmdbBridgeBucket.watchlist,
        mediaType: 'movie',
        existingId: null,
      );

      expect(companion.tmdbId.value, 42);
      expect(companion.tmdbMediaType.value, 'movie');
      expect(companion.watchlist.value, isTrue);
      expect(companion.favorite.present, isFalse,
          reason: 'favorite is absent for watchlist companions');
      expect(companion.tmdbRating.present, isFalse,
          reason: 'rating is absent for watchlist companions');
      expect(companion.titleSnapshot.value, 'The Hitchhikers Guide');
      expect(companion.posterPathSnapshot.value, '/poster.jpg');
    });

    test('builds a rated companion with raw TMDB rating', () {
      const dto = TmdbAccountListItemDto(
        id: 7,
        name: 'Series Title',
        firstAirDate: '2020-01-01',
        rating: 8.5,
      );

      final companion = TmdbAccountMapper.bucketCompanion(
        dto,
        bucket: TmdbBridgeBucket.rated,
        mediaType: 'tv',
        existingId: null,
      );

      expect(companion.tmdbRating.value, 8.5);
      expect(companion.titleSnapshot.value, 'Series Title');
    });
  });
}
