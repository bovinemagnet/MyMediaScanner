import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/flac_reader.dart';

import '../../helpers/flac_fixtures.dart';

void main() {
  group('FlacReader', () {
    test('extracts artist, album, title, and track number', () {
      final bytes = buildFlacFixture(tags: {
        'ARTIST': 'Test Artist',
        'ALBUM': 'Test Album',
        'TITLE': 'Test Track',
        'TRACKNUMBER': '3',
        'DISCNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.artist, equals('Test Artist'));
      expect(metadata.album, equals('Test Album'));
      expect(metadata.title, equals('Test Track'));
      expect(metadata.trackNumber, equals(3));
      expect(metadata.discNumber, equals(1));
    });

    test('ALBUMARTIST takes precedence over ARTIST', () {
      final bytes = buildFlacFixture(tags: {
        'ARTIST': 'Track Artist',
        'ALBUMARTIST': 'Album Artist',
        'ALBUM': 'Compilation',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.effectiveArtist, equals('Album Artist'));
      expect(metadata.artist, equals('Track Artist'));
      expect(metadata.albumArtist, equals('Album Artist'));
    });

    test('handles missing tags gracefully', () {
      final bytes = buildFlacFixture(tags: {
        'ALBUM': 'Only Album',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.album, equals('Only Album'));
      expect(metadata.artist, isNull);
      expect(metadata.title, isNull);
      expect(metadata.trackNumber, isNull);
      expect(metadata.discNumber, isNull);
      expect(metadata.barcode, isNull);
      expect(metadata.effectiveArtist, isNull);
    });

    test('extracts barcode from BARCODE tag', () {
      final bytes = buildFlacFixture(tags: {
        'BARCODE': '0602445123456',
        'ALBUM': 'With Barcode',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.barcode, equals('0602445123456'));
    });

    test('extracts barcode from UPC tag as fallback', () {
      final bytes = buildFlacFixture(tags: {
        'UPC': '012345678901',
        'ALBUM': 'With UPC',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.barcode, equals('012345678901'));
    });

    test('extracts total tracks from TOTALTRACKS', () {
      final bytes = buildFlacFixture(tags: {
        'TOTALTRACKS': '12',
        'TRACKNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.totalTracks, equals(12));
    });

    test('extracts total tracks from TRACKTOTAL as fallback', () {
      final bytes = buildFlacFixture(tags: {
        'TRACKTOTAL': '10',
        'TRACKNUMBER': '1',
      });

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.totalTracks, equals(10));
    });

    test('computes duration from STREAMINFO', () {
      // 44100 Hz, 441000 samples = 10 seconds = 10000 ms
      final bytes = buildFlacFixture(
        tags: {'TITLE': 'Duration Test'},
        sampleRate: 44100,
        totalSamples: 441000,
      );

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.durationMs, equals(10000));
    });

    test('exposes the exact total sample count from STREAMINFO', () {
      // Pick a sample count that does not divide evenly by sampleRate so a
      // duration-based approximation would not round-trip to the same value.
      const samples = 441001;
      final bytes = buildFlacFixture(
        tags: {'TITLE': 'Sample Count Test'},
        sampleRate: 44100,
        totalSamples: samples,
      );

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.totalSamples, equals(samples));
    });

    test('rejects non-FLAC files', () {
      final bytes = Uint8List.fromList([0x49, 0x44, 0x33, 0x04]); // ID3 header

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNull);
    });

    test('rejects empty bytes', () {
      final metadata = FlacReader.readMetadataFromBytes(Uint8List(0));

      expect(metadata, isNull);
    });

    test('handles file with no VORBIS_COMMENT block', () {
      final bytes = buildFlacFixture(
        tags: null,
        includeVorbisComment: false,
        isLastBlockStreamInfo: true,
      );

      final metadata = FlacReader.readMetadataFromBytes(bytes);

      expect(metadata, isNotNull);
      expect(metadata!.artist, isNull);
      expect(metadata.album, isNull);
      // Duration should still be computed from STREAMINFO
      expect(metadata.durationMs, equals(10000));
    });

    group('cover art', () {
      test('exposes the first embedded picture and its MIME type', () {
        final art = Uint8List.fromList([1, 2, 3, 4, 5]);
        final bytes = buildFlacFixture(
          tags: {'ARTIST': 'Cappella'},
          pictureData: art,
          pictureMimeType: 'image/png',
        );

        final metadata = FlacReader.readMetadataFromBytes(bytes);

        expect(metadata, isNotNull);
        expect(metadata!.coverArt, art);
        expect(metadata.coverArtMimeType, 'image/png');
      });

      test('coverArt is null when no picture block exists', () {
        final bytes = buildFlacFixture(tags: {'ARTIST': 'Cappella'});

        final metadata = FlacReader.readMetadataFromBytes(bytes);

        expect(metadata!.coverArt, isNull);
        expect(metadata.coverArtMimeType, isNull);
      });
    });
  });
}
