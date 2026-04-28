import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

enum TmdbDisconnectChoice { pushAndDisconnect, disconnectAnyway, cancel }

/// Three-button dialog shown when the user clicks Disconnect AND there
/// are dirty (un-pushed) bridge rows.
class TmdbDisconnectWarningDialog extends ConsumerStatefulWidget {
  const TmdbDisconnectWarningDialog({super.key, required this.dirtyCount});

  final int dirtyCount;

  @override
  ConsumerState<TmdbDisconnectWarningDialog> createState() =>
      _TmdbDisconnectWarningDialogState();
}

class _TmdbDisconnectWarningDialogState
    extends ConsumerState<TmdbDisconnectWarningDialog> {
  bool _busy = false;
  String? _message;

  Future<void> _pushAndDisconnect() async {
    setState(() {
      _busy = true;
      _message = 'Pushing pending changes…';
    });
    final summary =
        await ref.read(pushTmdbChangeUseCaseProvider).all();
    if (!mounted) return;
    if (summary.failed > 0) {
      setState(() {
        _busy = false;
        _message =
            'Push completed with ${summary.failed} failures. '
                'Disconnect anyway?';
      });
    } else {
      await ref.read(disconnectTmdbAccountUseCaseProvider).call();
      if (!mounted) return;
      await ref
          .read(tmdbAccountConnectionProvider.notifier)
          .refresh();
      if (mounted) {
        Navigator.of(context).pop(TmdbDisconnectChoice.pushAndDisconnect);
      }
    }
  }

  Future<void> _disconnectAnyway() async {
    setState(() {
      _busy = true;
      _message = 'Disconnecting…';
    });
    await ref.read(disconnectTmdbAccountUseCaseProvider).call();
    if (!mounted) return;
    await ref.read(tmdbAccountConnectionProvider.notifier).refresh();
    if (mounted) {
      Navigator.of(context).pop(TmdbDisconnectChoice.disconnectAnyway);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disconnect TMDB Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You have ${widget.dirtyCount} unsaved change'
              '${widget.dirtyCount == 1 ? '' : 's'} that '
              'have not been pushed to TMDB yet.'),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () =>
                  Navigator.of(context).pop(TmdbDisconnectChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _disconnectAnyway,
          child: const Text('Disconnect anyway'),
        ),
        FilledButton(
          onPressed: _busy ? null : _pushAndDisconnect,
          child: const Text('Push and disconnect'),
        ),
      ],
    );
  }
}
