import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/import_tmdb_account_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class TmdbImportDialog extends ConsumerStatefulWidget {
  const TmdbImportDialog({super.key});

  @override
  ConsumerState<TmdbImportDialog> createState() =>
      _TmdbImportDialogState();
}

class _TmdbImportDialogState extends ConsumerState<TmdbImportDialog> {
  final _selected = ImportTmdbAccountUseCase.allBuckets().toSet();
  bool _busy = false;
  int _pulled = 0;
  int _failed = 0;

  void _toggle(TmdbBucketSelection sel, bool value) {
    setState(() {
      if (value) {
        _selected.add(sel);
      } else {
        _selected.remove(sel);
      }
    });
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _pulled = 0;
      _failed = 0;
    });
    final summary =
        await ref.read(importTmdbAccountUseCaseProvider).call(
              selectedBuckets: _selected,
              progress: (pulled, failed) {
                if (mounted) {
                  setState(() {
                    _pulled = pulled;
                    _failed = failed;
                  });
                }
              },
            );
    await ref
        .read(tmdbAccountSyncSettingsProvider.notifier)
        .recordSyncResult(
          pulled: summary.pulled,
          failed: summary.failed,
          error: summary.lastError,
        );
    if (mounted) Navigator.of(context).pop(summary);
  }

  Widget _checkbox(
      String label, TmdbBridgeBucket bucket, String mediaType) {
    final sel =
        TmdbBucketSelection(bucket: bucket, mediaType: mediaType);
    return CheckboxListTile(
      value: _selected.contains(sel),
      onChanged: _busy ? null : (v) => _toggle(sel, v ?? false),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import from TMDB'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pick which lists to import. Items will not be added '
              'to your local collection grid; they will appear in the '
              'TMDB Watchlist / Rated / Favourites views.'),
          const SizedBox(height: 12),
          _checkbox('Rated movies', TmdbBridgeBucket.rated, 'movie'),
          _checkbox('Rated TV', TmdbBridgeBucket.rated, 'tv'),
          _checkbox('Watchlist movies', TmdbBridgeBucket.watchlist, 'movie'),
          _checkbox('Watchlist TV', TmdbBridgeBucket.watchlist, 'tv'),
          _checkbox('Favourite movies', TmdbBridgeBucket.favourite, 'movie'),
          _checkbox('Favourite TV', TmdbBridgeBucket.favourite, 'tv'),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text('Pulled $_pulled, failed $_failed'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy || _selected.isEmpty ? null : _run,
          child: const Text('Import'),
        ),
      ],
    );
  }
}
