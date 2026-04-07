import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';

void main() {
  group('CoverOcrHelper.cleanTitle', () {
    test('collapses newlines into spaces', () {
      expect(CoverOcrHelper.cleanTitle('Dark Side\nof the Moon'),
          'Dark Side of the Moon');
    });

    test('collapses multiple whitespace', () {
      expect(CoverOcrHelper.cleanTitle('Dark   Side    of  the Moon'),
          'Dark Side of the Moon');
    });

    test('removes trademark symbols', () {
      expect(CoverOcrHelper.cleanTitle('Sony\u2122 Music\u00AE Copyright\u00A9'),
          'Sony Music Copyright');
    });

    test('trims whitespace', () {
      expect(CoverOcrHelper.cleanTitle('  Hello World  '), 'Hello World');
    });

    test('handles combined noise', () {
      expect(
        CoverOcrHelper.cleanTitle('  Dark  Side\n\nof\n  the   Moon\u2122  '),
        'Dark Side of the Moon',
      );
    });
  });
}
