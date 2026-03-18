import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';

void main() {
  group('CoverOcrHelper._cleanTitle', () {
    test('collapses newlines to spaces', () {
      expect(
        CoverOcrHelper.cleanTitle('Harry\nPotter'),
        'Harry Potter',
      );
    });

    test('collapses multiple spaces', () {
      expect(
        CoverOcrHelper.cleanTitle('The   Lord   of   the   Rings'),
        'The Lord of the Rings',
      );
    });

    test('removes trademark symbols', () {
      expect(
        CoverOcrHelper.cleanTitle('Pokémon™ Violet®'),
        'Pokémon Violet',
      );
    });

    test('trims whitespace', () {
      expect(
        CoverOcrHelper.cleanTitle('  Hello World  '),
        'Hello World',
      );
    });

    test('handles mixed noise', () {
      expect(
        CoverOcrHelper.cleanTitle('  Harry\nPotter™  and\n the  Philosopher\'s  Stone®  '),
        'Harry Potter and the Philosopher\'s Stone',
      );
    });

    test('returns empty for whitespace-only input', () {
      expect(CoverOcrHelper.cleanTitle('   '), '');
    });
  });
}
