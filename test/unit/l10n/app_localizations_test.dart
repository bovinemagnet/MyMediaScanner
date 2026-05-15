import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/l10n/app_localizations.dart';
import 'package:mymediascanner/l10n/app_localizations_en.dart';

void main() {
  test('English ARB delivers the expected scaffold strings', () async {
    final l10n = AppLocalizationsEn();

    expect(l10n.appTitle, 'MyMediaScanner');
    expect(l10n.settingsTitle, 'Settings');
    expect(l10n.trashRestore, 'Restore');
    expect(l10n.trashDeleteForever, 'Delete forever');
    expect(l10n.settingsAccessibilityHeading, 'Accessibility');
  });

  test('AppLocalizations.supportedLocales lists English', () {
    expect(
      AppLocalizations.supportedLocales,
      contains(const Locale('en')),
    );
  });
}
