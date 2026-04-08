import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/selected_rip_album_provider.dart';

void main() {
  // Creates a fresh, isolated ProviderContainer for each test and registers
  // its disposal as a teardown so tests never share state.
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('SelectedRipAlbumNotifier', () {
    // ------------------------------------------------------------------
    // Initial state
    // ------------------------------------------------------------------

    test('build_initialState_isNull', () {
      final container = makeContainer();

      expect(container.read(selectedRipAlbumProvider), isNull);
    });

    // ------------------------------------------------------------------
    // select
    // ------------------------------------------------------------------

    test('select_validId_setsStateToGivenId', () {
      final container = makeContainer();

      container.read(selectedRipAlbumProvider.notifier).select('album-1');

      expect(container.read(selectedRipAlbumProvider), 'album-1');
    });

    test('select_calledTwice_stateReflectsLastId', () {
      final container = makeContainer();
      final notifier = container.read(selectedRipAlbumProvider.notifier);

      notifier.select('album-1');
      notifier.select('album-2');

      expect(container.read(selectedRipAlbumProvider), 'album-2');
    });

    // ------------------------------------------------------------------
    // clear
    // ------------------------------------------------------------------

    test('clear_afterSelect_resetsStateToNull', () {
      final container = makeContainer();
      final notifier = container.read(selectedRipAlbumProvider.notifier);
      notifier.select('album-1');

      notifier.clear();

      expect(container.read(selectedRipAlbumProvider), isNull);
    });

    test('clear_whenAlreadyNull_stateRemainsNull', () {
      final container = makeContainer();

      // Calling clear on an already-null state must not throw and must
      // leave state as null.
      container.read(selectedRipAlbumProvider.notifier).clear();

      expect(container.read(selectedRipAlbumProvider), isNull);
    });
  });
}
