import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/widgets/context_menu_actions.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';

void main() {
  group('ContextMenuActions', () {
    // ------------------------------------------------------------------ //
    // forMediaItem                                                         //
    // ------------------------------------------------------------------ //

    group('forMediaItem', () {
      test('returns exactly 5 actions', () {
        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        expect(actions.length, 5);
      });

      test('returns actions with correct labels in order', () {
        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        expect(actions[0].label, 'Edit');
        expect(actions[1].label, 'Add to shelf');
        expect(actions[2].label, 'Lend');
        expect(actions[3].label, 'Refresh metadata');
        expect(actions[4].label, 'Delete');
      });

      test('returns actions with correct icons in order', () {
        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        expect(actions[0].icon, Icons.edit_outlined);
        expect(actions[1].icon, Icons.shelves);
        expect(actions[2].icon, Icons.person_add_outlined);
        expect(actions[3].icon, Icons.refresh);
        expect(actions[4].icon, Icons.delete_outline);
      });

      test('Edit action calls onEdit callback', () {
        var called = false;

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () => called = true,
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        actions[0].onTap();

        expect(called, isTrue);
      });

      test('Add to shelf action calls onAddToShelf callback', () {
        var called = false;

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () => called = true,
          onLend: () {},
          onRefreshMetadata: () {},
        );

        actions[1].onTap();

        expect(called, isTrue);
      });

      test('Lend action calls onLend callback', () {
        var called = false;

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () => called = true,
          onRefreshMetadata: () {},
        );

        actions[2].onTap();

        expect(called, isTrue);
      });

      test('Refresh metadata action calls onRefreshMetadata callback', () {
        var called = false;

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () => called = true,
        );

        actions[3].onTap();

        expect(called, isTrue);
      });

      test('Delete action calls onDelete callback', () {
        var called = false;

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () => called = true,
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        actions[4].onTap();

        expect(called, isTrue);
      });

      test('each action only triggers its own callback and not others', () {
        // Track which callbacks were invoked.
        final invoked = <String>{};

        final actions = ContextMenuActions.forMediaItem(
          onEdit: () => invoked.add('edit'),
          onDelete: () => invoked.add('delete'),
          onAddToShelf: () => invoked.add('addToShelf'),
          onLend: () => invoked.add('lend'),
          onRefreshMetadata: () => invoked.add('refreshMetadata'),
        );

        // Trigger only the Lend action.
        actions[2].onTap();

        expect(invoked, {'lend'});
      });

      test('returns a new list on each call — mutations are independent', () {
        final first = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );
        final second = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        // Verify they are separate list instances.
        expect(identical(first, second), isFalse);
      });

      test('all returned items are ContextMenuAction instances', () {
        final actions = ContextMenuActions.forMediaItem(
          onEdit: () {},
          onDelete: () {},
          onAddToShelf: () {},
          onLend: () {},
          onRefreshMetadata: () {},
        );

        for (final action in actions) {
          expect(action, isA<ContextMenuAction>());
        }
      });
    });

    // ------------------------------------------------------------------ //
    // forShelf                                                             //
    // ------------------------------------------------------------------ //

    group('forShelf', () {
      test('returns exactly 2 actions', () {
        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () {},
        );

        expect(actions.length, 2);
      });

      test('returns actions with correct labels in order', () {
        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () {},
        );

        expect(actions[0].label, 'Rename');
        expect(actions[1].label, 'Delete');
      });

      test('returns actions with correct icons in order', () {
        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () {},
        );

        expect(actions[0].icon, Icons.edit_outlined);
        expect(actions[1].icon, Icons.delete_outline);
      });

      test('Rename action calls onRename callback', () {
        var called = false;

        final actions = ContextMenuActions.forShelf(
          onRename: () => called = true,
          onDelete: () {},
        );

        actions[0].onTap();

        expect(called, isTrue);
      });

      test('Delete action calls onDelete callback', () {
        var called = false;

        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () => called = true,
        );

        actions[1].onTap();

        expect(called, isTrue);
      });

      test('Rename action does not trigger onDelete callback', () {
        var deleteCalled = false;

        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () => deleteCalled = true,
        );

        actions[0].onTap();

        expect(deleteCalled, isFalse);
      });

      test('Delete action does not trigger onRename callback', () {
        var renameCalled = false;

        final actions = ContextMenuActions.forShelf(
          onRename: () => renameCalled = true,
          onDelete: () {},
        );

        actions[1].onTap();

        expect(renameCalled, isFalse);
      });

      test('all returned items are ContextMenuAction instances', () {
        final actions = ContextMenuActions.forShelf(
          onRename: () {},
          onDelete: () {},
        );

        for (final action in actions) {
          expect(action, isA<ContextMenuAction>());
        }
      });
    });
  });
}
