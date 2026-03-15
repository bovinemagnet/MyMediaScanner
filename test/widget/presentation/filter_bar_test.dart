import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/filter_bar.dart';

void main() {
  group('FilterBar', () {
    testWidgets('renders All chip and media type chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterBar(),
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      // Should render chips for Film, TV, Music, Book, Game (not Unknown)
      for (final type in MediaType.values
          .where((t) => t != MediaType.unknown)) {
        expect(find.text(type.label), findsOneWidget);
      }
      expect(find.text('Unknown'), findsNothing);
    });

    testWidgets('renders Lent out and Ripped filter chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FilterBar(),
            ),
          ),
        ),
      );

      expect(find.text('Lent out'), findsOneWidget);
      expect(find.text('Ripped'), findsOneWidget);
    });

    testWidgets('tapping a media type chip updates the filter',
        (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return const FilterBar();
                },
              ),
            ),
          ),
        ),
      );

      // Initially no media type is selected
      expect(
        capturedRef.read(collectionFilterProvider).mediaType,
        isNull,
      );

      // Tap the Film chip
      await tester.tap(find.text('Film'));
      await tester.pumpAndSettle();

      expect(
        capturedRef.read(collectionFilterProvider).mediaType,
        MediaType.film,
      );
    });

    testWidgets('tapping All chip clears media type filter', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return const FilterBar();
                },
              ),
            ),
          ),
        ),
      );

      // First select Film
      await tester.tap(find.text('Film'));
      await tester.pumpAndSettle();
      expect(
        capturedRef.read(collectionFilterProvider).mediaType,
        MediaType.film,
      );

      // Then tap All to clear
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(
        capturedRef.read(collectionFilterProvider).mediaType,
        isNull,
      );
    });
  });
}
