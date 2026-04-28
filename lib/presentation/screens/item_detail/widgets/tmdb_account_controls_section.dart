import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// Item-detail section for TMDB account state. Cross-platform.
/// Visible when:
///   - accountSyncEnabled is true
///   - the item has a tmdb_id and movie/tv media type
class TmdbAccountControlsSection extends ConsumerWidget {
  const TmdbAccountControlsSection({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  final int tmdbId;
  final String mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    if (!settings.enabled) return const SizedBox.shrink();

    final bridgeAsync = ref.watch(
        tmdbBridgeForIdProvider((tmdbId: tmdbId, mediaType: mediaType)));
    return bridgeAsync.maybeWhen(
      data: (bridge) {
        if (bridge == null) return const SizedBox.shrink();
        return _buildSection(context, ref, settings, bridge);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    TmdbAccountSyncSettings settings,
    TmdbBridgeItem bridge,
  ) {
    final pushEnabled = settings.twoWaySync;
    final isDirty = bridge.lastError == null && bridge.lastPulledAt == null;
    final pending = bridge.lastError != null
        ? '⚠ Push failed — tap to retry'
        : (isDirty ? '⏳ Syncing…' : null);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.cloud_done, size: 18),
              const SizedBox(width: 6),
              Text('TMDB Account',
                  style: Theme.of(context).textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            if (bridge.localRating != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    'TMDB rating: ${bridge.localRating!.toStringAsFixed(1)} / 5'),
              ),
            Wrap(spacing: 8, runSpacing: 4, children: [
              FilterChip(
                label: const Text('Watchlist'),
                avatar: Icon(
                    bridge.watchlist
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    size: 16),
                selected: bridge.watchlist,
                onSelected: pushEnabled
                    ? (v) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(toggleTmdbWatchlistUseCaseProvider)
                            .call(
                                tmdbId: tmdbId,
                                mediaType: mediaType,
                                value: v);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Watchlist push failed: ${result.error}')));
                        }
                      }
                    : null,
              ),
              FilterChip(
                label: const Text('Favourite'),
                avatar: Icon(
                    bridge.favorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 16),
                selected: bridge.favorite,
                onSelected: pushEnabled
                    ? (v) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(toggleTmdbFavoriteUseCaseProvider)
                            .call(
                                tmdbId: tmdbId,
                                mediaType: mediaType,
                                value: v);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Favourite push failed: ${result.error}')));
                        }
                      }
                    : null,
              ),
            ]),
            if (pending != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: bridge.lastError != null
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(pushTmdbChangeUseCaseProvider)
                            .call(tmdbId: tmdbId, mediaType: mediaType);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Retry failed: ${result.error}')));
                        }
                      }
                    : null,
                child: Text(pending,
                    style: TextStyle(
                        color: bridge.lastError != null
                            ? Theme.of(context).colorScheme.error
                            : null)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
