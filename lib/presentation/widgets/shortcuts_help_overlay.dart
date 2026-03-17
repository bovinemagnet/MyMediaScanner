import 'package:flutter/material.dart';

/// Modal dialog listing all available desktop keyboard shortcuts.
class ShortcutsHelpOverlay extends StatelessWidget {
  const ShortcutsHelpOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keyboard Shortcuts'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionHeader(context, 'Global'),
              _shortcutRow('Ctrl+N', 'Open Scan screen'),
              _shortcutRow('Ctrl+F', 'Focus search bar'),
              _shortcutRow('Ctrl+,', 'Open Settings'),
              _shortcutRow('F1', 'Show this help'),
              _shortcutRow('Escape', 'Close panel / clear input'),
              const SizedBox(height: 16),
              _sectionHeader(context, 'Collection'),
              _shortcutRow('\u2190 \u2191 \u2192 \u2193', 'Navigate items'),
              _shortcutRow('Enter', 'Open selected item'),
              _shortcutRow('Delete', 'Delete selected item'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _shortcutRow(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
