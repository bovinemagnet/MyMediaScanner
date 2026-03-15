import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/media_type_toggles.dart';

void main() {
  group('MediaTypeToggles', () {
    testWidgets('renders all 5 media type chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaTypeToggles(),
            ),
          ),
        ),
      );

      expect(find.text('CD'), findsOneWidget);
      expect(find.text('DVD/Blu-ray'), findsOneWidget);
      expect(find.text('TV'), findsOneWidget);
      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
    });

    testWidgets('all chips are initially selected', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaTypeToggles(),
            ),
          ),
        ),
      );

      // All five FilterChips should be selected by default
      final chips = tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .toList();
      expect(chips.length, 5);
      for (final chip in chips) {
        expect(chip.selected, isTrue);
      }
    });

    testWidgets('tapping a chip toggles its enabled state', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return const MediaTypeToggles();
                },
              ),
            ),
          ),
        ),
      );

      // All types enabled initially
      expect(
        capturedRef.read(scannerProvider).enabledMediaTypes,
        contains(MediaType.music),
      );

      // Tap the CD chip to disable Music
      await tester.tap(find.text('CD'));
      await tester.pumpAndSettle();

      expect(
        capturedRef.read(scannerProvider).enabledMediaTypes,
        isNot(contains(MediaType.music)),
      );
    });

    testWidgets('chips reflect disabled state after toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaTypeToggles(),
            ),
          ),
        ),
      );

      // Tap CD chip to disable Music
      await tester.tap(find.text('CD'));
      await tester.pumpAndSettle();

      final chips = tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .toList();

      // The first chip (CD / Music) should now be deselected
      expect(chips[0].selected, isFalse);
      // Others should remain selected
      expect(chips[1].selected, isTrue);
      expect(chips[2].selected, isTrue);
      expect(chips[3].selected, isTrue);
      expect(chips[4].selected, isTrue);
    });
  });
}
