/// Widget tests for [SettingsScreen] and its constituent section widgets:
/// the API key form, theme-mode toggle, and sync configuration section.
///
/// Each test isolates exactly the behaviour under scrutiny by overriding all
/// providers that would otherwise attempt I/O (secure storage, shared prefs,
/// database).  The FLAC Library section is rendered because tests run on
/// Linux (desktop), so the relevant rip providers are also stubbed.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/settings_screen.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_defect_detector/audio_defect_detector.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ---------------------------------------------------------------------------
// Fake notifiers — extend the real class so overrideWith type checks pass
// ---------------------------------------------------------------------------

class _FakeApiKeysNotifier extends ApiKeysNotifier {
  @override
  Future<Map<String, String?>> build() async => <String, String?>{
        'tmdb': null,
        'discogs': null,
        'upcitemdb': null,
        'google_books': null,
        'tvdb': null,
        'fanart': null,
      };
}

class _FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;
}

class _FakePostgresConfigNotifier extends PostgresConfigNotifier {
  @override
  Future<PostgresConfig?> build() async => null;
}

class _FakeRipLibraryPathNotifier extends RipLibraryPathNotifier {
  @override
  Future<String?> build() async => null;
}

class _FakeFlacBinaryPathNotifier extends FlacBinaryPathNotifier {
  @override
  Future<String?> build() async => null;
}

class _FakeClickDetectionSensitivityNotifier
    extends ClickDetectionSensitivityNotifier {
  @override
  Future<Sensitivity> build() async => Sensitivity.medium;
}

class _FakeReplayGainModeNotifier extends ReplayGainModeNotifier {
  @override
  ReplayGainMode build() => ReplayGainMode.off;
}

class _FakeReplayGainPreampNotifier extends ReplayGainPreampNotifier {
  @override
  double build() => 0.0;
}

class _FakePreventClippingNotifier extends PreventClippingNotifier {
  @override
  bool build() => true;
}

// ---------------------------------------------------------------------------
// Helper — build the full SettingsScreen with all providers stubbed
// ---------------------------------------------------------------------------

