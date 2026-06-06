// Widget tests for ManualBarcodeEntryDialog.
//
// The dialog owns its TextEditingController and disposes it via State.dispose
// so the controller is never used after disposal during the route's exit
// animation (the previous `.whenComplete(controller.dispose)` pattern threw
// "A TextEditingController was used after being disposed").
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/manual_barcode_entry_dialog.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    required ValueChanged<String> onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ManualBarcodeEntryDialog(onSubmit: onSubmit),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('ManualBarcodeEntryDialog', () {
    testWidgets('submits the entered barcode and closes cleanly', (
      tester,
    ) async {
      String? submitted;
      await openDialog(tester, onSubmit: (v) => submitted = v);

      await tester.enterText(find.byType(TextField), '9780747532699');
      await tester.tap(find.text('Look up'));
      await tester.pumpAndSettle();

      expect(submitted, '9780747532699');
      expect(find.byType(TextField), findsNothing);
      // No "used after being disposed" error during the exit animation.
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not submit when cancelled', (tester) async {
      var called = false;
      await openDialog(tester, onSubmit: (_) => called = true);

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not submit an empty value', (tester) async {
      var called = false;
      await openDialog(tester, onSubmit: (_) => called = true);

      await tester.tap(find.text('Look up'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
