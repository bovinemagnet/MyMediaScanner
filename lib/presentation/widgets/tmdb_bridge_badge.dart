import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// A tiny TMDB icon badge used as a cover overlay (`size: small`)
/// or as a horizontal strip on the item-detail screen (`size: detailStrip`).
///
/// Cross-platform — gated only on bridge-row presence, not on
/// `PlatformCapability.isDesktop`.
class TmdbBridgeBadge extends ConsumerWidget {
  const TmdbBridgeBadge({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    this.size = TmdbBridgeBadgeSize.small,
  });

  final int tmdbId;
  final String mediaType;
  final TmdbBridgeBadgeSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBridge = ref.watch(
      tmdbBridgeForIdProvider((tmdbId: tmdbId, mediaType: mediaType)),
    );
    return asyncBridge.maybeWhen(
      data: (b) => b == null ? const SizedBox.shrink() : _build(b, context),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _build(TmdbBridgeItem b, BuildContext context) {
    if (size == TmdbBridgeBadgeSize.small) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'TMDB',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      children: [
        if (b.localRating != null)
          Chip(
            avatar: const Icon(Icons.star, size: 16),
            label: Text('TMDB ${b.localRating!.toStringAsFixed(1)} / 5'),
          ),
        if (b.watchlist)
          const Chip(
            avatar: Icon(Icons.bookmark, size: 16),
            label: Text('Watchlist'),
          ),
        if (b.favorite)
          const Chip(
            avatar: Icon(Icons.favorite, size: 16),
            label: Text('Favourite'),
          ),
      ],
    );
  }
}

enum TmdbBridgeBadgeSize { small, detailStrip }
