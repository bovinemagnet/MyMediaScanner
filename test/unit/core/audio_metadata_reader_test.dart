// Tests for AudioMetadataReader.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/audio_metadata_reader.dart';

void main() {
  group('AudioMetadataReader', () {
    test('supportedExtensions contains flac and mp3', () {
      expect(
          AudioMetadataReader.supportedExtensions, containsAll(['.flac', '.mp3']));
    });

    test('readMetadata returns null for unsupported extension', () async {
      final result = await AudioMetadataReader.readMetadata('/tmp/test.wav');
      expect(result, isNull);
    });

    test('readMetadata returns null for nonexistent flac file', () async {
      final result = await AudioMetadataReader.readMetadata(
          '/tmp/nonexistent_audio_file_12345.flac');
      expect(result, isNull);
    });

    test('readMetadata returns null for nonexistent mp3 file', () async {
      final result = await AudioMetadataReader.readMetadata(
          '/tmp/nonexistent_audio_file_12345.mp3');
      expect(result, isNull);
    });

    test('AudioMetadata effectiveArtist prefers albumArtist', () {
      const m = AudioMetadata(
        artist: 'Artist',
        albumArtist: 'Album Artist',
        format: AudioFormat.flac,
      );
      expect(m.effectiveArtist, 'Album Artist');
    });

    test('AudioMetadata effectiveArtist falls back to artist', () {
      const m = AudioMetadata(
        artist: 'Solo Artist',
        format: AudioFormat.mp3,
      );
      expect(m.effectiveArtist, 'Solo Artist');
    });

    test('AudioFormat enum has expected values', () {
      expect(AudioFormat.values, containsAll([AudioFormat.flac, AudioFormat.mp3]));
    });
  });
}
