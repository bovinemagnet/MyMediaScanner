import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// Modal dialog shown after the user clicks Connect. Holds the
/// in-memory request token while the user approves in the browser
/// and exchanges it on Continue.
class TmdbConnectDialog extends ConsumerStatefulWidget {
  const TmdbConnectDialog({super.key});

  @override
  ConsumerState<TmdbConnectDialog> createState() =>
      _TmdbConnectDialogState();
}

class _TmdbConnectDialogState extends ConsumerState<TmdbConnectDialog> {
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(connectTmdbAccountUseCaseProvider).startConnect();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = await ref
        .read(connectTmdbAccountUseCaseProvider)
        .finishConnect();
    if (!mounted) return;
    if (state is TmdbConnected) {
      ref.read(tmdbAccountConnectionProvider.notifier).setState(state);
      Navigator.of(context).pop(state);
    } else if (state is TmdbConnectionError) {
      setState(() {
        _busy = false;
        _error = state.message;
      });
    }
  }

  Future<void> _reopen() async {
    await ref.read(connectTmdbAccountUseCaseProvider).reopenApproval();
  }

  void _cancel() {
    ref.read(connectTmdbAccountUseCaseProvider).cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect to TMDB'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We have opened TMDB in your browser. Sign in and approve '
            'MyMediaScanner, then come back and click Continue.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: _busy ? null : _reopen,
            child: const Text('Re-open page')),
        TextButton(
            onPressed: _busy ? null : _cancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy ? null : _continue,
          child: const Text("I've approved it — continue"),
        ),
      ],
    );
  }
}
