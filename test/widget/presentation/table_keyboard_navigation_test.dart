import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/table_keyboard_navigation.dart';

/// Helper that builds a [TableKeyboardNavigation] inside a [MaterialApp].
Widget _buildSubject({
  VoidCallback? onMoveUp,
  VoidCallback? onMoveDown,
  VoidCallback? onMoveToFirst,
  VoidCallback? onMoveToLast,
  VoidCallback? onSelect,
  VoidCallback? onDelete,
  VoidCallback? onClearSelection,
  bool autofocus = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TableKeyboardNavigation(
        onMoveUp: onMoveUp ?? () {},
        onMoveDown: onMoveDown ?? () {},
        onMoveToFirst: onMoveToFirst,
        onMoveToLast: onMoveToLast,
        onSelect: onSelect,
        onDelete: onDelete,
        onClearSelection: onClearSelection,
        autofocus: autofocus,
        child: const SizedBox(width: 200, height: 200),
      ),
    ),
  );
}

void main() {
  group('TableKeyboardNavigation', () {
    group('on desktop', () {
      testWidgets(
        'up arrow calls onMoveUp',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onMoveUp: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'down arrow calls onMoveDown',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onMoveDown: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'Home key calls onMoveToFirst',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onMoveToFirst: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.home);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'End key calls onMoveToLast',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onMoveToLast: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.end);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'Enter calls onSelect',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onSelect: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'Delete calls onDelete',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onDelete: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'Backspace calls onDelete',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onDelete: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'Escape calls onClearSelection',
        (tester) async {
          var called = false;
          await tester.pumpWidget(_buildSubject(
            onClearSelection: () => called = true,
          ));
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          expect(called, isTrue);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    group('on non-desktop', () {
      testWidgets(
        'renders child without keyboard handling',
        (tester) async {
          var moveUpCalled = false;
          await tester.pumpWidget(_buildSubject(
            onMoveUp: () => moveUpCalled = true,
          ));
          await tester.pumpAndSettle();

          // The child should be rendered
          expect(find.byType(SizedBox), findsWidgets);

          // Keyboard events should not trigger callbacks on mobile
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          expect(moveUpCalled, isFalse);
        },
        variant: TargetPlatformVariant.mobile(),
      );

      testWidgets(
        'child is rendered on mobile',
        (tester) async {
          await tester.pumpWidget(_buildSubject());
          await tester.pumpAndSettle();

          // The child should still be rendered on mobile
          expect(find.byType(SizedBox), findsWidgets);
        },
        variant: TargetPlatformVariant.mobile(),
      );
    });
  });
}
