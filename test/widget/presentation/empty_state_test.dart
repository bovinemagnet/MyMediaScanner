import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: 'No items found'),
        ),
      ));

      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            message: 'Empty',
            icon: Icons.search_off,
          ),
        ),
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('renders action widget when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyState(
            message: 'No items',
            action: ElevatedButton(
              onPressed: () {},
              child: const Text('Add item'),
            ),
          ),
        ),
      ));

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does not render action when not provided', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: 'Nothing here'),
        ),
      ));

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
