import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/discogs_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';

void main() {
  group('DiscogsMapper', () {
    test('maps release to MetadataResult with correct fields', () {
      const dto = DiscogsReleaseDto(
        id: 12345,
        title: 'OK Computer',
        year: 1997,
        artists: [DiscogsArtistDto(name: 'Radiohead')],
        labels: [DiscogsLabelDto(name: 'Parlophone', catno: '7243 8 55229 2 8')],
        genres: ['Electronic', 'Rock'],
        images: [DiscogsImageDto(uri: 'https://img.discogs.com/ok.jpg', type: 'primary')],
        catno: 'CDNODATA 21',
        tracklist: [
          DiscogsTrackDto(position: '1', title: 'Airbag', duration: '4:44'),
          DiscogsTrackDto(position: '2', title: 'Paranoid Android', duration: '6:23'),
        ],
      );

      final result = DiscogsMapper.fromRelease(dto, '0724385522925', 'ean13');

      expect(result.title, 'OK Computer');
      expect(result.barcode, '0724385522925');
      expect(result.barcodeType, 'ean13');
      expect(result.mediaType, MediaType.music);
      expect(result.year, 1997);
      expect(result.coverUrl, 'https://img.discogs.com/ok.jpg');
      expect(result.publisher, 'Parlophone');
      expect(result.sourceApis, ['discogs']);
    });

    test('maps artist names and genres', () {
      const dto = DiscogsReleaseDto(
        id: 999,
        title: 'Test Album',
        artists: [
          DiscogsArtistDto(name: 'Artist One'),
          DiscogsArtistDto(name: 'Artist Two'),
        ],
        genres: ['Jazz', 'Funk'],
      );

      final result = DiscogsMapper.fromRelease(dto, '1234', 'ean13');

      expect(result.genres, ['Jazz', 'Funk']);
      final artists = result.extraMetadata['artists'] as List;
      expect(artists, ['Artist One', 'Artist Two']);
    });

    test('critic score normalisation (0-5 to 0-10)', () {
      const dto = DiscogsReleaseDto(
        id: 100,
        title: 'Rated Album',
        community: DiscogsCommunityDto(
          rating: DiscogsCommunityRatingDto(average: 4.5, count: 200),
        ),
      );

      final result = DiscogsMapper.fromRelease(dto, '5555', 'upc_a');

      // 4.5 * 2 = 9.0
      expect(result.criticScore, 9.0);
      expect(result.criticSource, 'Discogs');
    });

    test('critic score is null when community rating is absent', () {
      const dto = DiscogsReleaseDto(
        id: 101,
        title: 'Unrated Album',
      );

      final result = DiscogsMapper.fromRelease(dto, '6666', 'ean13');

      expect(result.criticScore, isNull);
      expect(result.criticSource, isNull);
    });

    test('extraMetadata contains discogs_release_id and track listing', () {
      const dto = DiscogsReleaseDto(
        id: 42,
        title: 'With Tracks',
        tracklist: [
          DiscogsTrackDto(position: 'A1', title: 'Side A Track 1', duration: '3:20'),
        ],
      );

      final result = DiscogsMapper.fromRelease(dto, '7777', 'ean13');

      expect(result.extraMetadata['discogs_release_id'], 42);
      final tracks = result.extraMetadata['track_listing'] as List;
      expect(tracks.length, 1);
      expect((tracks[0] as Map)['title'], 'Side A Track 1');
    });
  });

  group('DiscogsMapper.toCandidate', () {
    test('maps search result to MetadataCandidate', () {
      const dto = DiscogsSearchResultDto(
        id: 12345,
        title: 'Pink Floyd - Dark Side of the Moon',
        year: '1973',
        coverImage: 'https://example.com/cover.jpg',
      );

      final candidate = DiscogsMapper.toCandidate(dto);

      expect(candidate.sourceApi, 'discogs');
      expect(candidate.sourceId, '12345');
      expect(candidate.title, 'Pink Floyd - Dark Side of the Moon');
      expect(candidate.coverUrl, 'https://example.com/cover.jpg');
      expect(candidate.year, 1973);
      expect(candidate.mediaType, MediaType.music);
    });

    test('handles null year gracefully', () {
      const dto = DiscogsSearchResultDto(id: 1, title: 'Unknown Album');
      final candidate = DiscogsMapper.toCandidate(dto);
      expect(candidate.year, isNull);
      expect(candidate.coverUrl, isNull);
    });

    test('handles non-numeric year string', () {
      const dto = DiscogsSearchResultDto(id: 1, title: 'Album', year: 'Unknown');
      final candidate = DiscogsMapper.toCandidate(dto);
      expect(candidate.year, isNull);
    });
  });
}
