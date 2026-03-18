import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/tvdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('TvdbMapper', () {
    group('fromSeries', () {
      test('maps all fields correctly', () {
        const series = TvdbSeriesDto(
          id: 73739,
          name: 'Lost',
          slug: 'lost',
          image: 'https://artworks.thetvdb.com/banners/posters/73739-1.jpg',
          year: '2004',
          overview: 'Survivors of a plane crash on a mysterious island.',
          genres: [
            TvdbGenreDto(id: 1, name: 'Drama'),
            TvdbGenreDto(id: 2, name: 'Mystery'),
          ],
        );

        final result = TvdbMapper.fromSeries(series, '123456', 'ean13');

        expect(result.barcode, '123456');
        expect(result.barcodeType, 'ean13');
        expect(result.mediaType, MediaType.tv);
        expect(result.title, 'Lost');
        expect(result.description,
            'Survivors of a plane crash on a mysterious island.');
        expect(result.coverUrl,
            'https://artworks.thetvdb.com/banners/posters/73739-1.jpg');
        expect(result.year, 2004);
        expect(result.genres, ['Drama', 'Mystery']);
        expect(result.sourceApis, ['tvdb']);
        expect(result.extraMetadata['tvdb_id'], 73739);
        expect(result.extraMetadata['tvdb_slug'], 'lost');
      });

      test('handles null fields gracefully', () {
        const series = TvdbSeriesDto(id: 1, name: 'Minimal');

        final result = TvdbMapper.fromSeries(series, '000', 'ean13');

        expect(result.title, 'Minimal');
        expect(result.year, isNull);
        expect(result.genres, isEmpty);
        expect(result.coverUrl, isNull);
        expect(result.description, isNull);
      });
    });

    group('fromSearchResult', () {
      test('maps movie type correctly', () {
        const dto = TvdbSearchResultDto(
          tvdbId: '550',
          name: 'Fight Club',
          type: 'movie',
          year: '1999',
          imageUrl: 'https://example.com/poster.jpg',
          overview: 'An insomniac and a soap maker.',
          network: null,
        );

        final result =
            TvdbMapper.fromSearchResult(dto, '123456', 'ean13');

        expect(result.mediaType, MediaType.film);
        expect(result.title, 'Fight Club');
        expect(result.year, 1999);
      });

      test('maps series type correctly', () {
        const dto = TvdbSearchResultDto(
          tvdbId: '73739',
          name: 'Lost',
          type: 'series',
          year: '2004',
          network: 'ABC',
          country: 'usa',
        );

        final result =
            TvdbMapper.fromSearchResult(dto, '123456', 'ean13');

        expect(result.mediaType, MediaType.tv);
        expect(result.extraMetadata['network'], 'ABC');
        expect(result.extraMetadata['country'], 'usa');
      });
    });

    group('toCandidate', () {
      test('maps fields for disambiguation', () {
        const dto = TvdbSearchResultDto(
          tvdbId: '73739',
          name: 'Lost',
          type: 'series',
          year: '2004',
          imageUrl: 'https://example.com/poster.jpg',
          network: 'ABC',
        );

        final candidate = TvdbMapper.toCandidate(dto);

        expect(candidate.sourceApi, 'tvdb');
        expect(candidate.sourceId, '73739');
        expect(candidate.title, 'Lost');
        expect(candidate.subtitle, 'ABC');
        expect(candidate.year, 2004);
        expect(candidate.mediaType, MediaType.tv);
        expect(candidate.coverUrl, 'https://example.com/poster.jpg');
      });

      test('handles missing tvdbId', () {
        const dto = TvdbSearchResultDto(name: 'No ID');
        final candidate = TvdbMapper.toCandidate(dto);

        expect(candidate.sourceId, '');
      });

      test('handles invalid year string', () {
        const dto = TvdbSearchResultDto(
          tvdbId: '1',
          name: 'Test',
          year: 'unknown',
        );
        final candidate = TvdbMapper.toCandidate(dto);

        expect(candidate.year, isNull);
      });
    });
  });
}
