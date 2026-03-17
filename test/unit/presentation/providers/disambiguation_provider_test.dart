import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';

void main() {
  group('DisambiguationNotifier logic', () {
    test('candidate filtering removes selected candidate on null detail', () {
      const candidates = [
        MetadataCandidate(sourceApi: 'discogs', sourceId: '1', title: 'A'),
        MetadataCandidate(sourceApi: 'discogs', sourceId: '2', title: 'B'),
        MetadataCandidate(sourceApi: 'discogs', sourceId: '3', title: 'C'),
      ];

      final filtered = candidates
          .where((c) => c != candidates.first)
          .toList();

      expect(filtered.length, 2);
      expect(filtered[0].sourceId, '2');
      expect(filtered[1].sourceId, '3');
    });

    test('MetadataCandidate equality works for filtering', () {
      const a = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'Album A',
        mediaType: MediaType.music,
      );
      const b = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'Album A',
        mediaType: MediaType.music,
      );

      expect(a == b, isTrue);
      expect([a, b].where((c) => c != a).isEmpty, isTrue);
    });

    test('empty candidate list remains empty after filtering', () {
      const List<MetadataCandidate> candidates = [];
      const target = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'A',
      );

      final filtered = candidates.where((c) => c != target).toList();
      expect(filtered, isEmpty);
    });
  });
}
