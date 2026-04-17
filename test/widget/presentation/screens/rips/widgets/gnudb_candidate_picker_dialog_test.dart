import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/presentation/screens/disambiguation/widgets/candidate_card.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/gnudb_candidate_picker_dialog.dart';

GnudbCandidate _candidate(int i) => GnudbCandidate(
      discId: 'abc0000$i',
      category: 'rock',
      dto: GnudbDiscDto(
        discId: 'abc0000$i',
        artist: 'Artist $i',
        albumTitle: 'Album $i',
        year: 2020 + i,
        trackTitles: const ['One', 'Two'],
      ),
    );

void main() {
  testWidgets('renders a CandidateCard per candidate', (tester) async {
    final candidates = [_candidate(1), _candidate(2), _candidate(3)];

    await tester.pumpWidget(MaterialApp(
      home: GnudbCandidatePickerDialog(candidates: candidates),
    ));

    expect(find.byType(CandidateCard), findsNWidgets(3));
    expect(find.text('Album 1'), findsOneWidget);
    expect(find.text('Artist 3'), findsOneWidget);
  });

  testWidgets('tapping a card pops the dialog with that candidate',
      (tester) async {
    final candidates = [_candidate(1), _candidate(2)];
    GnudbCandidate? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              selected = await showGnudbCandidatePicker(
                context: ctx,
                candidates: candidates,
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(GnudbCandidatePickerDialog), findsOneWidget);

    await tester.tap(find.text('Album 2'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.discId, 'abc00002');
  });

  testWidgets('Cancel dismisses without selecting', (tester) async {
    GnudbCandidate? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              selected = await showGnudbCandidatePicker(
                context: ctx,
                candidates: [_candidate(1)],
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
  });
}
