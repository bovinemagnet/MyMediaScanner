// Tests for MetaflacWriter.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:dart_metaflac/dart_metaflac.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';

const _fixturePath = 'test/fixtures/with_tags.flac';

void main() {
  group('MetaflacWriter', () {
    late Directory tempDir;
    late String workingFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('metaflac_writer_test_');
      workingFile = '${tempDir.path}/with_tags.flac';
      await File(_fixturePath).copy(workingFile);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    List<String> readTag(String key) {
      final bytes = File(workingFile).readAsBytesSync();
      final doc = FlacMetadataDocument.readFromBytes(bytes);
      return doc.vorbisComment?.comments.valuesOf(key) ?? const [];
    }

    test('setTags writes and replaces a Vorbis comment', () async {
      const writer = MetaflacWriter();

      await writer.setTags(workingFile, {
        'ARTIST': 'New Artist',
        'ALBUM': 'New Album',
      });

      expect(readTag('ARTIST'), equals(['New Artist']));
      expect(readTag('ALBUM'), equals(['New Album']));
    });

    test('setTags with empty map is a no-op', () async {
      const writer = MetaflacWriter();
      final before = File(workingFile).readAsBytesSync();

      await writer.setTags(workingFile, {});

      final after = File(workingFile).readAsBytesSync();
      expect(after, equals(before));
    });

    test('removeTag drops the tag', () async {
      const writer = MetaflacWriter();
      expect(readTag('ARTIST'), isNotEmpty);

      await writer.removeTag(workingFile, 'ARTIST');

      expect(readTag('ARTIST'), isEmpty);
    });

    test('setTags throws MetaflacWriteException for a missing file', () async {
      const writer = MetaflacWriter();
      expect(
        () => writer.setTags('/nonexistent/path/file.flac', {'TITLE': 'x'}),
        throwsA(isA<MetaflacWriteException>()),
      );
    });

    test('removeTag throws MetaflacWriteException for a missing file',
        () async {
      const writer = MetaflacWriter();
      expect(
        () => writer.removeTag('/nonexistent/path/file.flac', 'TITLE'),
        throwsA(isA<MetaflacWriteException>()),
      );
    });
  });
}
