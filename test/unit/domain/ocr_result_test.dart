import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';

void main() {
  group('OcrTextBlock', () {
    test('creates instance with required fields', () {
      const block = OcrTextBlock(
        text: 'Dark Side of the Moon',
        confidence: 0.95,
        area: 12000.0,
      );

      expect(block.text, 'Dark Side of the Moon');
      expect(block.confidence, 0.95);
      expect(block.area, 12000.0);
    });
  });

  group('OcrResult', () {
    test('creates instance with blocks', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'Dark Side of the Moon',
              confidence: 0.95,
              area: 12000.0),
          OcrTextBlock(
              text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
        ],
      );

      expect(result.blocks.length, 2);
    });

    test('primaryText returns largest block text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
          OcrTextBlock(
              text: 'Dark Side of the Moon',
              confidence: 0.95,
              area: 12000.0),
        ],
      );

      expect(result.primaryText, 'Dark Side of the Moon');
    });

    test('secondaryText returns second-largest block text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'Dark Side of the Moon',
              confidence: 0.95,
              area: 12000.0),
          OcrTextBlock(
              text: 'Pink Floyd', confidence: 0.88, area: 6000.0),
          OcrTextBlock(text: '1973', confidence: 0.70, area: 2000.0),
        ],
      );

      expect(result.secondaryText, 'Pink Floyd');
    });

    test('overallConfidence averages block confidences', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'Title', confidence: 0.90, area: 10000.0),
          OcrTextBlock(
              text: 'Artist', confidence: 0.80, area: 5000.0),
        ],
      );

      expect(result.overallConfidence, closeTo(0.85, 0.001));
    });

    test('isEmpty returns true when no blocks', () {
      const result = OcrResult(blocks: []);
      expect(result.isEmpty, isTrue);
      expect(result.primaryText, isNull);
      expect(result.secondaryText, isNull);
      expect(result.overallConfidence, 0.0);
    });

    test('inferredTitle returns primary text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'The Matrix', confidence: 0.92, area: 15000.0),
          OcrTextBlock(
              text: 'Keanu Reeves', confidence: 0.85, area: 5000.0),
        ],
      );

      expect(result.inferredTitle, 'The Matrix');
    });

    test('inferredArtist returns secondary text', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'The Matrix', confidence: 0.92, area: 15000.0),
          OcrTextBlock(
              text: 'Keanu Reeves', confidence: 0.85, area: 5000.0),
        ],
      );

      expect(result.inferredArtist, 'Keanu Reeves');
    });

    test('highConfidenceBlocks filters by threshold', () {
      const result = OcrResult(
        blocks: [
          OcrTextBlock(
              text: 'Clear', confidence: 0.95, area: 10000.0),
          OcrTextBlock(
              text: 'Fuzzy', confidence: 0.40, area: 3000.0),
          OcrTextBlock(
              text: 'Decent', confidence: 0.75, area: 5000.0),
        ],
      );

      final high = result.highConfidenceBlocks(threshold: 0.70);
      expect(high.length, 2);
      expect(high.map((b) => b.text), containsAll(['Clear', 'Decent']));
    });
  });
}