Widget _buildSettings({
  MockFlutterSecureStorage? storage,
  ThemeModeNotifier Function()? themeNotifierFactory,
}) {
  final mockStorage = storage ?? MockFlutterSecureStorage();
  when(() => mockStorage.read(key: any(named: 'key')))
      .thenAnswer((_) async => null);

  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(mockStorage),
      apiKeysProvider.overrideWith(_FakeApiKeysNotifier.new),
      themeModeProvider.overrideWith(
        themeNotifierFactory ?? _FakeThemeModeNotifier.new,
      ),
      postgresConfigProvider.overrideWith(_FakePostgresConfigNotifier.new),
      syncRepositoryProvider.overrideWithValue(null),
      ripLibraryPathProvider.overrideWith(_FakeRipLibraryPathNotifier.new),
      ripScanNotifierProvider.overrideWith(() => RipScanNotifier()),
      flacBinaryPathOverrideProvider.overrideWith(
          _FakeFlacBinaryPathNotifier.new),
      clickDetectionSensitivityProvider.overrideWith(
          _FakeClickDetectionSensitivityNotifier.new),
      replayGainModeProvider.overrideWith(_FakeReplayGainModeNotifier.new),
      replayGainPreampProvider
          .overrideWith(_FakeReplayGainPreampNotifier.new),
      preventClippingProvider.overrideWith(_FakePreventClippingNotifier.new),
    ],
    child: const MaterialApp(
      home: SettingsScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Test 1 — API key section: MusicBrainz built-in help note
  // -------------------------------------------------------------------------

  testWidgets(
      'renders the API key section with MusicBrainz built-in help note',
      (tester) async {
    await tester.pumpWidget(_buildSettings());
    await tester.pumpAndSettle();

    // Scroll until the API Integrations section is visible.
    await tester.scrollUntilVisible(
      find.textContaining('MusicBrainz'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.textContaining('MusicBrainz'), findsWidgets);
    // The help note says "needs no key" for MusicBrainz.
    expect(find.textContaining('no key'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 2 — saving a TMDB key calls the api-keys notifier
  // -------------------------------------------------------------------------

  testWidgets('saving a TMDB key calls the api-keys notifier with the value',
      (tester) async {
    // Capture the TMDB key written to secure storage.
    final mockStorage = MockFlutterSecureStorage();
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(_buildSettings(storage: mockStorage));
    await tester.pumpAndSettle();

    // Scroll until the TMDB field is visible.
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'TMDB API Key'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'TMDB API Key'),
      'my-tmdb-key',
    );
    await tester.pump();

    // Tap the save icon associated with the TMDB field.
    // The _keyField helper renders the fields in order: TMDB, Discogs, UPC,
    // so the first Icons.save in the tree belongs to the TMDB field.
    final saveIconFinder = find.byIcon(Icons.save).first;
    await tester.ensureVisible(saveIconFinder);
    await tester.tap(saveIconFinder);
    await tester.pumpAndSettle();

    // Verify secure storage was asked to write the key value.
    verify(() => mockStorage.write(
          key: 'api_key_tmdb',
          value: 'my-tmdb-key',
        )).called(1);

    // Snackbar should confirm the save.
    expect(find.textContaining('TMDB API Key saved'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 3 — theme mode toggle updates the provider
  // -------------------------------------------------------------------------

  testWidgets('theme mode toggle updates the provider', (tester) async {
    final capturedModes = <ThemeMode>[];

    await tester.pumpWidget(_buildSettings(
      themeNotifierFactory: () => _CapturingThemeModeNotifier(
        onSet: capturedModes.add,
      ),
    ));
    await tester.pumpAndSettle();

    // Scroll to the Preferences section where the theme tile lives.
    await tester.scrollUntilVisible(
      find.byType(SegmentedButton<ThemeMode>),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Tap the 'Light' segment inside the SegmentedButton.
    // The SegmentedButton renders its children so we look for the icon
    // inside it specifically to avoid hitting icons in the ListTile leading.
    final segmentedButton = find.byType(SegmentedButton<ThemeMode>);
    final lightSegment = find.descendant(
      of: segmentedButton,
      matching: find.byIcon(Icons.light_mode),
    );
    await tester.ensureVisible(lightSegment);
    await tester.tap(lightSegment);
    await tester.pumpAndSettle();

    expect(capturedModes, contains(ThemeMode.light));

    // Tap the 'Dark' segment.
    final darkSegment = find.descendant(
      of: segmentedButton,
      matching: find.byIcon(Icons.dark_mode),
    );
    await tester.ensureVisible(darkSegment);
    await tester.tap(darkSegment);
    await tester.pumpAndSettle();

    expect(capturedModes, contains(ThemeMode.dark));
  });

  // -------------------------------------------------------------------------
  // Test 4 — sync section shows not-configured state when no postgres config
  // -------------------------------------------------------------------------

  testWidgets(
      'sync section shows not-configured state when postgresConfig is null',
      (tester) async {
    await tester.pumpWidget(_buildSettings());
    await tester.pumpAndSettle();

    expect(find.text('Sync not configured'), findsOneWidget);
    expect(
        find.text('Set up PostgreSQL connection first'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 5 — ApiKeyForm in isolation: MusicBrainz note and field labels
  // -------------------------------------------------------------------------

  testWidgets(
      'ApiKeyForm renders MusicBrainz built-in help note and TMDB field',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    final mockStorage = MockFlutterSecureStorage();
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(mockStorage),
          apiKeysProvider.overrideWith(_FakeApiKeysNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ApiKeyForm()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('MusicBrainz'), findsOneWidget);
    expect(find.textContaining('no key'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'TMDB API Key'), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------
// Capturing notifier for theme-mode tests
// ---------------------------------------------------------------------------

class _CapturingThemeModeNotifier extends ThemeModeNotifier {
  _CapturingThemeModeNotifier({required this.onSet});

  final void Function(ThemeMode) onSet;

  @override
  ThemeMode build() => ThemeMode.system;

  @override
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    onSet(mode);
  }
}
