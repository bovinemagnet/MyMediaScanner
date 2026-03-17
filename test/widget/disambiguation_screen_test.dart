import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/presentation/screens/disambiguation/widgets/candidate_card.dart';

void main() {
  group('CandidateCard', () {
    testWidgets('renders title, subtitle, year, and source', (tester) async {
      const candidate = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '12345',
        title: 'Dark Side of the Moon',
        subtitle: 'Pink Floyd',
        year: 1973,
        mediaType: MediaType.music,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidateCard(
              candidate: candidate,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dark Side of the Moon'), findsOneWidget);
      expect(find.text('Pink Floyd'), findsOneWidget);
      expect(find.text('1973'), findsOneWidget);
      expect(find.text('discogs'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      const candidate = MetadataCandidate(
        sourceApi: 'tmdb',
        sourceId: '550',
        title: 'Fight Club',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidateCard(
              candidate: candidate,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fight Club'));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder when coverUrl is null', (tester) async {
      const candidate = MetadataCandidate(
        sourceApi: 'discogs',
        sourceId: '1',
        title: 'No Cover Album',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidateCard(
              candidate: candidate,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.album), findsOneWidget);
    });
  });
}
