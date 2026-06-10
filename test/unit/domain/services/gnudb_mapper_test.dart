import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/services/gnudb_mapper.dart';

void main() {
  const sampleDisc = GnudbDisc(
    discId: '08025603',
    artist: 'Example Artist',
    albumTitle: 'Example Album',
    year: 2023,
    genre: 'Rock',
    trackTitles: ['First Song', 'Second Song', 'Third Song'],
    extendedAlbum: 'Album notes',
  );

  group('GnudbMapper.toMetadataResult', () {
    test('maps core fields to a music-typed MetadataResult', () {
      final result = GnudbMapper.toMetadataResult(
        sampleDisc,
        category: 'rock',
      );
      expect(result.barcode, 'gnudb:08025603');
      expect(result.barcodeType, 'cddb');
      expect(result.mediaType, MediaType.music);
      expect(result.title, 'Example Album');
      expect(result.subtitle, 'Example Artist');
      expect(result.year, 2023);
      expect(result.genres, ['Rock']);
      expect(result.sourceApis, ['gnudb']);
    });

    test('stashes gnudb-specific identifiers in extraMetadata', () {
      final result = GnudbMapper.toMetadataResult(
        sampleDisc,
        category: 'rock',
      );
      expect(result.extraMetadata['gnudb_disc_id'], '08025603');
      expect(result.extraMetadata['gnudb_category'], 'rock');
      expect(result.extraMetadata['gnudb_track_titles'], [
        'First Song',
        'Second Song',
        'Third Song',
      ]);
      expect(result.extraMetadata['gnudb_album_notes'], 'Album notes');
    });

    test('produces empty genres list when genre is null', () {
      const disc = GnudbDisc(
        discId: 'deadbeef',
        artist: 'A',
        albumTitle: 'B',
        trackTitles: ['One'],
      );
      final result = GnudbMapper.toMetadataResult(disc, category: 'misc');
      expect(result.genres, isEmpty);
      expect(result.year, isNull);
    });

    test('track listing is included in extraMetadata', () {
      final result = GnudbMapper.toMetadataResult(
        sampleDisc,
        category: 'rock',
      );
      final listing = result.extraMetadata['track_listing']
          as List<Map<String, dynamic>>;
      expect(listing, hasLength(3));
      expect(listing[0]['position'], 1);
      expect(listing[0]['title'], 'First Song');
      expect(listing[2]['position'], 3);
    });
  });

  group('GnudbMapper.toCandidate', () {
    test('builds a MetadataCandidate with source=gnudb', () {
      final candidate = GnudbMapper.toCandidate(
        sampleDisc,
        category: 'rock',
      );
      expect(candidate.sourceApi, 'gnudb');
      expect(candidate.sourceId, 'rock:08025603');
      expect(candidate.title, 'Example Album');
      expect(candidate.subtitle, 'Example Artist');
      expect(candidate.year, 2023);
      expect(candidate.mediaType, MediaType.music);
    });
  });
}
