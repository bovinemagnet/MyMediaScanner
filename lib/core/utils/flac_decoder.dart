/// FLAC to raw PCM decoder.
///
/// Wraps the pure-Dart `dart_flac` library to decode FLAC files into raw PCM
/// bytes (16-bit signed LE, stereo interleaved). The decode runs in an
/// isolate to avoid blocking the UI on long files.
///
/// The constructor still accepts a [binaryPath] for backwards compatibility
/// with the secure-storage override that was used by the legacy `flac` CLI
/// implementation; the value is ignored — no external binary is invoked.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_flac/dart_flac.dart' as dflac;

/// Decodes FLAC files to raw PCM using the in-process `dart_flac` decoder.
class FlacDecoder {
  /// Create a decoder.
  ///
  /// [binaryPath] is accepted for backwards compatibility with a previous
  /// CLI-based implementation but is now ignored.
  FlacDecoder({String? binaryPath}) : _binaryPath = binaryPath ?? 'flac';

  final String _binaryPath;

  /// The configured binary path (now informational only — no binary is
  /// invoked).
  String get binaryPath => _binaryPath;

  /// Always returns `true` — decoding is in-process and has no external
  /// dependency to probe.
  Future<bool> isAvailable() async => true;

  /// Decode a FLAC file to raw PCM bytes (16-bit signed LE, interleaved).
  ///
  /// The decode runs in an isolate. Throws [FlacDecodeException] if decoding
  /// fails.
  Future<Uint8List> decode(String flacFilePath) async {
    try {
      return await Isolate.run(
        () => dflac.decodeFlacFileToPcm(flacFilePath),
      );
    } catch (e) {
      throw FlacDecodeException('Failed to decode $flacFilePath: $e');
    }
  }
}

/// Exception thrown when FLAC decoding fails.
class FlacDecodeException implements Exception {
  const FlacDecodeException(this.message);

  final String message;

  @override
  String toString() => 'FlacDecodeException: $message';
}
