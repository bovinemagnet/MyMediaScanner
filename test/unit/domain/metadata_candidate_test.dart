import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';

void main() {
  group('MetadataCandidate', () {
    test('creates instance with required fields', () {
      const candidate = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '12345',
        title: 'Dark Side of the Moon',
      );

      expect(candidate.sourceApi, 'discogs');
      expect(candidate.sourceId, '12345');
      expect(candidate.title, 'Dark Side of the Moon');
      expect(candidate.subtitle, isNull);
      expect(candidate.coverUrl, isNull);
      expect(candidate.year, isNull);
      expect(candidate.format, isNull);
      expect(candidate.mediaType, isNull);
    });

    test('creates instance with all fields', () {
      const candidate = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '12345',
        title: 'Dark Side of the Moon',
        subtitle: 'Pink Floyd',
        coverUrl: 'https://example.com/cover.jpg',
        year: 1973,
        format: 'CD',
        mediaType: MediaType.music,
      );

      expect(candidate.subtitle, 'Pink Floyd');
      expect(candidate.coverUrl, 'https://example.com/cover.jpg');
      expect(candidate.year, 1973);
      expect(candidate.format, 'CD');
      expect(candidate.mediaType, MediaType.music);
    });

    test('supports equality', () {
      const a = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '12345',
        title: 'Dark Side of the Moon',
      );
      const b = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '12345',
        title: 'Dark Side of the Moon',
      );

      expect(a, equals(b));
    });
  });
}
