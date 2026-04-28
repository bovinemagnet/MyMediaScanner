import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class TmdbResolveConflictsScreen extends ConsumerWidget {
  const TmdbResolveConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = PlatformCapability.isDesktop;
    final asyncRows = ref.watch(tmdbConflictedRowsProvider);

    Widget body = asyncRows.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No conflicts to resolve.',
                  textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) => _ConflictRow(item: rows[i]),
        );
      },
    );

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const Text('Resolve Conflicts')),
      body: isDesktop
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenHeader(title: 'Resolve Conflicts'),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

class _ConflictRow extends ConsumerWidget {
  const _ConflictRow({required this.item});
  final TmdbBridgeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.title ?? '#${item.tmdbId}'),
      subtitle: Text('Media type: ${item.mediaType}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        OutlinedButton(
          onPressed: () async {
            await ref
                .read(resolveTmdbConflictUseCaseProvider)
                .keepMine(
                    tmdbId: item.tmdbId, mediaType: item.mediaType);
          },
          child: const Text('Keep mine'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () async {
            await ref
                .read(resolveTmdbConflictUseCaseProvider)
                .useTmdb(
                    tmdbId: item.tmdbId, mediaType: item.mediaType);
          },
          child: const Text('Use TMDB'),
        ),
      ]),
    );
  }
}
