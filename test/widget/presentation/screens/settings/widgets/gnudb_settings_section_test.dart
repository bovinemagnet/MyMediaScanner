import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/gnudb_settings_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('displays the default username and saves edits',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: GnudbSettingsSection()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'mymediascanner');

    await tester.enterText(find.byType(TextField), 'paul');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Provider was updated.
    final element = tester.element(find.byType(GnudbSettingsSection));
    final container = ProviderScope.containerOf(element);
    expect(container.read(gnudbUsernameProvider), 'paul');

    // Snackbar shown.
    expect(find.text('GnuDB username saved'), findsOneWidget);
  });

  testWidgets('empty input reverts to default on save', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: GnudbSettingsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(GnudbSettingsSection));
    final container = ProviderScope.containerOf(element);
    expect(container.read(gnudbUsernameProvider), 'mymediascanner');
  });
}
