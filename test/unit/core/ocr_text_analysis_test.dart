import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/ocr_text_analysis.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';

void main() {
  group('OcrTextAnalysisUtils.extractYear', () {
    test('extracts 4-digit year from text', () {
      expect(OcrTextAnalysisUtils.extractYear('Released 2011'), 2011);
    });

    test('returns first year match', () {
      expect(OcrTextAnalysisUtils.extractYear('1973 Remastered 2011'), 1973);
    });

    test('returns null when no year present', () {
      expect(OcrTextAnalysisUtils.extractYear('Dark Side of the Moon'), isNull);
    });

    test('does not match numbers outside 1900-2099', () {
      expect(OcrTextAnalysisUtils.extractYear('Track 1234'), isNull);
    });
  });

  group('OcrTextAnalysisUtils.removeNoiseWords', () {
    test('removes single noise words', () {
      expect(
        OcrTextAnalysisUtils.removeNoiseWords(
            'Dark Side of the Moon Remastered CD'),
        'Dark Side of the Moon',
      );
    });

    test('removes multi-word noise phrases', () {
      expect(
        OcrTextAnalysisUtils.removeNoiseWords(
            'The Wall Special Edition'),
        'The Wall',
      );
    });

    test('is case-insensitive', () {
      expect(
        OcrTextAnalysisUtils.removeNoiseWords(
            'The Matrix BLU-RAY'),
        'The Matrix',
      );
    });

    test('handles empty parentheses after removal', () {
      expect(
        OcrTextAnalysisUtils.removeNoiseWords(
            'The Matrix (Blu-ray)'),
        'The Matrix',
      );
    });
  });

  group('OcrTextAnalysisUtils.splitTitleArtist', () {
    test('splits "Artist - Title" pattern', () {
      final result =
          OcrTextAnalysisUtils.splitTitleArtist('Pink Floyd - The Wall');
      expect(result, isNotNull);
      expect(result!.title, 'The Wall');
      expect(result.artist, 'Pink Floyd');
    });

    test('splits "Title by Artist" pattern', () {
      final result =
          OcrTextAnalysisUtils.splitTitleArtist('Great Expectations by Charles Dickens');
      expect(result, isNotNull);
      expect(result!.title, 'Great Expectations');
      expect(result.artist, 'Charles Dickens');
    });

    test('returns null for plain text', () {
      expect(
        OcrTextAnalysisUtils.splitTitleArtist('The Shawshank Redemption'),
        isNull,
      );
    });
  });

  group('OcrTextAnalysisUtils.inferMediaType', () {
    test('detects film from Blu-ray', () {
      expect(
        OcrTextAnalysisUtils.inferMediaType('The Shawshank Redemption Blu-ray'),
        MediaType.film,
      );
    });

    test('detects music from CD', () {
      expect(
        OcrTextAnalysisUtils.inferMediaType(
            'Dark Side of the Moon CD'),
        MediaType.music,
      );
    });

    test('detects book from ISBN pattern', () {
      expect(
        OcrTextAnalysisUtils.inferMediaType('978-0-14-103614-4'),
        MediaType.book,
      );
    });

    test('detects book from paperback', () {
      expect(
        OcrTextAnalysisUtils.inferMediaType('Paperback Edition'),
        MediaType.book,
      );
    });

    test('returns null for ambiguous text', () {
      expect(
        OcrTextAnalysisUtils.inferMediaType('The Matrix'),
        isNull,
      );
    });
  });

  group('OcrTextAnalysisUtils.analyse', () {
    test('extracts title, year, and type from music cover', () {
      const result = OcrResult(blocks: [
        OcrTextBlock(
            text: 'Dark Side of the Moon (Remastered 2011) CD',
            confidence: 0.90,
            area: 12000.0),
        OcrTextBlock(
            text: 'Pink Floyd', confidence: 0.85, area: 6000.0),
      ]);

      final analysis = OcrTextAnalysisUtils.analyse(result);
      expect(analysis.cleanedTitle, 'Dark Side of the Moon');
      expect(analysis.cleanedArtist, 'Pink Floyd');
      expect(analysis.year, 2011);
      expect(analysis.inferredMediaType, MediaType.music);
    });

    test('extracts title from film cover', () {
      const result = OcrResult(blocks: [
        OcrTextBlock(
            text: 'The Shawshank Redemption Blu-ray',
            confidence: 0.92,
            area: 15000.0),
      ]);

      final analysis = OcrTextAnalysisUtils.analyse(result);
      expect(analysis.cleanedTitle, 'The Shawshank Redemption');
      expect(analysis.inferredMediaType, MediaType.film);
    });

    test('handles artist-title split in primary block', () {
      const result = OcrResult(blocks: [
        OcrTextBlock(
            text: 'Pink Floyd - The Wall',
            confidence: 0.88,
            area: 10000.0),
      ]);

      final analysis = OcrTextAnalysisUtils.analyse(result);
      expect(analysis.cleanedTitle, 'The Wall');
      expect(analysis.cleanedArtist, 'Pink Floyd');
    });

    test('returns empty analysis for empty result', () {
      const result = OcrResult(blocks: []);
      final analysis = OcrTextAnalysisUtils.analyse(result);
      expect(analysis.cleanedTitle, isNull);
      expect(analysis.cleanedArtist, isNull);
      expect(analysis.year, isNull);
      expect(analysis.confidence, 0.0);
    });
  });
}
