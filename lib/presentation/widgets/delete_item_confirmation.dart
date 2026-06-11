/// Shared delete-item confirmation dialog.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';

/// Shows a confirmation dialog asking whether to delete an item from
/// the collection.
///
/// Returns `true` when the user confirms deletion, `false` when the
/// user cancels or dismisses the dialog.
Future<bool> showDeleteItemConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete item?'),
      content: const Text('This item will be removed from your collection.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
