// Author: Paul Snow

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';

void main() {
  // Resolved relative to the package root when running `flutter test`.
  final fixtureFlac = File('test/fixtures/decode_stereo_16_44100.flac');
  final fixturePcm = File('test/fixtures/decode_stereo_16_44100.pcm');

  group('FlacDecoder', () {
    test('decodes a known FLAC file to bytes matching the PCM ground truth',
        () async {
      expect(fixtureFlac.existsSync(), isTrue,
          reason: 'fixture FLAC missing');
      expect(fixturePcm.existsSync(), isTrue,
          reason: 'fixture PCM missing');

      final decoder = FlacDecoder();
      final pcm = await decoder.decode(fixtureFlac.path);
      final expected = await fixturePcm.readAsBytes();

      expect(pcm.length, expected.length);
      expect(pcm, equals(expected));
    });

    test('decodes without a usable system flac binary on PATH', () async {
      // Construct a decoder whose configured binary path does not exist on
      // disk. The implementation must not depend on the external `flac` CLI.
      final decoder = FlacDecoder(binaryPath: '/nonexistent/no-such-flac-binary');
      final pcm = await decoder.decode(fixtureFlac.path);
      final expected = await fixturePcm.readAsBytes();

      expect(pcm, equals(expected));
    });

    test('isAvailable returns true even with a bogus binary path', () async {
      final decoder = FlacDecoder(binaryPath: '/nonexistent/no-such-flac-binary');
      expect(await decoder.isAvailable(), isTrue);
    });
  });
}
