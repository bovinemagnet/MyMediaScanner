/// Writes Vorbis Comment tags to FLAC files using the metaflac CLI.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

/// Writes Vorbis Comment tags to FLAC files using the `metaflac` CLI.
class MetaflacWriter {
  /// Create a writer with an optional custom binary path.
  ///
  /// If [binaryPath] is null, uses 'metaflac' from PATH.
  MetaflacWriter({String? binaryPath}) : _binaryPath = binaryPath ?? 'metaflac';

  final String _binaryPath;

  /// The path to the metaflac binary being used.
  String get binaryPath => _binaryPath;

  /// Check whether the `metaflac` CLI is available.
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(_binaryPath, ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Write [tags] to the FLAC file at [filePath].
  ///
  /// For each tag, first removes any existing value with `--remove-tag`,
  /// then sets the new value with `--set-tag`. All operations are issued
  /// as a single `metaflac` invocation.
  ///
  /// Throws [MetaflacWriteException] if the process exits with a non-zero
  /// code or cannot be started.
  Future<void> setTags(String filePath, Map<String, String> tags) async {
    final args = <String>[];
    for (final entry in tags.entries) {
      args
        ..add('--remove-tag=${entry.key}')
        ..add('--set-tag=${entry.key}=${entry.value}');
    }
    args.add(filePath);

    try {
      final result = await Process.run(_binaryPath, args);
      if (result.exitCode != 0) {
        final stderr = result.stderr is String
            ? result.stderr as String
            : String.fromCharCodes(result.stderr as List<int>);
        throw MetaflacWriteException(
          'Failed to set tags on $filePath (exit code ${result.exitCode}): '
          '${stderr.trim()}',
        );
      }
    } on MetaflacWriteException {
      rethrow;
    } catch (e) {
      throw MetaflacWriteException('Failed to run metaflac: $e');
    }
  }

  /// Remove the tag identified by [tagKey] from the FLAC file at [filePath].
  ///
  /// Throws [MetaflacWriteException] if the process exits with a non-zero
  /// code or cannot be started.
  Future<void> removeTag(String filePath, String tagKey) async {
    try {
      final result = await Process.run(
        _binaryPath,
        ['--remove-tag=$tagKey', filePath],
      );
      if (result.exitCode != 0) {
        final stderr = result.stderr is String
            ? result.stderr as String
            : String.fromCharCodes(result.stderr as List<int>);
        throw MetaflacWriteException(
          'Failed to remove tag $tagKey from $filePath '
          '(exit code ${result.exitCode}): ${stderr.trim()}',
        );
      }
    } on MetaflacWriteException {
      rethrow;
    } catch (e) {
      throw MetaflacWriteException('Failed to run metaflac: $e');
    }
  }
}

/// Derives the metaflac binary path from a flac binary override path.
///
/// If [flacBinaryOverride] is `/usr/bin/flac`, returns `/usr/bin/metaflac`.
/// Returns `'metaflac'` when the override is null or empty, or when there
/// is no directory separator in the path.
String deriveMetaflacPath(String? flacBinaryOverride) {
  if (flacBinaryOverride == null || flacBinaryOverride.isEmpty) {
    return 'metaflac';
  }
  final lastSlash = flacBinaryOverride.lastIndexOf('/');
  if (lastSlash < 0) return 'metaflac';
  return '${flacBinaryOverride.substring(0, lastSlash + 1)}metaflac';
}

/// Exception thrown when a metaflac tag-write operation fails.
class MetaflacWriteException implements Exception {
  const MetaflacWriteException(this.message);

  final String message;

  @override
  String toString() => 'MetaflacWriteException: $message';
}
