import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class TmdbBucketScreen extends ConsumerWidget {
  const TmdbBucketScreen({super.key, required this.bucket});

  final TmdbBridgeBucket bucket;

  String get _title => switch (bucket) {
        TmdbBridgeBucket.watchlist => 'TMDB Watchlist',
        TmdbBridgeBucket.rated => 'TMDB Rated',
        TmdbBridgeBucket.favourite => 'TMDB Favourites',
        TmdbBridgeBucket.saved => 'TMDB Saved',
      };

  String get _emptyMessage => switch (bucket) {
        TmdbBridgeBucket.watchlist =>
          'Nothing on your TMDB watchlist yet. Add titles on themoviedb.org '
              'and they will appear here after the next sync.',
        TmdbBridgeBucket.rated =>
          'No TMDB ratings yet. Rate titles on themoviedb.org and run a '
              'sync.',
        TmdbBridgeBucket.favourite =>
          'No TMDB favourites yet. Mark some on themoviedb.org and run a '
              'sync.',
        TmdbBridgeBucket.saved =>
          'No remote-first saves yet. When you save a movie or TV title as '
              'TMDB only, it will appear here.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRows = ref.watch(tmdbBridgeBucketProvider(bucket));
    final isDesktop = PlatformCapability.isDesktop;

    Widget body = asyncRows.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_emptyMessage, textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) =>
              _BridgeRowTile(item: rows[i], bucket: bucket),
        );
      },
    );

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: Text(_title)),
      body: isDesktop
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(title: _title),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

class _BridgeRowTile extends ConsumerWidget {
  const _BridgeRowTile({required this.item, required this.bucket});
  final TmdbBridgeItem item;
  final TmdbBridgeBucket bucket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = Uri.parse(
        'https://www.themoviedb.org/${item.mediaType}/${item.tmdbId}');
    final mediaTypeLabel = item.mediaType == 'tv' ? 'TV' : 'Movie';
    final ratingLabel =
        bucket == TmdbBridgeBucket.rated && item.localRating != null
            ? ' • ★${item.localRating!.toStringAsFixed(1)}'
            : '';
    return ListTile(
      leading: item.posterPath == null
          ? const SizedBox(width: 56)
          : Image.network(
              'https://image.tmdb.org/t/p/w92${item.posterPath}',
              width: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(width: 56, child: Icon(Icons.image)),
            ),
      title: Text(item.title ?? '#${item.tmdbId}'),
      subtitle: Text('$mediaTypeLabel$ratingLabel'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (bucket == TmdbBridgeBucket.watchlist) ...[
          IconButton(
            tooltip: 'Mark as owned',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final mirrorEnabled = ref
                  .read(tmdbAccountSyncSettingsProvider)
                  .mirrorOwnership;
              final result = await ref
                  .read(markTmdbWatchlistOwnedUseCaseProvider)
                  .call(
                    bridgeId: item.id,
                    tmdbId: item.tmdbId,
                    mediaType: item.mediaType,
                    mirrorEnabled: mirrorEnabled,
                  );
              if (result.fullSuccess) {
                messenger.showSnackBar(const SnackBar(
                    content: Text('Marked as owned and removed from watchlist')));
              } else {
                final issues = [
                  if (result.convertError != null) 'convert: ${result.convertError}',
                  if (result.watchlistError != null)
                    'watchlist: ${result.watchlistError}',
                  if (result.mirrorError != null) 'mirror: ${result.mirrorError}',
                ].join('; ');
                messenger.showSnackBar(SnackBar(
                    content: Text('Partial success — $issues')));
              }
            },
          ),
          IconButton(
            tooltip: 'Remove from TMDB watchlist',
            icon: const Icon(Icons.bookmark_remove),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await ref
                  .read(toggleTmdbWatchlistUseCaseProvider)
                  .call(
                    tmdbId: item.tmdbId,
                    mediaType: item.mediaType,
                    value: false,
                  );
              messenger.showSnackBar(SnackBar(
                content: Text(result.success
                    ? 'Removed from TMDB watchlist'
                    : 'Remove failed: ${result.error}'),
              ));
            },
          ),
        ],
        IconButton(
          tooltip: 'Open on TMDB',
          icon: const Icon(Icons.open_in_new),
          onPressed: () => launchUrl(url,
              mode: LaunchMode.externalApplication),
        ),
        IconButton(
          tooltip: 'Convert to local item',
          icon: const Icon(Icons.add_box_outlined),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ref
                  .read(convertBridgeToLocalItemUseCaseProvider)
                  .call(item.id);
              messenger.showSnackBar(
                  const SnackBar(content: Text('Added to local collection')));
            } catch (e) {
              messenger.showSnackBar(
                  SnackBar(content: Text('Could not convert item: $e')));
            }
          },
        ),
      ]),
    );
  }
}
