import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

/// Coverage status for a music item.
enum CoverageStatus { notRipped, partiallyRipped, fullyRipped, qualityIssues }

/// Provider that watches all music items from the collection.
final _musicItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref
      .watch(mediaItemRepositoryProvider)
      .watchAll(mediaType: MediaType.music);
});

/// Displays rip coverage across the music collection.
class RipCoverageView extends ConsumerStatefulWidget {
  const RipCoverageView({super.key});

  @override
  ConsumerState<RipCoverageView> createState() => _RipCoverageViewState();
}

class _RipCoverageViewState extends ConsumerState<RipCoverageView> {
  Set<CoverageStatus> _activeFilters = {};

  @override
  Widget build(BuildContext context) {
    final musicAsync = ref.watch(_musicItemsProvider);
    final albumsAsync = ref.watch(allRipAlbumsProvider);

    return musicAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(_musicItemsProvider),
      ),
      data: (musicItems) {
        return albumsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(allRipAlbumsProvider),
          ),
          data: (ripAlbums) {
            final categorised = _categorise(musicItems, ripAlbums);
            final filtered = _activeFilters.isEmpty
                ? categorised
                : categorised
                    .where((e) => _activeFilters.contains(e.status))
                    .toList();

            final rippedCount = categorised
                .where((e) =>
                    e.status == CoverageStatus.fullyRipped ||
                    e.status == CoverageStatus.qualityIssues)
                .length;

            final pct = musicItems.isEmpty
                ? 0
                : (rippedCount * 100 / musicItems.length).round();

            return Column(
              children: [
                _SummaryBar(
                  rippedCount: rippedCount,
                  totalCount: musicItems.length,
                  percentage: pct,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Wrap(
                    spacing: 8,
                    children: CoverageStatus.values.map((status) {
                      return FilterChip(
                        label: Text(_statusLabel(status)),
                        avatar: Icon(_statusIcon(status),
                            size: 16, color: _statusColour(status)),
                        selected: _activeFilters.contains(status),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _activeFilters = {..._activeFilters, status};
                            } else {
                              _activeFilters = {..._activeFilters}
                                ..remove(status);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No items match the current filters.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            return _CoverageItemTile(entry: entry);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_CoverageEntry> _categorise(
    List<MediaItem> items,
    List<RipAlbum> albums,
  ) {
    final albumByMediaId = <String, RipAlbum>{};
    for (final album in albums) {
      if (album.mediaItemId != null) {
        albumByMediaId[album.mediaItemId!] = album;
      }
    }

    return items.map((item) {
      final linked = albumByMediaId[item.id];
      if (linked == null) {
        return _CoverageEntry(
          item: item,
          ripAlbum: null,
          status: CoverageStatus.notRipped,
        );
      }

      // Check track count from extraMetadata
      final trackListing = item.extraMetadata['track_listing'];
      final expectedTracks = trackListing is List ? trackListing.length : 0;
      final actualTracks = linked.trackCount;

      final fullyRipped =
          expectedTracks == 0 || actualTracks >= expectedTracks;

      if (!fullyRipped) {
        return _CoverageEntry(
          item: item,
          ripAlbum: linked,
          status: CoverageStatus.partiallyRipped,
        );
      }

      // Check for quality issues (we'll refine this with track data later)
      return _CoverageEntry(
        item: item,
        ripAlbum: linked,
        status: CoverageStatus.fullyRipped,
      );
    }).toList()
      ..sort((a, b) => a.status.index.compareTo(b.status.index));
  }
}

class _CoverageEntry {
  const _CoverageEntry({
    required this.item,
    required this.ripAlbum,
    required this.status,
  });

  final MediaItem item;
  final RipAlbum? ripAlbum;
  final CoverageStatus status;
}

String _statusLabel(CoverageStatus status) {
  switch (status) {
    case CoverageStatus.notRipped:
      return 'Not ripped';
    case CoverageStatus.partiallyRipped:
      return 'Partially ripped';
    case CoverageStatus.fullyRipped:
      return 'Fully ripped';
    case CoverageStatus.qualityIssues:
      return 'Quality issues';
  }
}

IconData _statusIcon(CoverageStatus status) {
  switch (status) {
    case CoverageStatus.notRipped:
      return Icons.cancel;
    case CoverageStatus.partiallyRipped:
      return Icons.timelapse;
    case CoverageStatus.fullyRipped:
      return Icons.check_circle;
    case CoverageStatus.qualityIssues:
      return Icons.warning;
  }
}

Color _statusColour(CoverageStatus status) {
  switch (status) {
    case CoverageStatus.notRipped:
      return Colors.red;
    case CoverageStatus.partiallyRipped:
      return Colors.amber;
    case CoverageStatus.fullyRipped:
      return Colors.green;
    case CoverageStatus.qualityIssues:
      return Colors.amber;
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.rippedCount,
    required this.totalCount,
    required this.percentage,
  });

  final int rippedCount;
  final int totalCount;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.album, size: 32, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$rippedCount of $totalCount CDs ripped ($percentage%)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? rippedCount / totalCount : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoverageItemTile extends ConsumerWidget {
  const _CoverageItemTile({required this.entry});

  final _CoverageEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check track quality for linked albums
    final hasQualityIssues = _checkQualityIssues(ref);
    final effectiveStatus =
        hasQualityIssues ? CoverageStatus.qualityIssues : entry.status;

    return ListTile(
      leading: Icon(
        _statusIcon(effectiveStatus),
        color: _statusColour(effectiveStatus),
      ),
      title: Text(entry.item.title),
      subtitle: Text(entry.item.subtitle ?? ''),
      trailing: entry.ripAlbum != null
          ? Text('${entry.ripAlbum!.trackCount} tracks')
          : null,
      onTap: () => context.go('/item/${entry.item.id}'),
    );
  }

  bool _checkQualityIssues(WidgetRef ref) {
    if (entry.ripAlbum == null) return false;
    if (entry.status != CoverageStatus.fullyRipped) return false;

    final tracksAsync = ref.watch(ripTracksProvider(entry.ripAlbum!.id));
    final tracks = tracksAsync.whenOrNull(data: (t) => t) ?? [];
    if (tracks.isEmpty) return false;

    // Only flag quality issues if analysis has been run
    final anyChecked = tracks.any((t) => t.qualityCheckedAt != null);
    if (!anyChecked) return false;

    return tracks.any((t) =>
        t.accurateRipStatus == 'mismatch' || (t.clickCount ?? 0) > 0);
  }
}
