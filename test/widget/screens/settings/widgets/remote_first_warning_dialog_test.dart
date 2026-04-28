import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/remote_first_warning_dialog.dart';

void main() {
  Future<bool?> show(WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const RemoteFirstWarningDialog(),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Confirm returns true', (tester) async {
    bool? captured;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () async {
            captured = await showDialog<bool>(
              context: context,
              builder: (_) => const RemoteFirstWarningDialog(),
            );
          },
          child: const Text('open'),
        ),
      )),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable anyway'));
    await tester.pumpAndSettle();
    expect(captured, isTrue);
  });

  testWidgets('Cancel returns false', (tester) async {
    bool? captured;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () async {
            captured = await showDialog<bool>(
              context: context,
              builder: (_) => const RemoteFirstWarningDialog(),
            );
          },
          child: const Text('open'),
        ),
      )),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(captured, isFalse);
  });

  testWidgets('Renders the PRD warning text', (tester) async {
    await show(tester);
    expect(
        find.textContaining('TMDB can store your ratings'),
        findsOneWidget);
    expect(
        find.textContaining('barcode, shelf, location'), findsOneWidget);
  });
}
