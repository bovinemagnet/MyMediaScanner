import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/app/theme/app_layout_extension.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/fetch_missing_cover_usecase.dart';
import 'package:mymediascanner/domain/usecases/manage_rips_usecase.dart';
import 'package:mymediascanner/domain/usecases/refresh_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/return_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/notification_provider.dart';
import 'package:mymediascanner/presentation/widgets/overdue_badge.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/selected_rip_album_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/shelf_picker_dialog.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/borrower_picker_dialog.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/cover_art_hero.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/metadata_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/purchase_info_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/location_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/progress_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/tag_chips.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart';
import 'package:mymediascanner/presentation/widgets/tmdb_bridge_badge.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(mediaItemProvider(itemId));

    return itemAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (item) {
        if (item == null) {
          return const Scaffold(body: ErrorState(message: 'Item not found'));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(item.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.shelves),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ShelfPickerDialog(mediaItemId: item.id),
                ),
                tooltip: 'Add to shelf',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshMetadata(context, ref, item),
                tooltip: 'Refresh metadata',
              ),
              if (item.coverUrl == null || item.coverUrl!.isEmpty)
                IconButton(
                  icon: const Icon(Icons.image_search),
                  onPressed: () => _fetchMissingCover(context, ref, item),
                  tooltip: 'Fetch cover art',
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/collection/item/${item.id}/edit'),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GradientHeroBackdrop(
                    mediaType: item.mediaType,
                    child: Center(
                      child: CoverArtHero(
                        imageUrl: item.coverUrl,
                        tag: 'cover-${item.id}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (item.subtitle != null)
                    Center(
                      child: Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: StarRatingWidget(
                      rating: item.userRating ?? 0,
                      onChanged: (rating) async {
                        try {
                          await UpdateRatingUseCase(
                            repository: ref.read(mediaItemRepositoryProvider),
                          ).execute(item.id, rating: rating);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update rating: $e'),
                              ),
                            );
                          }
                        }
                        ref.invalidate(mediaItemProvider(itemId));
                      },
                    ),
                  ),
                  if (item.criticScore != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reviews_outlined,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.criticScore!.toStringAsFixed(1)}/10',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.criticSource ?? '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  () {
                    final tmdbId = item.extraMetadata['tmdb_id'];
                    final mediaType = item.extraMetadata['media_type'];
                    if (tmdbId is int &&
                        (mediaType == 'movie' || mediaType == 'tv')) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: TmdbBridgeBadge(
                          tmdbId: tmdbId,
                          mediaType: mediaType as String,
                          size: TmdbBridgeBadgeSize.detailStrip,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }(),
                  () {
                    final tmdbId = item.extraMetadata['tmdb_id'];
                    final mediaType = item.extraMetadata['media_type'];
                    if (tmdbId is int &&
                        (mediaType == 'movie' || mediaType == 'tv')) {
                      return TmdbAccountControlsSection(
                        tmdbId: tmdbId,
                        mediaType: mediaType as String,
                      );
                    }
                    return const SizedBox.shrink();
                  }(),
                  TagChips(mediaItemId: item.id),
                  if (item.userReview != null &&
                      item.userReview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(item.userReview!),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PurchaseInfoSection(
                    item: item,
                    onChanged: (updated) async {
                      try {
                        await ref
                            .read(mediaItemRepositoryProvider)
                            .update(
                              updated.copyWith(
                                updatedAt:
                                    DateTime.now().millisecondsSinceEpoch,
                              ),
                            );
                        ref.invalidate(mediaItemProvider(itemId));
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save purchase info: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  LocationSection(item: item),
                  const SizedBox(height: 16),
                  ProgressSection(item: item),
                  const SizedBox(height: 16),
                  _LendingSection(mediaItemId: item.id),
                  if (item.mediaType == MediaType.music) ...[
                    const SizedBox(height: 16),
                    _RipStatusSection(item: item),
                  ],
                  const SizedBox(height: 16),
                  MetadataSection(item: item),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshMetadata(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Refreshing metadata\u2026')));
    try {
      await RefreshMetadataUseCase(
        metadataRepository: ref.read(metadataRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      ).execute(item);
      ref.invalidate(mediaItemProvider(itemId));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Metadata refreshed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Failed to refresh metadata: $e')),
          );
      }
    }
  }

  Future<void> _fetchMissingCover(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Searching for cover art\u2026')),
    );
    try {
      final outcome = await FetchMissingCoverUseCase(
        metadataRepository: ref.read(metadataRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      ).execute(item);
      ref.invalidate(mediaItemProvider(itemId));
      if (!context.mounted) return;
      final message = switch (outcome) {
        FetchCoverOutcome.updated => 'Cover art updated',
        FetchCoverOutcome.notFound => 'No cover art found',
        FetchCoverOutcome.alreadyHasCover => 'Item already has a cover',
      };
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to fetch cover: $e')),
        );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This item will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await DeleteMediaItemUseCase(
                repository: ref.read(mediaItemRepositoryProvider),
              ).execute(itemId);
              if (context.mounted) {
                Navigator.pop(ctx);
                context.go('/collection');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LendingSection extends ConsumerWidget {
  const _LendingSection({required this.mediaItemId});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLoanAsync = ref.watch(activeLoanForItemProvider(mediaItemId));
    final loansHistoryAsync = ref.watch(loansForItemProvider(mediaItemId));
    final allBorrowersAsync = ref.watch(allBorrowersProvider);
    final dateFormat = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lending', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        activeLoanAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (activeLoan) {
            if (activeLoan == null) {
              return FilledButton.tonal(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      BorrowerPickerDialog(mediaItemId: mediaItemId),
                ),
                child: const Text('Lend'),
              );
            }

            // Find borrower name
            final borrowers = allBorrowersAsync.value ?? [];
            final borrower = borrowers
                .where((b) => b.id == activeLoan.borrowerId)
                .firstOrNull;
            final borrowerName = borrower?.name ?? 'Unknown';
            final lentDate = dateFormat.format(
              DateTime.fromMillisecondsSinceEpoch(activeLoan.lentAt),
            );

            final loanColors = Theme.of(context).colorScheme;
            return Card(
              color: loanColors.tertiaryContainer.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: loanColors.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lent to $borrowerName',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Since $lentDate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (activeLoan.dueAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Due: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(activeLoan.dueAt!))}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (activeLoan.isOverdue)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: OverdueBadge(
                                daysOverdue: activeLoan.daysOverdue,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.tonal(
                          onPressed: () async {
                            try {
                              await ReturnItemUseCase(
                                repository: ref.read(loanRepositoryProvider),
                                notificationService: ref.read(
                                  notificationServiceProvider,
                                ),
                              ).execute(activeLoan.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to return item: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Return'),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: activeLoan.dueAt != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      activeLoan.dueAt!,
                                    )
                                  : DateTime.now().add(
                                      const Duration(days: 14),
                                    ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              helpText: 'Extend due date',
                            );
                            if (picked != null) {
                              await ref
                                  .read(loanRepositoryProvider)
                                  .updateDueDate(
                                    activeLoan.id,
                                    picked.millisecondsSinceEpoch,
                                  );
                            }
                          },
                          child: Text(
                            activeLoan.dueAt != null
                                ? 'Extend'
                                : 'Set due date',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Lending history
        loansHistoryAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (loans) {
            final pastLoans = loans.where((l) => l.returnedAt != null).toList();
            if (pastLoans.isEmpty) return const SizedBox.shrink();

            final borrowers = allBorrowersAsync.value ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('History', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                ...pastLoans.map((loan) {
                  final borrower = borrowers
                      .where((b) => b.id == loan.borrowerId)
                      .firstOrNull;
                  final name = borrower?.name ?? 'Unknown';
                  final lent = dateFormat.format(
                    DateTime.fromMillisecondsSinceEpoch(loan.lentAt),
                  );
                  final returned = dateFormat.format(
                    DateTime.fromMillisecondsSinceEpoch(loan.returnedAt!),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '$name: $lent \u2013 $returned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RipStatusSection extends ConsumerWidget {
  const _RipStatusSection({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ripAlbumAsync = ref.watch(ripAlbumForItemProvider(item.id));
    final analysisState = ref.watch(qualityAnalysisNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rip Status', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ripAlbumAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (ripAlbum) {
            if (ripAlbum == null) {
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.album,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Not ripped')),
                    ],
                  ),
                ),
              );
            }

            // Compare track counts
            final ripTrackCount = ripAlbum.trackCount;
            final expectedTracks = _getExpectedTrackCount(item);
            final isFullyRipped = expectedTracks != null
                ? ripTrackCount >= expectedTracks
                : true;
            final isPartiallyRipped =
                expectedTracks != null &&
                ripTrackCount > 0 &&
                ripTrackCount < expectedTracks;

            final Color statusColour;
            final IconData statusIcon;
            final String statusText;

            if (isPartiallyRipped) {
              statusColour = Colors.amber;
              statusIcon = Icons.warning_amber;
              statusText =
                  'Partially ripped ($ripTrackCount/$expectedTracks tracks)';
            } else if (isFullyRipped) {
              statusColour = Colors.green;
              statusIcon = Icons.check_circle;
              statusText = expectedTracks != null
                  ? 'Ripped ($ripTrackCount/$expectedTracks tracks)'
                  : 'Ripped ($ripTrackCount tracks)';
            } else {
              statusColour = Colors.grey;
              statusIcon = Icons.album;
              statusText = 'Ripped ($ripTrackCount tracks)';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: statusColour.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColour),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (ripAlbum.artist != null)
                                Text(
                                  '${ripAlbum.artist} — ${ripAlbum.albumTitle ?? "Unknown"}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              const SizedBox(height: 2),
                              Text(
                                ripAlbum.libraryPath,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (analysisState.status ==
                            QualityAnalysisStatus.analysing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          FilledButton.tonal(
                            onPressed: () {
                              ref
                                  .read(
                                    qualityAnalysisNotifierProvider.notifier,
                                  )
                                  .analyse(ripAlbum.id);
                            },
                            child: const Text('Check Quality'),
                          ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () async {
                            try {
                              await ManageRipsUseCase(
                                repository: ref.read(
                                  ripLibraryRepositoryProvider,
                                ),
                              ).unlinkFromMediaItem(ripAlbum.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to unlink rip: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Unlink'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play and navigation buttons
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final tracks = await ref.read(
                          ripTracksProvider(ripAlbum.id).future,
                        );
                        if (tracks.isNotEmpty) {
                          await ref
                              .read(playbackActionProvider.notifier)
                              .playAlbum(album: ripAlbum, tracks: tracks);
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(selectedRipAlbumProvider.notifier)
                            .select(ripAlbum.id);
                        context.go('/rips');
                      },
                      icon: const Icon(Icons.library_music),
                      label: const Text('View in Rips Library'),
                    ),
                  ],
                ),
                // Analysis progress
                if (analysisState.status ==
                    QualityAnalysisStatus.analysing) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${analysisState.currentStep} '
                      '(${analysisState.currentTrack}/${analysisState.totalTracks})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
                if (analysisState.error != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Error: ${analysisState.error}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                // Per-track quality rows
                const SizedBox(height: 8),
                _TrackQualityList(ripAlbumId: ripAlbum.id),
              ],
            );
          },
        ),
      ],
    );
  }

  int? _getExpectedTrackCount(MediaItem item) {
    final trackListing = item.extraMetadata['track_listing'];
    if (trackListing is List) return trackListing.length;
    return null;
  }
}

class _TrackQualityList extends ConsumerWidget {
  const _TrackQualityList({required this.ripAlbumId});

  final String ripAlbumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(ripTracksProvider(ripAlbumId));

    return tracksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (tracks) {
        // Only show if at least one track has quality data
        final hasQualityData = tracks.any((t) => t.accurateRipStatus != null);
        if (!hasQualityData) return const SizedBox.shrink();

        return Column(
          children: tracks.map((track) {
            return _TrackQualityRow(track: track);
          }).toList(),
        );
      },
    );
  }
}

class _TrackQualityRow extends StatelessWidget {
  const _TrackQualityRow({required this.track});

  final RipTrack track;

  @override
  Widget build(BuildContext context) {
    final status = track.accurateRipStatus;

    final IconData icon;
    final Color colour;
    final String label;

    switch (status) {
      case 'verified':
        icon = Icons.check_circle;
        colour = Colors.green;
        final source = track.ripLogSource != null
            ? 'Verified via ${track.ripLogSource} log'
            : 'AccurateRip verified';
        final confidence = track.accurateRipConfidence != null
            ? ' (confidence ${track.accurateRipConfidence})'
            : '';
        label = '$source$confidence';
      case 'mismatch':
        icon = Icons.cancel;
        colour = Colors.red;
        label = 'AccurateRip CRC mismatch';
      case 'not_found':
        if (track.totalDefects > 0) {
          icon = Icons.warning_amber;
          colour = Colors.amber;
          label = _defectSummary(track);
        } else {
          icon = Icons.check_circle_outline;
          colour = Colors.green;
          label = 'No issues detected';
        }
      default:
        icon = Icons.remove;
        colour = Colors.grey;
        label = 'Not yet analysed';
    }

    return ExpansionTile(
      leading: Icon(icon, color: colour, size: 20),
      title: Text(
        '${track.trackNumber}. ${track.title ?? "Track ${track.trackNumber}"}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(label, style: Theme.of(context).textTheme.bodySmall),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (track.peakLevel != null)
                Text(
                  'Peak level: ${(track.peakLevel! * 100).toStringAsFixed(1)}%',
                ),
              if (track.trackQuality != null)
                Text(
                  'Track quality: ${(track.trackQuality! * 100).toStringAsFixed(1)}%',
                ),
              if (track.copyCrc != null) Text('Copy CRC: ${track.copyCrc}'),
              if (track.accurateRipCrcV1 != null)
                Text('AR CRC v1: ${track.accurateRipCrcV1}'),
              if (track.accurateRipCrcV2 != null)
                Text('AR CRC v2: ${track.accurateRipCrcV2}'),
              // Surface every non-zero defect-type count separately so
              // the user can tell a clipping-heavy rip from a click-laden
              // one without the breakdown being collapsed to a total.
              if ((track.clickCount ?? 0) > 0)
                Text('Clicks: ${track.clickCount}'),
              if ((track.popCount ?? 0) > 0) Text('Pops: ${track.popCount}'),
              if ((track.clippingCount ?? 0) > 0)
                Text('Clipping: ${track.clippingCount}'),
              if ((track.dropoutCount ?? 0) > 0)
                Text('Dropouts: ${track.dropoutCount}'),
              if (track.defectConfidence != null && track.totalDefects > 0)
                Text(
                  'Confidence: '
                  '${(track.defectConfidence! * 100).toStringAsFixed(0)}%',
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a compact "N clicks, M dropouts" line for the not_found state
  /// so the user can see _which_ defect categories fired without
  /// expanding the row.
  String _defectSummary(RipTrack track) {
    final parts = <String>[];
    if ((track.clickCount ?? 0) > 0) {
      parts.add('${track.clickCount} click${track.clickCount! == 1 ? '' : 's'}');
    }
    if ((track.popCount ?? 0) > 0) {
      parts.add('${track.popCount} pop${track.popCount! == 1 ? '' : 's'}');
    }
    if ((track.clippingCount ?? 0) > 0) {
      parts.add(
        '${track.clippingCount} clipping',
      );
    }
    if ((track.dropoutCount ?? 0) > 0) {
      parts.add(
        '${track.dropoutCount} dropout${track.dropoutCount! == 1 ? '' : 's'}',
      );
    }
    return parts.isEmpty
        ? 'Defects detected'
        : '${parts.join(', ')} detected';
  }
}

/// Optional gradient backdrop behind the cover. Active when the current
/// theme's [AppLayoutExtension.gradientItemDetailHero] flag is set — the
/// backdrop fades from the media-type accent down to the scaffold surface
/// so the cover appears to lift off its page.
class _GradientHeroBackdrop extends StatelessWidget {
  const _GradientHeroBackdrop({required this.mediaType, required this.child});

  final MediaType mediaType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.layoutFlags.gradientItemDetailHero) return child;

    final colors = Theme.of(context).colorScheme;
    final soft = context.mediaColors.softFor(mediaType);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [soft, colors.surface],
        ),
      ),
      child: child,
    );
  }
}
