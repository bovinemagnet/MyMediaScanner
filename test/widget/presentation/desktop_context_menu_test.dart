import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';

/// Builds a minimal app that hosts a [DesktopContextMenu] inside a [Scaffold]
/// so that [Overlay] (required by [showMenu]) is available.
Widget _buildSubject({
  required List<ContextMenuAction> actions,
  Widget child = const Text('child'),
}) {
  return MaterialApp(
    home: Scaffold(
      body: DesktopContextMenu(
        actions: actions,
        child: child,
      ),
    ),
  );
}

void main() {
  group('DesktopContextMenu', () {
    // ------------------------------------------------------------------ //
    // Desktop platforms — secondary tap shows popup menu                  //
    //                                                                      //
    // TargetPlatformVariant manages setUp/tearDown of                      //
    // debugDefaultTargetPlatformOverride so the Flutter test binding's     //
    // invariant check sees a clean state at the end of each test.          //
    // ------------------------------------------------------------------ //

    group('on desktop platform', () {
      testWidgets(
        'secondary tap shows popup menu with all action labels',
        (tester) async {
          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () {},
            ),
            ContextMenuAction(
              label: 'Delete',
              icon: Icons.delete_outline,
              onTap: () {},
            ),
            ContextMenuAction(
              label: 'Add to shelf',
              icon: Icons.shelves,
              onTap: () {},
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          // Perform a secondary (right-click) tap on the child widget.
          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          // All three action labels must appear in the popup.
          expect(find.text('Edit'), findsOneWidget);
          expect(find.text('Delete'), findsOneWidget);
          expect(find.text('Add to shelf'), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'secondary tap renders action icons in popup menu',
        (tester) async {
          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () {},
            ),
            ContextMenuAction(
              label: 'Rename',
              icon: Icons.drive_file_rename_outline,
              onTap: () {},
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
          expect(find.byIcon(Icons.drive_file_rename_outline), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'tapping a menu item calls the corresponding onTap callback',
        (tester) async {
          var editTapped = false;
          var deleteTapped = false;

          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () => editTapped = true,
            ),
            ContextMenuAction(
              label: 'Delete',
              icon: Icons.delete_outline,
              onTap: () => deleteTapped = true,
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          // Open the context menu.
          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          // Tap the 'Edit' item.
          await tester.tap(find.text('Edit'));
          await tester.pumpAndSettle();

          expect(editTapped, isTrue);
          expect(deleteTapped, isFalse);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'tapping the second menu item calls only its onTap callback',
        (tester) async {
          var firstTapped = false;
          var secondTapped = false;

          final actions = [
            ContextMenuAction(
              label: 'Action One',
              icon: Icons.one_k,
              onTap: () => firstTapped = true,
            ),
            ContextMenuAction(
              label: 'Action Two',
              icon: Icons.two_k,
              onTap: () => secondTapped = true,
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Action Two'));
          await tester.pumpAndSettle();

          expect(firstTapped, isFalse);
          expect(secondTapped, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'wraps child in GestureDetector when actions are non-empty',
        (tester) async {
          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () {},
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          // A GestureDetector must be present in the tree.
          expect(find.byType(GestureDetector), findsWidgets);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'renders child directly without GestureDetector when actions are empty',
        (tester) async {
          await tester.pumpWidget(_buildSubject(actions: const []));

          // On desktop with an empty actions list the widget returns child
          // without wrapping it in a GestureDetector.
          expect(find.byType(GestureDetector), findsNothing);
          expect(find.text('child'), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'secondary tap on empty actions does not show a popup menu',
        (tester) async {
          await tester.pumpWidget(_buildSubject(actions: const []));

          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          // No PopupMenuItem should appear.
          expect(find.byType(PopupMenuItem<void>), findsNothing);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------ //
    // Non-desktop platforms — child renders directly, no GestureDetector  //
    // ------------------------------------------------------------------ //

    group('on non-desktop platform', () {
      testWidgets(
        'renders child directly without GestureDetector on mobile',
        (tester) async {
          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () {},
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          // Even with non-empty actions, mobile platforms skip the GestureDetector.
          expect(find.byType(GestureDetector), findsNothing);
          expect(find.text('child'), findsOneWidget);
        },
        variant: TargetPlatformVariant.mobile(),
      );

      testWidgets(
        'secondary tap on mobile does not open a popup menu',
        (tester) async {
          var tapped = false;

          final actions = [
            ContextMenuAction(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onTap: () => tapped = true,
            ),
          ];

          await tester.pumpWidget(_buildSubject(actions: actions));

          await tester.tap(find.text('child'), buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          // The callback must not have been invoked.
          expect(tapped, isFalse);
          expect(find.byType(PopupMenuItem<void>), findsNothing);
        },
        variant: TargetPlatformVariant.mobile(),
      );
    });
  });
}
