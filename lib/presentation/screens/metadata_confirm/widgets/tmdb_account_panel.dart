import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';

/// Account-state panel shown on the metadata-confirm screen when a
/// TMDB account bridge row exists for the resolved title.
///
/// Cross-platform: gated only by `accountSyncEnabled`, not by
/// `PlatformCapability.isDesktop`.
class TmdbAccountPanel extends StatelessWidget {
  const TmdbAccountPanel({
    super.key,
    required this.bridge,
    required this.localRating,
    required this.onApplyRating,
  });

  final TmdbBridgeItem bridge;
  final double? localRating;
  final void Function(double newLocalRating) onApplyRating;

  @override
  Widget build(BuildContext context) {
    final tmdbLocal = bridge.localRating;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.cloud_done, size: 18),
              const SizedBox(width: 6),
              Text(
                'Your TMDB account state',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ]),
            const SizedBox(height: 8),
            if (tmdbLocal != null)
              Row(children: [
                Text('TMDB rating: ${tmdbLocal.toStringAsFixed(1)} / 5'),
                const SizedBox(width: 8),
                if (localRating == null)
                  TextButton(
                    onPressed: () => onApplyRating(tmdbLocal),
                    child: const Text('Apply to local rating'),
                  ),
              ]),
            Wrap(spacing: 8, children: [
              if (bridge.watchlist)
                const Chip(
                  avatar: Icon(Icons.bookmark, size: 16),
                  label: Text('Watchlist'),
                ),
              if (bridge.favorite)
                const Chip(
                  avatar: Icon(Icons.favorite, size: 16),
                  label: Text('Favourite'),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
