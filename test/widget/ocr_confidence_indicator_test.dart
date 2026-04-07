import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/ocr_confidence_indicator.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('OcrConfidenceIndicator', () {
    testWidgets('displays high confidence with green styling', (tester) async {
      await tester.pumpWidget(wrap(
        const OcrConfidenceIndicator(
          confidence: 0.92,
          searchTermUsed: 'The Matrix',
        ),
      ));

      expect(find.textContaining('92% confidence'), findsOneWidget);
      expect(find.textContaining('High confidence'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.textContaining('The Matrix'), findsOneWidget);
    });

    testWidgets('displays medium confidence with amber styling',
        (tester) async {
      await tester.pumpWidget(wrap(
        const OcrConfidenceIndicator(
          confidence: 0.65,
        ),
      ));

      expect(find.textContaining('65% confidence'), findsOneWidget);
      expect(find.textContaining('Medium confidence'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays low confidence with warning styling',
        (tester) async {
      await tester.pumpWidget(wrap(
        const OcrConfidenceIndicator(
          confidence: 0.30,
        ),
      ));

      expect(find.textContaining('30% confidence'), findsOneWidget);
      expect(find.textContaining('Low confidence'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('hides search term when null', (tester) async {
      await tester.pumpWidget(wrap(
        const OcrConfidenceIndicator(
          confidence: 0.85,
        ),
      ));

      expect(find.textContaining('Searched:'), findsNothing);
    });

    testWidgets('shows search term when provided', (tester) async {
      await tester.pumpWidget(wrap(
        const OcrConfidenceIndicator(
          confidence: 0.85,
          searchTermUsed: 'Dark Side of the Moon',
        ),
      ));

      expect(find.textContaining('Dark Side of the Moon'), findsOneWidget);
    });
  });
}
