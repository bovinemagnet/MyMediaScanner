import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// TMDB-account list entries surfaced in the Settings screen.
///
/// Renders three route tiles (Watchlist / Rated / Favourites) when
/// connected, plus a fourth Resolve-Conflicts tile when the user has
/// chosen the ask-user conflict policy and there are conflicts pending.
///
/// Cross-platform: this is the mobile entry point for the bucket views,
/// and on desktop it complements the existing sidebar entries.
class TmdbListsSection extends ConsumerWidget {
  const TmdbListsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(tmdbAccountConnectionProvider);
    final isConnected = connectionAsync.value is TmdbConnected;
    if (!isConnected) return const SizedBox.shrink();

    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    final conflictsCount = ref.watch(tmdbConflictedRowsProvider).maybeWhen(
          data: (rows) => rows.length,
          orElse: () => 0,
        );
    final showConflicts =
        settings.conflictPolicy == TmdbConflictPolicy.askUser &&
            conflictsCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('TMDB Lists',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('TMDB Watchlist'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => GoRouter.of(context).go('/tmdb/watchlist'),
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('TMDB Rated'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => GoRouter.of(context).go('/tmdb/rated'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('TMDB Favourites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => GoRouter.of(context).go('/tmdb/favourites'),
          ),
          if (showConflicts)
            ListTile(
              leading: Icon(Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Resolve Conflicts ($conflictsCount)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => GoRouter.of(context).go('/tmdb/conflicts'),
            ),
        ],
      ),
    );
  }
}
