import 'package:flutter/material.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';

/// Builds standard context menu action sets for reuse across screens.
abstract final class ContextMenuActions {
  /// Actions for a collection media item card.
  static List<ContextMenuAction> forMediaItem({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onAddToShelf,
    required VoidCallback onLend,
    required VoidCallback onRefreshMetadata,
  }) =>
      [
        ContextMenuAction(
          label: 'Edit',
          icon: Icons.edit_outlined,
          onTap: onEdit,
        ),
        ContextMenuAction(
          label: 'Add to shelf',
          icon: Icons.shelves,
          onTap: onAddToShelf,
        ),
        ContextMenuAction(
          label: 'Lend',
          icon: Icons.person_add_outlined,
          onTap: onLend,
        ),
        ContextMenuAction(
          label: 'Refresh metadata',
          icon: Icons.refresh,
          onTap: onRefreshMetadata,
        ),
        ContextMenuAction(
          label: 'Delete',
          icon: Icons.delete_outline,
          onTap: onDelete,
        ),
      ];

  /// Actions for a shelf list tile.
  static List<ContextMenuAction> forShelf({
    required VoidCallback onRename,
    required VoidCallback onDelete,
  }) =>
      [
        ContextMenuAction(
          label: 'Rename',
          icon: Icons.edit_outlined,
          onTap: onRename,
        ),
        ContextMenuAction(
          label: 'Delete',
          icon: Icons.delete_outline,
          onTap: onDelete,
        ),
      ];
}
