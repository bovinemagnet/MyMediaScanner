/// FLAC to raw PCM decoder backed by the system `flac` CLI.
///
/// Used as an opt-in fast path for desktop bulk re-analysis where the
/// pure-Dart [FlacDecoder] is correct but ~5× slower than native C. Falls
/// back transparently — callers should probe [isAvailable] once and only
/// substitute this decoder when the result is `true`.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:mymediascanner/core/utils/flac_decoder.dart';

/// Decodes FLAC files via the system `flac` binary.
///
/// Extends [FlacDecoder] so the surrounding code paths (use case
/// constructor, mocks) treat it identically to the in-process decoder.
class NativeFlacDecoder extends FlacDecoder {
  NativeFlacDecoder({super.binaryPath});

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(binaryPath, ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Uint8List> decode(String flacFilePath) async {
    final ProcessResult result;
    try {
      result = await Process.run(
        binaryPath,
        [
          '-d', // decode
          '-c', // stdout
          '-f', // force overwrite (no-op with -c, harmless)
          '--force-raw-format',
          '--endian=little',
          '--sign=signed',
          flacFilePath,
        ],
        stdoutEncoding: null, // capture stdout as bytes
      );
    } catch (e) {
      throw FlacDecodeException(
        'Failed to invoke flac binary at $binaryPath: $e',
      );
    }

    if (result.exitCode != 0) {
      final stderr = result.stderr is String
          ? result.stderr as String
          : String.fromCharCodes(result.stderr as List<int>);
      throw FlacDecodeException(
        'Failed to decode $flacFilePath (exit code ${result.exitCode}): '
        '${stderr.trim()}',
      );
    }

    final stdout = result.stdout;
    if (stdout is Uint8List) return stdout;
    if (stdout is List<int>) return Uint8List.fromList(stdout);

    throw FlacDecodeException(
      'Unexpected stdout type from flac process: ${stdout.runtimeType}',
    );
  }
}
