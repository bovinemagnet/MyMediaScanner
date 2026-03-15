/// FLAC to raw PCM decoder using the `flac` CLI tool.
///
/// Wraps the `flac` command-line utility to decode FLAC files into raw PCM
/// bytes (16-bit signed LE, stereo interleaved). Intended for use in isolates
/// for CPU-intensive audio quality analysis.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';
import 'dart:typed_data';

/// Decodes FLAC files to raw PCM using the `flac` CLI.
class FlacDecoder {
  /// Create a decoder with an optional custom binary path.
  ///
  /// If [binaryPath] is null, uses 'flac' from PATH.
  FlacDecoder({String? binaryPath}) : _binaryPath = binaryPath ?? 'flac';

  final String _binaryPath;

  /// The path to the flac binary being used.
  String get binaryPath => _binaryPath;

  /// Check whether the `flac` CLI is available.
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(_binaryPath, ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Decode a FLAC file to raw PCM bytes (16-bit signed LE, stereo).
  ///
  /// Uses `--force-raw-format` to produce headerless raw PCM output.
  /// Throws [FlacDecodeException] if decoding fails.
  Future<Uint8List> decode(String flacFilePath) async {
    final result = await Process.run(
      _binaryPath,
      [
        '-d', // decode
        '-c', // stdout
        '-f', // force overwrite (not applicable with -c, but harmless)
        '--force-raw-format',
        '--endian=little',
        '--sign=signed',
        flacFilePath,
      ],
      stdoutEncoding: null, // capture stdout as bytes
    );

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

/// Exception thrown when FLAC decoding fails.
class FlacDecodeException implements Exception {
  const FlacDecodeException(this.message);

  final String message;

  @override
  String toString() => 'FlacDecodeException: $message';
}
