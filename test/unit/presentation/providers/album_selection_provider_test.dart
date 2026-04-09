import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/album_selection_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('AlbumSelectionNotifier', () {
    test('build_initialState_isEmpty', () {
      final container = makeContainer();

      expect(container.read(albumSelectionProvider), isEmpty);
    });

    test('toggle_addsId_whenNotSelected', () {
      final container = makeContainer();

      container.read(albumSelectionProvider.notifier).toggle('album-1');

      expect(container.read(albumSelectionProvider), {'album-1'});
    });

    test('toggle_removesId_whenAlreadySelected', () {
      final container = makeContainer();
      final notifier = container.read(albumSelectionProvider.notifier);

      notifier.toggle('album-1');
      notifier.toggle('album-1');

      expect(container.read(albumSelectionProvider), isEmpty);
    });

    test('selectAll_setsAllProvidedIds', () {
      final container = makeContainer();

      container
          .read(albumSelectionProvider.notifier)
          .selectAll(['album-1', 'album-2', 'album-3']);

      expect(container.read(albumSelectionProvider),
          {'album-1', 'album-2', 'album-3'});
    });

    test('clear_emptiesTheSet', () {
      final container = makeContainer();
      final notifier = container.read(albumSelectionProvider.notifier);

      notifier.selectAll(['album-1', 'album-2']);
      notifier.clear();

      expect(container.read(albumSelectionProvider), isEmpty);
    });

    test('selectRange_addsIdsInRange_fromLowToHigh', () {
      final container = makeContainer();
      final ordered = ['album-1', 'album-2', 'album-3', 'album-4', 'album-5'];

      container
          .read(albumSelectionProvider.notifier)
          .selectRange(ordered, 1, 3);

      expect(container.read(albumSelectionProvider),
          {'album-2', 'album-3', 'album-4'});
    });

    test('selectRange_addsIdsInRange_fromHighToLow', () {
      final container = makeContainer();
      final ordered = ['album-1', 'album-2', 'album-3', 'album-4', 'album-5'];

      container
          .read(albumSelectionProvider.notifier)
          .selectRange(ordered, 3, 1);

      expect(container.read(albumSelectionProvider),
          {'album-2', 'album-3', 'album-4'});
    });

    test('selectRange_mergesWithExistingSelection', () {
      final container = makeContainer();
      final notifier = container.read(albumSelectionProvider.notifier);
      final ordered = ['album-1', 'album-2', 'album-3', 'album-4', 'album-5'];

      notifier.toggle('album-5');
      notifier.selectRange(ordered, 0, 1);

      expect(container.read(albumSelectionProvider),
          {'album-1', 'album-2', 'album-5'});
    });
  });

  group('isInSelectionModeProvider', () {
    test('isInSelectionMode_falseWhenEmpty', () {
      final container = makeContainer();

      expect(container.read(isInSelectionModeProvider), isFalse);
    });

    test('isInSelectionMode_trueWhenNonEmpty', () {
      final container = makeContainer();

      container.read(albumSelectionProvider.notifier).toggle('album-1');

      expect(container.read(isInSelectionModeProvider), isTrue);
    });
  });
}
