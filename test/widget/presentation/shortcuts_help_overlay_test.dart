import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/shortcuts_help_overlay.dart';

/// Pumps a [ShortcutsHelpOverlay] inside an [AlertDialog]-compatible host.
///
/// The overlay is itself an [AlertDialog], so it is shown via [showDialog]
/// to give it the [Navigator] context it needs for the Close button.
Future<void> _pumpOverlay(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const ShortcutsHelpOverlay(),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );

  // Open the dialog.
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('ShortcutsHelpOverlay', () {
    // ------------------------------------------------------------------
    // Title
    // ------------------------------------------------------------------

    testWidgets('renders_keyboardShortcutsTitle', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Keyboard Shortcuts'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Section headers
    // ------------------------------------------------------------------

    testWidgets('renders_globalSectionHeader', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Global'), findsOneWidget);
    });

    testWidgets('renders_collectionSectionHeader', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Collection'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Shortcut descriptions — global section
    // ------------------------------------------------------------------

    testWidgets('renders_openScanScreenDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Open Scan screen'), findsOneWidget);
    });

    testWidgets('renders_focusSearchBarDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Focus search bar'), findsOneWidget);
    });

    testWidgets('renders_openSettingsDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('renders_showThisHelpDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Show this help'), findsOneWidget);
    });

    testWidgets('renders_closePanelClearInputDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Close panel / clear input'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Shortcut descriptions — collection section
    // ------------------------------------------------------------------

    testWidgets('renders_navigateItemsDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Navigate items'), findsOneWidget);
    });

    testWidgets('renders_openSelectedItemDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Open selected item'), findsOneWidget);
    });

    testWidgets('renders_deleteSelectedItemDescription', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Delete selected item'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Shortcut key labels
    // ------------------------------------------------------------------

    testWidgets('renders_ctrlNKeyLabel', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Ctrl+N'), findsOneWidget);
    });

    testWidgets('renders_f1KeyLabel', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('F1'), findsOneWidget);
    });

    testWidgets('renders_escapeKeyLabel', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Escape'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Close button
    // ------------------------------------------------------------------

    testWidgets('renders_closeButton', (tester) async {
      await _pumpOverlay(tester);

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('closeButton_dismissesDialog', (tester) async {
      await _pumpOverlay(tester);

      // Dialog is visible before tapping Close.
      expect(find.byType(ShortcutsHelpOverlay), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog has been removed from the tree.
      expect(find.byType(ShortcutsHelpOverlay), findsNothing);
      expect(find.text('Keyboard Shortcuts'), findsNothing);
    });
  });
}
