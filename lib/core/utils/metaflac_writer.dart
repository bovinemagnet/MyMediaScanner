/// Writes Vorbis Comment tags to FLAC files using the pure-Dart
/// `dart_metaflac` package.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:dart_metaflac/dart_metaflac.dart';
import 'package:dart_metaflac/io.dart';

/// Writes Vorbis Comment tags to FLAC files via `FlacFileEditor`.
class MetaflacWriter {
  /// Create a writer.
  const MetaflacWriter();

  /// Write [tags] to the FLAC file at [filePath].
  ///
  /// Each entry in [tags] replaces any existing values for that key.
  /// Writes are atomic (temp file + rename) by default.
  ///
  /// Throws [MetaflacWriteException] if the file cannot be read, parsed,
  /// or written.
  Future<void> setTags(String filePath, Map<String, String> tags) async {
    if (tags.isEmpty) return;

    final mutations = <MetadataMutation>[
      for (final entry in tags.entries) SetTag(entry.key, [entry.value]),
    ];

    try {
      await FlacFileEditor.updateFile(filePath, mutations: mutations);
    } catch (e) {
      throw MetaflacWriteException(
        'Failed to set tags on $filePath: $e',
      );
    }
  }

  /// Remove the tag identified by [tagKey] from the FLAC file at [filePath].
  ///
  /// Throws [MetaflacWriteException] if the file cannot be read, parsed,
  /// or written.
  Future<void> removeTag(String filePath, String tagKey) async {
    try {
      await FlacFileEditor.updateFile(
        filePath,
        mutations: [RemoveTag(tagKey)],
      );
    } catch (e) {
      throw MetaflacWriteException(
        'Failed to remove tag $tagKey from $filePath: $e',
      );
    }
  }
}

/// Exception thrown when a FLAC tag-write operation fails.
class MetaflacWriteException implements Exception {
  const MetaflacWriteException(this.message);

  final String message;

  @override
  String toString() => 'MetaflacWriteException: $message';
}
