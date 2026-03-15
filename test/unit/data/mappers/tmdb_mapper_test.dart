import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('TmdbMapper', () {
    test('maps movie search result to MetadataResult', () {
      final dto = TmdbSearchResultDto(
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
      expect(result.criticScore, 8.4);
      expect(result.criticSource, 'TMDB');
    });

    test('maps TV search result correctly', () {
      final dto = TmdbSearchResultDto(
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
}
