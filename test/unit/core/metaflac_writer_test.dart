// Tests for MetaflacWriter.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';

void main() {
  group('deriveMetaflacPath', () {
    test('returns metaflac when null', () {
      expect(deriveMetaflacPath(null), equals('metaflac'));
    });

    test('returns metaflac when empty string', () {
      expect(deriveMetaflacPath(''), equals('metaflac'));
    });

    test('derives from /usr/bin/flac', () {
      expect(deriveMetaflacPath('/usr/bin/flac'), equals('/usr/bin/metaflac'));
    });

    test('derives from /opt/homebrew/bin/flac', () {
      expect(
        deriveMetaflacPath('/opt/homebrew/bin/flac'),
        equals('/opt/homebrew/bin/metaflac'),
      );
    });
  });

  group('MetaflacWriter', () {
    test('binaryPath getter returns configured path', () {
      const customPath = '/usr/local/bin/metaflac';
      final writer = MetaflacWriter(binaryPath: customPath);
      expect(writer.binaryPath, equals(customPath));
    });

    test('isAvailable returns false for nonexistent binary', () async {
      final writer = MetaflacWriter(binaryPath: '/nonexistent/metaflac');
      expect(await writer.isAvailable(), isFalse);
    });

    test('setTags throws MetaflacWriteException for nonexistent binary',
        () async {
      final writer = MetaflacWriter(binaryPath: '/nonexistent/metaflac');
      expect(
        () => writer.setTags('/tmp/test.flac', {'TITLE': 'Test'}),
        throwsA(isA<MetaflacWriteException>()),
      );
    });

    test('removeTag throws MetaflacWriteException for nonexistent binary',
        () async {
      final writer = MetaflacWriter(binaryPath: '/nonexistent/metaflac');
      expect(
        () => writer.removeTag('/tmp/test.flac', 'TITLE'),
        throwsA(isA<MetaflacWriteException>()),
      );
    });
  });
}
