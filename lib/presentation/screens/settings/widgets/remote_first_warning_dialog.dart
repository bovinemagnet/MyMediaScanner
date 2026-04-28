import 'package:flutter/material.dart';

/// First-flip-on confirmation dialog for the "Allow remote-first save"
/// settings toggle. Returns `true` when the user confirms, `false` on
/// cancel.
class RemoteFirstWarningDialog extends StatelessWidget {
  const RemoteFirstWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable remote-first save?'),
      content: const Text(
        'TMDB can store your ratings, favourites, watchlist and list '
        'memberships, but it cannot store MyMediaScanner collection '
        'details such as barcode, shelf, location, purchase details, '
        'lending, tags, reviews, or scan history. In remote-first '
        'mode these details are not kept locally and may be '
        'unavailable offline.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Enable anyway'),
        ),
      ],
    );
  }
}
