// Author: Paul Snow

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/core/utils/native_flac_decoder.dart';

void main() {
  final fixtureFlac = File('test/fixtures/decode_stereo_16_44100.flac');
  final fixturePcm = File('test/fixtures/decode_stereo_16_44100.pcm');

  // The native path requires the system `flac` binary. Skip the
  // happy-path tests when it isn't installed so CI on machines
  // without flac doesn't false-fail; the bogus-path tests still
  // run because they only exercise the Process.run failure branch.
  final flacOnPath = _flacOnPath();

  group('NativeFlacDecoder', () {
    test(
      'is a FlacDecoder so the use case can use it interchangeably',
      () {
        final decoder = NativeFlacDecoder();
        expect(decoder, isA<FlacDecoder>());
      },
    );

    test(
      'decodes a known FLAC file to bytes matching the PCM ground truth',
      () async {
        final decoder = NativeFlacDecoder();
        final pcm = await decoder.decode(fixtureFlac.path);
        final expected = await fixturePcm.readAsBytes();
        expect(pcm, equals(expected));
      },
      skip: flacOnPath ? false : 'system flac binary not on PATH',
    );

    test(
      'isAvailable returns true when flac is on PATH',
      () async {
        final decoder = NativeFlacDecoder();
        expect(await decoder.isAvailable(), isTrue);
      },
      skip: flacOnPath ? false : 'system flac binary not on PATH',
    );

    test('isAvailable returns false when binary path does not exist', () async {
      final decoder = NativeFlacDecoder(
        binaryPath: '/nonexistent/no-such-flac-binary',
      );
      expect(await decoder.isAvailable(), isFalse);
    });

    test('decode throws FlacDecodeException when binary is missing', () async {
      final decoder = NativeFlacDecoder(
        binaryPath: '/nonexistent/no-such-flac-binary',
      );
      expect(
        () => decoder.decode(fixtureFlac.path),
        throwsA(isA<FlacDecodeException>()),
      );
    });
  });
}

bool _flacOnPath() {
  try {
    final result = Process.runSync('flac', ['--version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}
