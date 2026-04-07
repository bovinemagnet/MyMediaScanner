import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';

void main() {
  group('CoverOcrHelper.cleanTitle (used by TesseractOcrService)', () {
    test('collapses newlines to spaces', () {
      expect(CoverOcrHelper.cleanTitle('Hello\nWorld'), 'Hello World');
    });

    test('collapses multiple whitespace', () {
      expect(CoverOcrHelper.cleanTitle('Hello   World'), 'Hello World');
    });

    test('removes trademark symbols', () {
      expect(CoverOcrHelper.cleanTitle('Title™ ®©'), 'Title');
    });

    test('trims leading and trailing whitespace', () {
      expect(CoverOcrHelper.cleanTitle('  Hello  '), 'Hello');
    });

    test('handles mixed noise', () {
      expect(
        CoverOcrHelper.cleanTitle('  The\nMatrix™  ®  '),
        'The Matrix',
      );
    });
  });
}
