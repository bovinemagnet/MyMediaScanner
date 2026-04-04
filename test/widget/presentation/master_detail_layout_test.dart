import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';

/// Builds a [MasterDetailLayout] inside a [MaterialApp] whose viewport is
/// constrained to [screenWidth] × 800 via [MediaQuery].
Widget _buildSubject({
  required double screenWidth,
  Widget? detail,
  double masterMinWidth = 400,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(screenWidth, 800)),
      child: Scaffold(
        body: MasterDetailLayout(
          master: const Text('master content'),
          detail: detail,
          masterMinWidth: masterMinWidth,
        ),
      ),
    ),
  );
}

void main() {
  group('MasterDetailLayout', () {
    // ------------------------------------------------------------------
    // Desktop — wide screen (≥ mediumBreakpoint) with detail provided
    // ------------------------------------------------------------------

    group('on desktop at ${AppConstants.expandedBreakpoint}px with detail', () {
      testWidgets(
        'rendersMasterContent_andDetailContent',
        (tester) async {
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.expandedBreakpoint,
            detail: const Text('detail content'),
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.text('detail content'), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'rendersVerticalDivider_betweenMasterAndDetail',
        (tester) async {
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.expandedBreakpoint,
            detail: const Text('detail content'),
          ));

          // Ghost divider is a 1px Container (replacing VerticalDivider)
          final dividers = find.byWidgetPredicate(
              (w) => w is Container && w.constraints?.maxWidth == 1);
          expect(dividers, findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'masterPaneIsWrappedInSizedBox_notExpandedDirectly',
        (tester) async {
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.expandedBreakpoint,
            detail: const Text('detail content'),
          ));

          // The split layout wraps master in SizedBox and detail in Expanded.
          expect(find.byType(Row), findsOneWidget);
          expect(find.byType(SizedBox), findsWidgets);
          expect(find.byType(Expanded), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------
    // Desktop — wide screen with no detail (null)
    // ------------------------------------------------------------------

    group('on desktop at ${AppConstants.expandedBreakpoint}px without detail', () {
      testWidgets(
        'rendersMasterOnly_noVerticalDivider',
        (tester) async {
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.expandedBreakpoint,
            // detail is null — omitted
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.byType(VerticalDivider), findsNothing);
          expect(find.byType(Row), findsNothing);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------
    // Desktop — narrow screen (< mediumBreakpoint) with detail provided
    // ------------------------------------------------------------------

    group('on desktop at 500px (below breakpoint) with detail', () {
      testWidgets(
        'rendersMasterOnly_detailNotRendered',
        (tester) async {
          // 500 px is below the 900 px medium breakpoint, so only master
          // should appear even though detail is supplied.
          await tester.pumpWidget(_buildSubject(
            screenWidth: 500,
            detail: const Text('detail content'),
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.text('detail content'), findsNothing);
          expect(find.byType(VerticalDivider), findsNothing);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------
    // Desktop — exactly at the breakpoint boundary
    // ------------------------------------------------------------------

    group('on desktop at exactly ${AppConstants.mediumBreakpoint}px with detail', () {
      testWidgets(
        'rendersBothPanes_atExactBreakpoint',
        (tester) async {
          // The condition is width >= mediumBreakpoint, so at exactly 900 px
          // the split view must be shown.
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.mediumBreakpoint,
            detail: const Text('detail content'),
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.text('detail content'), findsOneWidget);
          // Ghost divider is a 1px Container (replacing VerticalDivider)
          final dividers = find.byWidgetPredicate(
              (w) => w is Container && w.constraints?.maxWidth == 1);
          expect(dividers, findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------
    // Desktop — one pixel below the breakpoint boundary
    // ------------------------------------------------------------------

    group('on desktop at ${AppConstants.mediumBreakpoint - 1}px with detail', () {
      testWidgets(
        'rendersMasterOnly_onePixelBelowBreakpoint',
        (tester) async {
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.mediumBreakpoint - 1,
            detail: const Text('detail content'),
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.text('detail content'), findsNothing);
          expect(find.byType(VerticalDivider), findsNothing);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });

    // ------------------------------------------------------------------
    // Mobile — wide screen with detail provided
    // ------------------------------------------------------------------

    group('on mobile at ${AppConstants.expandedBreakpoint}px with detail', () {
      testWidgets(
        'rendersMasterOnly_mobileIgnoresSplitLayout',
        (tester) async {
          // PlatformCapability.isDesktop is false on mobile, so the split
          // layout must never appear regardless of screen width or detail.
          await tester.pumpWidget(_buildSubject(
            screenWidth: AppConstants.expandedBreakpoint,
            detail: const Text('detail content'),
          ));

          expect(find.text('master content'), findsOneWidget);
          expect(find.text('detail content'), findsNothing);
          expect(find.byType(VerticalDivider), findsNothing);
        },
        variant: TargetPlatformVariant.mobile(),
      );
    });

    // ------------------------------------------------------------------
    // masterMinWidth enforcement
    // ------------------------------------------------------------------

    group('masterMinWidth enforcement on desktop', () {
      testWidgets(
        'masterPaneUsesMinWidth_when45PercentOfScreenIsSmaller',
        (tester) async {
          // Screen width = 1200 px → 45 % = 540 px, which is below the
          // custom masterMinWidth of 600 px.  The SizedBox for master
          // must therefore be 600 px wide (minWidth wins).
          const screenWidth = 1200.0;
          const masterMinWidth = 600.0;
          expect(screenWidth * 0.45, lessThan(masterMinWidth));

          await tester.pumpWidget(_buildSubject(
            screenWidth: screenWidth,
            detail: const Text('detail content'),
            masterMinWidth: masterMinWidth,
          ));

          // Locate the SizedBox that wraps the master pane.
          // The direct child of the Row is a SizedBox; walk up from the
          // master text and take the first SizedBox with a non-null width.
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
          expect(masterBox!.width, masterMinWidth);
        },
        variant: TargetPlatformVariant.desktop(),
      );

      testWidgets(
        'masterPaneUses45PercentWidth_when45PercentExceedsMinWidth',
        (tester) async {
          // Screen width = 1200 px → 45 % = 540 px, which is above the
          // default masterMinWidth of 400 px.  The SizedBox must be 540 px.
          const screenWidth = 1200.0;
          const masterMinWidth = 400.0;
          final expectedWidth = screenWidth * 0.45; // 540
          expect(expectedWidth, greaterThan(masterMinWidth));

          await tester.pumpWidget(_buildSubject(
            screenWidth: screenWidth,
            detail: const Text('detail content'),
            masterMinWidth: masterMinWidth,
          ));

          // Walk up from master text and take the first SizedBox that has
          // an explicit (non-null) width — this is the master pane container.
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
          expect(masterBox!.width, expectedWidth);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    });
  });
}
