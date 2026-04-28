import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('TmdbMapper', () {
    test('maps movie search result to MetadataResult', () {
      const dto = TmdbSearchResultDto(
        id: 550,
        title: 'Fight Club',
        overview: 'An insomniac office worker...',
        posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        releaseDate: '1999-10-15',
        mediaType: 'movie',
        voteAverage: 8.4,
        voteCount: 26000,
      );

      final result = TmdbMapper.fromSearchResult(dto, '5051892002172', 'ean13');

      expect(result.title, 'Fight Club');
      expect(result.mediaType, MediaType.film);
      expect(result.year, 1999);
      expect(result.coverUrl, contains('w500'));
      expect(result.sourceApis, ['tmdb']);
      expect(result.extraMetadata['tmdb_id'], 550);
      // Must be 'movie' not 'film' — the bridge table and TMDB API both use
      // 'movie', so TmdbMapper normalises at write time.
      expect(result.extraMetadata['media_type'], 'movie');
      expect(result.criticScore, 8.4);
      expect(result.criticSource, 'TMDB');
    });

    test('maps TV search result correctly', () {
      const dto = TmdbSearchResultDto(
        id: 1396,
        name: 'Breaking Bad',
        firstAirDate: '2008-01-20',
        mediaType: 'tv',
      );

      final result = TmdbMapper.fromSearchResult(dto, '1234567890123', 'ean13');

      expect(result.title, 'Breaking Bad');
      expect(result.mediaType, MediaType.tv);
      expect(result.year, 2008);
    });
  });

  group('TmdbMapper.toCandidate', () {
    test('maps movie search result to MetadataCandidate', () {
      const dto = TmdbSearchResultDto(
        id: 550,
        title: 'Fight Club',
        releaseDate: '1999-10-15',
        posterPath: '/poster.jpg',
        mediaType: 'movie',
      );

      final candidate = TmdbMapper.toCandidate(dto);

      expect(candidate.sourceApi, 'tmdb');
      expect(candidate.sourceId, '550');
      expect(candidate.title, 'Fight Club');
      expect(candidate.year, 1999);
      expect(candidate.coverUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
      expect(candidate.mediaType, MediaType.film);
    });

    test('maps TV search result to MetadataCandidate', () {
      const dto = TmdbSearchResultDto(
        id: 1399,
        name: 'Breaking Bad',
        firstAirDate: '2008-01-20',
        posterPath: '/bb.jpg',
        mediaType: 'tv',
      );

      final candidate = TmdbMapper.toCandidate(dto);

      expect(candidate.sourceApi, 'tmdb');
      expect(candidate.title, 'Breaking Bad');
      expect(candidate.mediaType, MediaType.tv);
    });
  });
}
