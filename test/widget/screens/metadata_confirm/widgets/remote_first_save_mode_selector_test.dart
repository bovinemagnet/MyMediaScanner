import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart';

void main() {
  testWidgets('renders three radio options', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RemoteFirstSaveModeSelector(
          value: SaveMode.saveLocally,
          onChanged: (_) {},
        ),
      ),
    ));
    expect(find.text('Save locally'), findsOneWidget);
    expect(find.text('Save locally and sync to TMDB'), findsOneWidget);
    expect(find.text('TMDB only'), findsOneWidget);
  });

  testWidgets('tapping a radio invokes onChanged with the new value',
      (tester) async {
    SaveMode? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RemoteFirstSaveModeSelector(
          value: SaveMode.saveLocally,
          onChanged: (v) => captured = v,
        ),
      ),
    ));
    await tester.tap(find.text('TMDB only'));
    await tester.pumpAndSettle();
    expect(captured, SaveMode.tmdbOnly);
  });
}
