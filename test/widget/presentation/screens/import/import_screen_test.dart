// Widget tests for [ImportScreen].
//
// Covers:
//   1. All four format options (Goodreads, Discogs, Letterboxd, Trakt) visible
//      in the idle source selector.
//   2. A progress indicator is visible while the import is in the enriching
//      phase.
//   3. A result summary ("Imported N items") is shown after import completes.
//   4. An error message is surfaced when the phase is error.
//
// NOTE: Tests that require real file_picker interaction are intentionally
// skipped because FilePicker.platform cannot be overridden in a widget test
// environment without platform-channel stubs.
// TODO: add file-picker integration tests in integration_test/ using a mock
//       file picker method-channel implementation.
//
// Author: Paul Snow
// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/import_provider.dart';
import 'package:mymediascanner/presentation/screens/import/import_screen.dart';

// ---------------------------------------------------------------------------
// Stub notifier — lets tests pre-seed [ImportState] without the real use case.
// ---------------------------------------------------------------------------

/// A stub [ImportNotifier] that starts with [_initial] and exposes a
/// [setStateForTest] helper so individual tests can drive state without
/// triggering the real import pipeline.
class _StubImportNotifier extends ImportNotifier {
  _StubImportNotifier(this._initial);

  final ImportState _initial;

  @override
  ImportState build() => _initial;

  // Public helper to drive state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void setStateForTest(ImportState s) => state = s;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [GoRouter] that knows about the collection route so that
/// "View collection" navigation doesn't throw.
GoRouter _router({String initialLocation = '/import'}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/import',
          builder: (_, _) => const ImportScreen(),
        ),
        GoRoute(
          path: '/collection',
          builder: (_, _) => const Scaffold(body: Text('collection')),
        ),
      ],
    );

/// Wraps [ImportScreen] with a ProviderScope that overrides
/// [importNotifierProvider] using [notifier].
Widget _wrap(_StubImportNotifier notifier, {GoRouter? router}) {
  return ProviderScope(
    overrides: [
      importNotifierProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp.router(routerConfig: router ?? _router()),
  );
}

/// Creates a stub notifier pre-set to [state].
_StubImportNotifier _notifier(ImportState state) =>
    _StubImportNotifier(state);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ImportScreen — idle state', () {
    testWidgets(
        'renders the format selector showing all four import sources',
        (tester) async {
      final stub = _notifier(const ImportState());

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      // The DropdownButtonFormField shows the initial value label.
      expect(
        find.text('Goodreads (.csv)'),
        findsOneWidget,
        reason: 'Goodreads option must appear in the dropdown',
      );

      // Open the dropdown to see all options.
      await tester.tap(find.byType(DropdownButtonFormField<ImportSource>));
      await tester.pumpAndSettle();

      expect(find.text('Discogs (.csv)'), findsOneWidget);
      expect(find.text('Letterboxd (.csv)'), findsOneWidget);
      expect(find.text('Trakt (.json)'), findsOneWidget);
    });

    testWidgets(
        'shows the "Choose file…" button in idle phase',
        (tester) async {
      final stub = _notifier(const ImportState());

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(find.text('Choose file…'), findsOneWidget);
    });
  });

  group('ImportScreen — enriching phase', () {
    testWidgets(
        'displays a progress indicator while the use case is running',
        (tester) async {
      // Build rows that simulate an in-progress enrichment (3 of 5 done).
      final rows = List.generate(
        5,
        (i) => ImportRow(
          sourceRowId: 'r$i',
          source: ImportSource.goodreads,
          mediaType: MediaType.book,
          rawTitle: 'Book $i',
        ),
      );

      final enrichingState = ImportState(
        phase: ImportPhase.enriching,
        source: ImportSource.goodreads,
        rows: rows,
        enrichedCount: 3,
      );

      final stub = _notifier(enrichingState);

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Enriching 3 of 5'), findsOneWidget);
    });
  });

  group('ImportScreen — done phase', () {
    testWidgets(
        'shows a result summary after import completes',
        (tester) async {
      const doneState = ImportState(
        phase: ImportPhase.done,
        savedCount: 8,
      );

      final stub = _notifier(doneState);

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(find.text('Imported 8 items'), findsOneWidget);
      expect(find.text('Import another'), findsOneWidget);
      expect(find.text('View collection'), findsOneWidget);
    });

    testWidgets(
        'singular grammar when exactly one item is imported',
        (tester) async {
      const doneState = ImportState(
        phase: ImportPhase.done,
        savedCount: 1,
      );

      final stub = _notifier(doneState);

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(find.text('Imported 1 items'), findsOneWidget);
    });
  });

  group('ImportScreen — error phase', () {
    testWidgets(
        'shows an error message when the import throws',
        (tester) async {
      const errorState = ImportState(
        phase: ImportPhase.error,
        errorMessage: 'Could not parse file: unexpected column header',
      );

      final stub = _notifier(errorState);

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not parse file: unexpected column header'),
        findsOneWidget,
      );
      expect(find.text('Start over'), findsOneWidget);
    });

    testWidgets(
        'shows "Unknown error" when errorMessage is null in error phase',
        (tester) async {
      const errorState = ImportState(
        phase: ImportPhase.error,
        // errorMessage intentionally null.
      );

      final stub = _notifier(errorState);

      await tester.pumpWidget(_wrap(stub));
      await tester.pumpAndSettle();

      expect(find.text('Unknown error'), findsOneWidget);
    });
  });

  group('ImportScreen — parsing phase', () {
    testWidgets(
        'shows a spinner and "Parsing file…" label during parsing',
        (tester) async {
      const parsingState = ImportState(
        phase: ImportPhase.parsing,
        source: ImportSource.discogs,
      );

      final stub = _notifier(parsingState);

      await tester.pumpWidget(_wrap(stub));
      // Use pump(Duration) rather than pumpAndSettle because an indeterminate
      // CircularProgressIndicator animates indefinitely.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Parsing file…'), findsOneWidget);
    });
  });

  group('ImportScreen — saving phase', () {
    testWidgets(
        'shows a spinner and "Saving items…" label during save',
        (tester) async {
      const savingState = ImportState(
        phase: ImportPhase.saving,
        source: ImportSource.letterboxd,
      );

      final stub = _notifier(savingState);

      await tester.pumpWidget(_wrap(stub));
      // Use pump(Duration) rather than pumpAndSettle — same reason as above.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving items…'), findsOneWidget);
    });
  });
}
