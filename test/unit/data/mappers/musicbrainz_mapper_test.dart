import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/musicbrainz_mapper.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('MusicBrainzMapper', () {
    const sampleRelease = MusicBrainzReleaseDto(
      id: 'abc-123',
      title: 'Vertigo 2005 // Live From Chicago',
      date: '2005-11-11',
      country: 'AU',
      barcode: '602498746400',
      score: 100,
      packaging: 'Jewel Case',
      artistCredit: [
        MusicBrainzArtistCreditDto(
          name: 'U2',
          artist: MusicBrainzArtistDto(
            id: 'artist-1',
            name: 'U2',
            sortName: 'U2',
          ),
        ),
      ],
      releaseGroup: MusicBrainzReleaseGroupDto(
        id: 'rg-456',
        title: 'Vertigo 2005 // Live From Chicago',
        primaryType: 'Album',
      ),
      labelInfo: [
        MusicBrainzLabelInfoDto(
          catalogNumber: '9874640',
          label: MusicBrainzLabelDto(
            id: 'label-1',
            name: 'Island Records',
          ),
        ),
      ],
      media: [
        MusicBrainzMediaDto(
          format: 'DVD',
          trackCount: 2,
          tracks: [
            MusicBrainzTrackDto(
              id: 'track-1',
              title: 'City of Blinding Lights',
              number: '1',
              length: 300000,
            ),
            MusicBrainzTrackDto(
              id: 'track-2',
              title: 'Vertigo',
              number: '2',
              length: 250000,
            ),
          ],
        ),
      ],
      tags: [
        MusicBrainzTagDto(count: 5, name: 'rock'),
        MusicBrainzTagDto(count: 3, name: 'live'),
      ],
    );

    group('fromRelease', () {
      test('maps all fields correctly', () {
        final result = MusicBrainzMapper.fromRelease(
          sampleRelease,
          '602498746400',
          'ean13',
        );

        expect(result.barcode, '602498746400');
        expect(result.barcodeType, 'ean13');
        expect(result.mediaType, MediaType.music);
        expect(result.title, 'Vertigo 2005 // Live From Chicago');
        expect(result.subtitle, 'U2');
        expect(result.year, 2005);
        expect(result.publisher, 'Island Records');
        expect(result.format, 'DVD');
        expect(result.genres, ['rock', 'live']);
        expect(result.sourceApis, ['musicbrainz']);
        expect(result.coverUrl,
            'https://coverartarchive.org/release/abc-123/front-250');
      });

      test('extraMetadata contains MusicBrainz IDs', () {
        final result = MusicBrainzMapper.fromRelease(
          sampleRelease,
          '602498746400',
          'ean13',
        );

        expect(result.extraMetadata['musicbrainz_release_id'], 'abc-123');
        expect(
            result.extraMetadata['musicbrainz_release_group_id'], 'rg-456');
        expect(result.extraMetadata['artists'], ['U2']);
        expect(result.extraMetadata['catalogue_number'], '9874640');
        expect(result.extraMetadata['country'], 'AU');
      });

      test('extraMetadata contains track listing', () {
        final result = MusicBrainzMapper.fromRelease(
          sampleRelease,
          '602498746400',
          'ean13',
        );

        final tracks =
            result.extraMetadata['track_listing'] as List<dynamic>;
        expect(tracks.length, 2);
        expect(tracks[0]['title'], 'City of Blinding Lights');
        expect(tracks[1]['title'], 'Vertigo');
      });

      test('handles null fields gracefully', () {
        const minimal = MusicBrainzReleaseDto(
          id: 'min-1',
          title: 'Minimal',
        );

        final result =
            MusicBrainzMapper.fromRelease(minimal, '1234', 'ean13');

        expect(result.title, 'Minimal');
        expect(result.subtitle, isNull);
        expect(result.year, isNull);
        expect(result.publisher, isNull);
        expect(result.genres, isEmpty);
      });
    });

    group('toCandidate', () {
      test('maps fields for disambiguation', () {
        final candidate = MusicBrainzMapper.toCandidate(sampleRelease);

        expect(candidate.sourceApi, 'musicbrainz');
        expect(candidate.sourceId, 'abc-123');
        expect(candidate.title, 'Vertigo 2005 // Live From Chicago');
        expect(candidate.subtitle, 'U2');
        expect(candidate.year, 2005);
        expect(candidate.format, 'DVD');
        expect(candidate.mediaType, MediaType.music);
        expect(candidate.coverUrl,
            'https://coverartarchive.org/release/abc-123/front-250');
      });

      test('handles missing ID', () {
        const noId = MusicBrainzReleaseDto(title: 'No ID');
        final candidate = MusicBrainzMapper.toCandidate(noId);

        expect(candidate.sourceId, '');
        expect(candidate.coverUrl, isNull);
      });
    });
  });
}
