import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

/// Radio group for picking the TMDB conflict resolution policy.
class ConflictPolicySelector extends ConsumerWidget {
  const ConflictPolicySelector({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(tmdbAccountSyncSettingsProvider).conflictPolicy;
    final notifier = ref.read(tmdbAccountSyncSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When local and TMDB both changed:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        RadioGroup<TmdbConflictPolicy>(
          groupValue: policy,
          onChanged: (v) {
            if (enabled && v != null) notifier.setConflictPolicy(v);
          },
          child: Column(
            children: [
              for (final p in TmdbConflictPolicy.values)
                RadioListTile<TmdbConflictPolicy>(
                  value: p,
                  title: Text(_label(p)),
                  subtitle: Text(
                    _subtitle(p),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _label(TmdbConflictPolicy p) => switch (p) {
        TmdbConflictPolicy.preferLatestTimestamp => 'Prefer latest timestamp',
        TmdbConflictPolicy.preferLocal => 'Prefer local',
        TmdbConflictPolicy.preferTmdb => 'Prefer TMDB',
        TmdbConflictPolicy.askUser => 'Ask me each time',
      };

  String _subtitle(TmdbConflictPolicy p) => switch (p) {
        TmdbConflictPolicy.preferLatestTimestamp =>
          'Whichever side was edited most recently wins.',
        TmdbConflictPolicy.preferLocal =>
          'Local edits in MyMediaScanner always win.',
        TmdbConflictPolicy.preferTmdb =>
          'TMDB always wins; pulls overwrite local edits.',
        TmdbConflictPolicy.askUser =>
          'Conflicts surface in the Resolve Conflicts screen.',
      };
}
