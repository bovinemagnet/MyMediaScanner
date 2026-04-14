import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';

/// Shows the duplicate warning dialog.
///
/// Returns `true` if the user confirms "save anyway" (different edition),
/// `false` if the user cancels, and `null` if the dialog is dismissed
/// (e.g. barrier tap).
Future<bool?> showDuplicateWarningDialog(
  BuildContext context,
  DuplicateMatch match,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => DuplicateWarningDialog(match: match),
  );
}

class DuplicateWarningDialog extends StatelessWidget {
  const DuplicateWarningDialog({super.key, required this.match});

  final DuplicateMatch match;

  String get _heading => switch (match.kind) {
        DuplicateKind.exactBarcode => 'Possible duplicate',
        DuplicateKind.fuzzyTitle => 'Possible duplicate',
        DuplicateKind.none => 'Possible duplicate',
      };

  String get _subhead => switch (match.kind) {
        DuplicateKind.exactBarcode =>
          'An item with the same barcode is already in your collection.',
        DuplicateKind.fuzzyTitle =>
          'An item with a very similar title and year already exists.',
        DuplicateKind.none => '',
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_heading),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_subhead),
            const SizedBox(height: 12),
            ...match.candidates.map(_CandidateCard.new),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Different edition — save anyway'),
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard(this.item);
  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 56,
            child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                ? Image.network(item.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: theme.colorScheme.surfaceContainerHigh))
                : Container(color: theme.colorScheme.surfaceContainerHigh),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (item.year != null)
                  Text('${item.year}',
                      style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
