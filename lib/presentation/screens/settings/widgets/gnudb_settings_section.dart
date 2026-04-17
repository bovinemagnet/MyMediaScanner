/// Settings form for the GnuDB integration.
///
/// GnuDB does not use an API key — it identifies clients via a
/// "hello" string containing the user's name and the application
/// name/version. This form lets the user customise the first part.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class GnudbSettingsSection extends ConsumerStatefulWidget {
  const GnudbSettingsSection({super.key});

  @override
  ConsumerState<GnudbSettingsSection> createState() =>
      _GnudbSettingsSectionState();
}

class _GnudbSettingsSectionState
    extends ConsumerState<GnudbSettingsSection> {
  late final TextEditingController _controller;
  String? _lastApplied;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(gnudbUsernameProvider);
    if (_lastApplied != current) {
      _controller.text = current;
      _lastApplied = current;
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GnuDB username',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Identifies you to the gnudb.org CDDB server. The default is '
            'fine; change it only if you have a reason.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'mymediascanner',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(gnudbUsernameProvider.notifier)
                      .setUsername(_controller.text);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('GnuDB username saved')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
