// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyMediaScanner';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTrashEntryTitle => 'Trash';

  @override
  String get settingsTrashEntrySubtitle =>
      'Restore or permanently delete items you removed from the collection';

  @override
  String get settingsDedupeEntryTitle => 'Find duplicates';

  @override
  String get settingsDedupeEntrySubtitle =>
      'Scan the library for items with the same barcode or a near-identical title and year';

  @override
  String get settingsBackupEntryTitle => 'Backup & restore';

  @override
  String get settingsBackupEntrySubtitle =>
      'Copy the local database to a portable file, or restore from a previously-saved backup';

  @override
  String get settingsAccessibilityHeading => 'Accessibility';

  @override
  String get settingsTextSizeHeading => 'Text size';

  @override
  String get settingsTextSizeBody =>
      'Stacks on top of the platform text-size setting so the whole app scales together with the rest of your device.';

  @override
  String get trashEmpty =>
      'Nothing in trash.\nSoft-deleted items appear here so you can restore them.';

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashDeleteForever => 'Delete forever';

  @override
  String get trashConfirmTitle => 'Delete forever?';

  @override
  String get trashConfirmCancel => 'Cancel';
}
