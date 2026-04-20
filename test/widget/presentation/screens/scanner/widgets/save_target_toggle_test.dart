import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/save_target_toggle.dart';

void main() {
  group('SaveTargetToggle', () {
    testWidgets('renders Collection and Wishlist segments', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SaveTargetToggle()),
          ),
        ),
      );

      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('Collection is selected by default', (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (_, ref, _) {
                  capturedRef = ref;
                  return const SaveTargetToggle();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        capturedRef.read(scannerProvider).saveTarget,
        SaveTarget.collection,
      );

      final button = tester.widget<SegmentedButton<SaveTarget>>(
        find.byType(SegmentedButton<SaveTarget>),
      );
      expect(button.selected, {SaveTarget.collection});
    });

    testWidgets('tapping Wishlist flips the scanner saveTarget',
        (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (_, ref, _) {
                  capturedRef = ref;
                  return const SaveTargetToggle();
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Wishlist'));
      await tester.pumpAndSettle();

      expect(
        capturedRef.read(scannerProvider).saveTarget,
        SaveTarget.wishlist,
      );

      final button = tester.widget<SegmentedButton<SaveTarget>>(
        find.byType(SegmentedButton<SaveTarget>),
      );
      expect(button.selected, {SaveTarget.wishlist});
    });

    testWidgets('tapping Collection after Wishlist flips back',
        (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (_, ref, _) {
                  capturedRef = ref;
                  return const SaveTargetToggle();
                },
              ),
            ),
          ),
        ),
      );

      // First switch to wishlist
      capturedRef
          .read(scannerProvider.notifier)
          .setSaveTarget(SaveTarget.wishlist);
      await tester.pumpAndSettle();

      // Now tap Collection
      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      expect(
        capturedRef.read(scannerProvider).saveTarget,
        SaveTarget.collection,
      );
    });
  });
}
