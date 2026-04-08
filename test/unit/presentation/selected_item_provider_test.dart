import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';

void main() {
  // Helper that creates a fresh ProviderContainer for each test, registers
  // teardown, and returns the notifier ready to exercise.
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('SelectedItemNotifier', () {
    // ------------------------------------------------------------------
    // Initial state
    // ------------------------------------------------------------------

    test('build_initialState_isNull', () {
      final container = makeContainer();

      expect(container.read(selectedItemProvider), isNull);
    });

    // ------------------------------------------------------------------
    // select
    // ------------------------------------------------------------------

    test('select_validId_setsStateToGivenId', () {
      final container = makeContainer();

      container.read(selectedItemProvider.notifier).select('abc');

      expect(container.read(selectedItemProvider), 'abc');
    });

    // ------------------------------------------------------------------
    // clear
    // ------------------------------------------------------------------

    test('clear_afterSelect_resetsStateToNull', () {
      final container = makeContainer();
      container.read(selectedItemProvider.notifier).select('abc');

      container.read(selectedItemProvider.notifier).clear();

      expect(container.read(selectedItemProvider), isNull);
    });

    // ------------------------------------------------------------------
    // moveNext
    // ------------------------------------------------------------------

    group('moveNext', () {
      test('moveNext_emptyList_returnsNullAndStateRemainsNull', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);

        final result = notifier.moveNext([]);

        expect(result, isNull);
        expect(container.read(selectedItemProvider), isNull);
      });

      test('moveNext_nullStateNonEmptyList_selectsFirstItemAndReturnsIt', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];

        final result = notifier.moveNext(items);

        expect(result, 'id1');
        expect(container.read(selectedItemProvider), 'id1');
      });

      test('moveNext_currentIsMiddleItem_selectsNextItemAndReturnsIt', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id2');

        final result = notifier.moveNext(items);

        expect(result, 'id3');
        expect(container.read(selectedItemProvider), 'id3');
      });

      test('moveNext_currentIsFirstItem_selectsSecondItemAndReturnsIt', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id1');

        final result = notifier.moveNext(items);

        expect(result, 'id2');
        expect(container.read(selectedItemProvider), 'id2');
      });

      test('moveNext_currentIsLastItem_staysAtLastAndReturnsCurrent', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id3');

        final result = notifier.moveNext(items);

        expect(result, 'id3');
        expect(container.read(selectedItemProvider), 'id3');
      });

      test('moveNext_currentIdNotInList_staysAtCurrentAndReturnsCurrent', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('unknown');

        final result = notifier.moveNext(items);

        expect(result, 'unknown');
        expect(container.read(selectedItemProvider), 'unknown');
      });

      test('moveNext_singleItemList_nullState_selectsThatItemAndReturnsIt', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);

        final result = notifier.moveNext(['only']);

        expect(result, 'only');
        expect(container.read(selectedItemProvider), 'only');
      });

      test('moveNext_singleItemList_alreadySelected_staysAndReturnsCurrent',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        notifier.select('only');

        final result = notifier.moveNext(['only']);

        expect(result, 'only');
        expect(container.read(selectedItemProvider), 'only');
      });
    });

    // ------------------------------------------------------------------
    // movePrevious
    // ------------------------------------------------------------------

    group('movePrevious', () {
      test('movePrevious_emptyList_returnsNullAndStateRemainsNull', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);

        final result = notifier.movePrevious([]);

        expect(result, isNull);
        expect(container.read(selectedItemProvider), isNull);
      });

      test('movePrevious_nullStateNonEmptyList_selectsLastItemAndReturnsIt',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];

        final result = notifier.movePrevious(items);

        expect(result, 'id3');
        expect(container.read(selectedItemProvider), 'id3');
      });

      test('movePrevious_currentIsMiddleItem_selectsPreviousItemAndReturnsIt',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id2');

        final result = notifier.movePrevious(items);

        expect(result, 'id1');
        expect(container.read(selectedItemProvider), 'id1');
      });

      test('movePrevious_currentIsLastItem_selectsSecondToLastAndReturnsIt',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id3');

        final result = notifier.movePrevious(items);

        expect(result, 'id2');
        expect(container.read(selectedItemProvider), 'id2');
      });

      test('movePrevious_currentIsFirstItem_staysAtFirstAndReturnsCurrent', () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('id1');

        final result = notifier.movePrevious(items);

        expect(result, 'id1');
        expect(container.read(selectedItemProvider), 'id1');
      });

      test(
          'movePrevious_currentIdNotInList_staysAtCurrentAndReturnsCurrent',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        final items = ['id1', 'id2', 'id3'];
        notifier.select('unknown');

        final result = notifier.movePrevious(items);

        expect(result, 'unknown');
        expect(container.read(selectedItemProvider), 'unknown');
      });

      test('movePrevious_singleItemList_nullState_selectsThatItemAndReturnsIt',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);

        final result = notifier.movePrevious(['only']);

        expect(result, 'only');
        expect(container.read(selectedItemProvider), 'only');
      });

      test(
          'movePrevious_singleItemList_alreadySelected_staysAndReturnsCurrent',
          () {
        final container = makeContainer();
        final notifier = container.read(selectedItemProvider.notifier);
        notifier.select('only');

        final result = notifier.movePrevious(['only']);

        expect(result, 'only');
        expect(container.read(selectedItemProvider), 'only');
      });
    });
  });
}
