import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/musicbrainz_mapper.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_movie_detail_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';

void main() {
  group('MusicBrainz series extraction', () {
    test('promotes release-group id and title to series fields', () {
      const dto = MusicBrainzReleaseDto(
        id: 'rel-1',
        title: 'OK Computer',
        releaseGroup: MusicBrainzReleaseGroupDto(
          id: 'rg-42',
          title: 'OK Computer',
          primaryType: 'Album',
        ),
      );

      final result = MusicBrainzMapper.fromRelease(dto, '123', 'EAN13');

      expect(result.seriesExternalId, 'mb:rg-42');
      expect(result.seriesName, 'OK Computer');
    });

    test('leaves series fields null when releaseGroup absent', () {
      const dto = MusicBrainzReleaseDto(id: 'rel-1', title: 't');
      final result = MusicBrainzMapper.fromRelease(dto, '123', 'EAN13');
      expect(result.seriesExternalId, isNull);
      expect(result.seriesName, isNull);
    });
  });

  group('TMDB enrichWithMovieDetail', () {
    test('populates series fields from belongs_to_collection', () {
      const search = TmdbSearchResultDto(id: 1, title: 'Iron Man', mediaType: 'movie');
      final base = TmdbMapper.fromSearchResult(search, '123', 'EAN13');
      const detail = TmdbMovieDetailDto(
        id: 1,
        title: 'Iron Man',
        belongsToCollection:
            TmdbCollectionRefDto(id: 86311, name: 'The Avengers Collection'),
      );

      final enriched = TmdbMapper.enrichWithMovieDetail(base, detail);

      expect(enriched.seriesExternalId, 'tmdb:86311');
      expect(enriched.seriesName, 'The Avengers Collection');
    });

    test('returns input unchanged when no belongs_to_collection', () {
      const search =
          TmdbSearchResultDto(id: 1, title: 'Standalone', mediaType: 'movie');
      final base = TmdbMapper.fromSearchResult(search, '123', 'EAN13');
      const detail =
          TmdbMovieDetailDto(id: 1, title: 'Standalone');

      final enriched = TmdbMapper.enrichWithMovieDetail(base, detail);

      expect(enriched, base);
    });
  });
}
