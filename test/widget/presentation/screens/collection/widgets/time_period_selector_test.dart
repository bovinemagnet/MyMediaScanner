// Widget tests for [TimePeriodSelector].
//
// Guards against the label-wrapping regression where "12 months" broke
// character-by-character across three lines inside its segmented-button cell
// on a narrow screen (issue #98).
//
// Author: Paul Snow
// Since: 0.0.0
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/time_period_selector.dart';

void main() {
  testWidgets(
    'time-period labels never wrap onto multiple lines on a narrow screen',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(width: 320, child: TimePeriodSelector()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final period in TimePeriod.values) {
        final labelFinder = find.text(period.label);
        final label = tester.widget<Text>(labelFinder);
        expect(
          label.maxLines,
          1,
          reason: '"${period.label}" must be capped to a single line',
        );
        // Each label scales down to fit its segment so the full text stays
        // readable ("12 months" shrinks instead of truncating to "1…").
        expect(
          find.ancestor(
            of: labelFinder,
            matching: find.byWidgetPredicate(
              (w) => w is FittedBox && w.fit == BoxFit.scaleDown,
            ),
          ),
          findsOneWidget,
          reason: '"${period.label}" should scale down, not ellipsise',
        );
      }
      // No layout overflow should be logged while rendering constrained.
      expect(tester.takeException(), isNull);
    },
  );
}
