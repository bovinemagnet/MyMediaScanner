import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a [MasterDetailLayout] inside a [ProviderScope] + [MaterialApp]
/// whose viewport is constrained to [screenWidth] x 800 via [MediaQuery].
Widget _buildSubject({
  required double screenWidth,
  Widget? detail,
  double masterMinWidth = 400,
  double detailMinWidth = 300,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(screenWidth, 800)),
        child: Scaffold(
          body: MasterDetailLayout(
            master: const Text('master content'),
            detail: detail,
            masterMinWidth: masterMinWidth,
            detailMinWidth: detailMinWidth,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Resizable MasterDetailLayout', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });


    // ----------------------------------------------------------------
    // Drag interaction changes master width
    // ----------------------------------------------------------------

    testWidgets(
      'dragging the divider changes the master pane width',
      (tester) async {
        const screenWidth = 1200.0;
        await tester.binding.setSurfaceSize(const Size(screenWidth, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(_buildSubject(
          screenWidth: screenWidth,
          detail: const Text('detail content'),
        ));
        await tester.pumpAndSettle();

        // Find the GestureDetector that serves as the drag handle.
        final gestureDetector = find.byType(GestureDetector);
        expect(gestureDetector, findsOneWidget);

        // Record the initial master SizedBox width.
        SizedBox masterBoxBefore = _findMasterSizedBox(tester);
        final widthBefore = masterBoxBefore.width!;

        // Drag the divider 50 px to the right.
        await tester.drag(gestureDetector, const Offset(50, 0));
        await tester.pumpAndSettle();

        SizedBox masterBoxAfter = _findMasterSizedBox(tester);
        expect(masterBoxAfter.width!, greaterThan(widthBefore));
      },
      variant: TargetPlatformVariant.desktop(),
    );

    // ----------------------------------------------------------------
    // Ratio is clamped at the minimum master width
    // ----------------------------------------------------------------

    testWidgets(
      'ratio is clamped so master never goes below masterMinWidth',
      (tester) async {
        const screenWidth = 1200.0;
        const masterMinWidth = 400.0;
        await tester.binding.setSurfaceSize(const Size(screenWidth, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_buildSubject(
          screenWidth: screenWidth,
          detail: const Text('detail content'),
          masterMinWidth: masterMinWidth,
        ));
        await tester.pumpAndSettle();

        final gestureDetector = find.byType(GestureDetector);

        // Drag far to the left — should clamp at masterMinWidth.
        await tester.drag(gestureDetector, const Offset(-800, 0));
        await tester.pumpAndSettle();

        SizedBox masterBox = _findMasterSizedBox(tester);
        expect(masterBox.width!, greaterThanOrEqualTo(masterMinWidth));
      },
      variant: TargetPlatformVariant.desktop(),
    );

    // ----------------------------------------------------------------
    // Ratio is clamped at the maximum (detail never below detailMinWidth)
    // ----------------------------------------------------------------

    testWidgets(
      'ratio is clamped so detail never goes below detailMinWidth',
      (tester) async {
        const screenWidth = 1200.0;
        const detailMinWidth = 300.0;
        const maxMasterWidth = screenWidth - detailMinWidth;
        await tester.binding.setSurfaceSize(const Size(screenWidth, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_buildSubject(
          screenWidth: screenWidth,
          detail: const Text('detail content'),
          detailMinWidth: detailMinWidth,
        ));
        await tester.pumpAndSettle();

        final gestureDetector = find.byType(GestureDetector);

        // Drag far to the right — should clamp so detail keeps its min width.
        await tester.drag(gestureDetector, const Offset(800, 0));
        await tester.pumpAndSettle();

        SizedBox masterBox = _findMasterSizedBox(tester);
        // Master width must not exceed (screenWidth - detailMinWidth).
        // The 8px divider sits between the panes; master width is clamped
        // before the divider width is considered, so we allow a small margin.
        expect(masterBox.width!, lessThanOrEqualTo(maxMasterWidth));
      },
      variant: TargetPlatformVariant.desktop(),
    );

    // ----------------------------------------------------------------
    // Divider shows resize cursor
    // ----------------------------------------------------------------

    testWidgets(
      'divider shows resizeColumn cursor via MouseRegion',
      (tester) async {
        await tester.pumpWidget(_buildSubject(
          screenWidth: AppConstants.expandedBreakpoint,
          detail: const Text('detail content'),
        ));
        await tester.pumpAndSettle();

        // Find the MouseRegion with the resizeColumn cursor specifically.
        final resizeMouseRegion = find.byWidgetPredicate(
          (w) =>
              w is MouseRegion &&
              w.cursor == SystemMouseCursors.resizeColumn,
        );
        expect(resizeMouseRegion, findsOneWidget);
      },
      variant: TargetPlatformVariant.desktop(),
    );

    // ----------------------------------------------------------------
    // Divider highlights on hover
    // ----------------------------------------------------------------

    testWidgets(
      'divider highlights with primary colour on hover',
      (tester) async {
        await tester.pumpWidget(_buildSubject(
          screenWidth: AppConstants.expandedBreakpoint,
          detail: const Text('detail content'),
        ));
        await tester.pumpAndSettle();

        // Find the 2px visual divider Container before hover.
        Container dividerBefore = _findDividerContainer(tester);
        final colourBefore = dividerBefore.color;

        // Find the MouseRegion with the resize cursor.
        final resizeRegion = find.byWidgetPredicate(
          (w) =>
              w is MouseRegion &&
              w.cursor == SystemMouseCursors.resizeColumn,
        );
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(resizeRegion));
        await tester.pumpAndSettle();

        Container dividerAfter = _findDividerContainer(tester);
        final colourAfter = dividerAfter.color;

        // The colour should have changed after hover.
        expect(colourAfter, isNot(equals(colourBefore)));
      },
      variant: TargetPlatformVariant.desktop(),
    );
  });
}

/// Locates the SizedBox that wraps the master pane (the first ancestor
/// SizedBox of 'master content' that has an explicit width).
SizedBox _findMasterSizedBox(WidgetTester tester) {
  SizedBox? masterBox;
  tester
      .widgetList<SizedBox>(find.ancestor(
        of: find.text('master content'),
        matching: find.byType(SizedBox),
      ))
      .forEach((box) {
    if (box.width != null) masterBox ??= box;
  });
  expect(masterBox, isNotNull,
      reason: 'Expected a SizedBox with explicit width above master');
  return masterBox!;
}

/// Locates the 2px visual divider Container inside the drag handle.
Container _findDividerContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(
    find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byType(Container),
    ),
  );
  return containers.firstWhere((c) => c.constraints?.maxWidth == 2);
}
