// Progress dialog for the batch "Fetch missing covers" sweep.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/fetch_missing_cover_usecase.dart';
import 'package:mymediascanner/domain/usecases/fill_missing_covers_usecase.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Shows the fill-covers progress dialog and kicks the sweep off. The
/// caller should refresh any stale collection views after the future
/// returned by [showFillMissingCoversDialog] completes.
Future<void> showFillMissingCoversDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final usecase = FillMissingCoversUseCase(
    mediaItemRepository: ref.read(mediaItemRepositoryProvider),
    fetchCover: FetchMissingCoverUseCase(
      metadataRepository: ref.read(metadataRepositoryProvider),
      mediaItemRepository: ref.read(mediaItemRepositoryProvider),
    ),
  );

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FillCoversDialog(usecase: usecase),
  );

  // Re-read the collection stream so cover thumbnails update.
  ref.invalidate(collectionProvider);
}

class _FillCoversDialog extends StatefulWidget {
  const _FillCoversDialog({required this.usecase});

  final FillMissingCoversUseCase usecase;

  @override
  State<_FillCoversDialog> createState() => _FillCoversDialogState();
}

class _FillCoversDialogState extends State<_FillCoversDialog> {
  StreamSubscription<FillCoversProgress>? _sub;
  FillCoversProgress? _progress;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.usecase.execute().listen(
      (p) {
        if (!mounted) return;
        setState(() => _progress = p);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _done = true);
      },
      onError: (Object err) {
        if (!mounted) return;
        setState(() => _done = true);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    widget.usecase.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    final colors = Theme.of(context).colorScheme;

    if (p == null) {
      return const AlertDialog(
        title: Text('Fetching cover art'),
        content: SizedBox(
          height: 64,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (p.total == 0) {
      return AlertDialog(
        title: const Text('Fetch cover art'),
        content: const Text(
          'Every item in your collection already has a cover — nothing to do.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final finished = _done || p.isDone;
    final title = finished
        ? (p.cancelled ? 'Cover fetch cancelled' : 'Cover fetch complete')
        : 'Fetching cover art';

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: p.fraction),
          const SizedBox(height: 12),
          Text(
            finished
                ? '${p.processed} of ${p.total} items processed'
                : 'Processed ${p.processed} of ${p.total}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Updated: ${p.updated}   ·   Not found: ${p.notFound}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (!finished && p.currentTitle != null) ...[
            const SizedBox(height: 8),
            Text(
              'Current: ${p.currentTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
      actions: [
        if (!finished)
          TextButton(
            onPressed: () {
              widget.usecase.cancel();
            },
            child: const Text('Cancel'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}
