import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/rip_view_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Creates a fresh, isolated ProviderContainer for each test and registers
  // its disposal as a teardown so tests never share state.
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    // Provide an empty in-memory SharedPreferences backing store so that
    // SharedPreferences.getInstance() never touches the real file system.
    SharedPreferences.setMockInitialValues({});
  });

  group('RipViewModeNotifier', () {
    // ------------------------------------------------------------------
    // Initial state
    // ------------------------------------------------------------------

    test('build_initialState_isGrid', () {
      final container = makeContainer();

      expect(container.read(ripViewModeProvider), RipViewMode.grid);
    });

    // ------------------------------------------------------------------
    // toggle
    // ------------------------------------------------------------------

    test('toggle_fromGrid_setsStateToTable', () {
      final container = makeContainer();

      container.read(ripViewModeProvider.notifier).toggle();

      expect(container.read(ripViewModeProvider), RipViewMode.table);
    });

    test('toggle_fromTable_setsStateBackToGrid', () {
      final container = makeContainer();
      final notifier = container.read(ripViewModeProvider.notifier);

      notifier.toggle(); // grid → table
      notifier.toggle(); // table → grid

      expect(container.read(ripViewModeProvider), RipViewMode.grid);
    });

    // ------------------------------------------------------------------
    // setMode
    // ------------------------------------------------------------------

    test('setMode_table_setsStateToTable', () {
      final container = makeContainer();

      container.read(ripViewModeProvider.notifier).setMode(RipViewMode.table);

      expect(container.read(ripViewModeProvider), RipViewMode.table);
    });

    test('setMode_grid_afterTable_setsStateBackToGrid', () {
      final container = makeContainer();
      final notifier = container.read(ripViewModeProvider.notifier);

      notifier.setMode(RipViewMode.table);
      notifier.setMode(RipViewMode.grid);

      expect(container.read(ripViewModeProvider), RipViewMode.grid);
    });

    // ------------------------------------------------------------------
    // Persistence — state loaded from SharedPreferences on build
    // ------------------------------------------------------------------

    test('build_withStoredTablePreference_loadsTableState', () async {
      // Seed prefs with 'table' before the provider is read so that
      // _loadFromPrefs() finds the stored value.
      SharedPreferences.setMockInitialValues({'rip_view_mode': 'table'});

      // Create the container manually (no addTearDown yet) so we can keep it
      // alive until the async prefs load has resolved.
      final container = ProviderContainer();

      // Subscribe so Riverpod keeps the provider alive and state changes reach
      // us.  Wait for the 'table' value to arrive (or timeout after 1 second).
      final completer = Completer<RipViewMode>();
      final sub = container.listen<RipViewMode>(
        ripViewModeProvider,
        (_, next) {
          if (!completer.isCompleted) completer.complete(next);
        },
        fireImmediately: false,
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () => container.read(ripViewModeProvider),
      );

      sub.close();
      container.dispose();

      expect(result, RipViewMode.table);
    });

    test('build_withStoredGridPreference_remainsGrid', () async {
      // When the stored value is 'grid', _loadFromPrefs never updates state,
      // so after a short delay the provider must still report grid.
      SharedPreferences.setMockInitialValues({'rip_view_mode': 'grid'});

      final container = ProviderContainer();
      // Prime the provider.
      container.read(ripViewModeProvider);
      // Allow any async prefs work to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final result = container.read(ripViewModeProvider);
      container.dispose();

      expect(result, RipViewMode.grid);
    });
  });
}
