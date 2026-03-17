import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/collection_view_mode_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/view_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [ViewModeToggle] in the minimum required widget tree:
/// a [ProviderScope] and a [MaterialApp] with a [Scaffold].
Widget _buildSubject() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: ViewModeToggle()),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Provide an empty in-memory SharedPreferences backing store so that
    // SharedPreferences.getInstance() never touches the real file system.
    SharedPreferences.setMockInitialValues({});
  });

  group('ViewModeToggle', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------

    testWidgets('renders_segmentedButton', (tester) async {
      await tester.pumpWidget(_buildSubject());

      expect(find.byType(SegmentedButton<CollectionViewMode>), findsOneWidget);
    });

    testWidgets('renders_gridSegment_withGridViewIcon', (tester) async {
      await tester.pumpWidget(_buildSubject());

      // Locate every Icon inside the SegmentedButton and verify grid_view
      // is present among them.
      final icons = tester
          .widgetList<Icon>(find.descendant(
            of: find.byType(SegmentedButton<CollectionViewMode>),
            matching: find.byType(Icon),
          ))
          .map((icon) => icon.icon)
          .toList();

      expect(icons, contains(Icons.grid_view));
    });

    testWidgets('renders_tableSegment_withTableRowsIcon', (tester) async {
      await tester.pumpWidget(_buildSubject());

      final icons = tester
          .widgetList<Icon>(find.descendant(
            of: find.byType(SegmentedButton<CollectionViewMode>),
            matching: find.byType(Icon),
          ))
          .map((icon) => icon.icon)
          .toList();

      expect(icons, contains(Icons.table_rows));
    });

    testWidgets('renders_twoSegments', (tester) async {
      await tester.pumpWidget(_buildSubject());

      // Each segment renders as a child of the SegmentedButton; the internal
      // implementation places one Icon per segment.
      final icons = tester
          .widgetList<Icon>(find.descendant(
            of: find.byType(SegmentedButton<CollectionViewMode>),
            matching: find.byType(Icon),
          ))
          .toList();

      // There must be exactly two segment icons (grid and table).
      expect(icons.length, 2);
    });

    // ------------------------------------------------------------------
    // Initial selection
    // ------------------------------------------------------------------

    testWidgets('initialState_gridSegmentIsSelected', (tester) async {
      await tester.pumpWidget(_buildSubject());

      final button = tester.widget<SegmentedButton<CollectionViewMode>>(
        find.byType(SegmentedButton<CollectionViewMode>),
      );

      expect(button.selected, {CollectionViewMode.grid});
    });

    // ------------------------------------------------------------------
    // Interaction — tapping the table segment switches mode
    // ------------------------------------------------------------------

    testWidgets('tapTableSegment_switchesModeToTable', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return const ViewModeToggle();
                },
              ),
            ),
          ),
        ),
      );

      // Confirm starting state is grid.
      expect(capturedRef.read(collectionViewModeProvider), CollectionViewMode.grid);

      // Tap the table_rows icon to select the table segment.
      await tester.tap(find.byIcon(Icons.table_rows));
      await tester.pumpAndSettle();

      expect(capturedRef.read(collectionViewModeProvider), CollectionViewMode.table);
    });

    testWidgets('tapTableSegment_tableSegmentBecomesSelected', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.tap(find.byIcon(Icons.table_rows));
      await tester.pumpAndSettle();

      final button = tester.widget<SegmentedButton<CollectionViewMode>>(
        find.byType(SegmentedButton<CollectionViewMode>),
      );

      expect(button.selected, {CollectionViewMode.table});
    });

    testWidgets('tapGridSegment_afterTable_switchesModeBackToGrid', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return const ViewModeToggle();
                },
              ),
            ),
          ),
        ),
      );

      // Switch to table first, then back to grid.
      await tester.tap(find.byIcon(Icons.table_rows));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      expect(capturedRef.read(collectionViewModeProvider), CollectionViewMode.grid);
    });
  });
}
