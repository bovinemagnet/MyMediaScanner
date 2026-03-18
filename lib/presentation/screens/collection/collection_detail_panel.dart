import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/refresh_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/cover_art_hero.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/metadata_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/tag_chips.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

/// Embedded item detail for the master-detail side panel.
///
/// Unlike [ItemDetailScreen], this has no Scaffold or AppBar —
/// it renders directly as the detail pane in a [MasterDetailLayout].
class CollectionDetailPanel extends ConsumerWidget {
  const CollectionDetailPanel({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(mediaItemProvider(itemId));

    return itemAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (item) {
        if (item == null) {
          return const ErrorState(message: 'Item not found');
        }
        return Column(
          children: [
            // Toolbar
            Material(
              elevation: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Refresh metadata',
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await RefreshMetadataUseCase(
                            metadataRepository:
                                ref.read(metadataRepositoryProvider),
                            mediaItemRepository:
                                ref.read(mediaItemRepositoryProvider),
                          ).execute(item);
                          ref.invalidate(mediaItemProvider(itemId));
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Metadata refreshed')));
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(
                              content:
                                  Text('Failed to refresh metadata: $e')));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit',
                      onPressed: () =>
                          context.go('/item/${item.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Close panel',
                      onPressed: () =>
                          ref.read(selectedItemProvider.notifier).clear(),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CoverArtHero(
                        imageUrl: item.coverUrl,
                        tag: 'panel-cover-${item.id}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (item.subtitle != null)
                      Center(
                        child: Text(item.subtitle!,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                      ),
                    const SizedBox(height: 12),
                    Center(
                      child: StarRatingWidget(
                        rating: item.userRating ?? 0,
                        onChanged: (rating) async {
                          try {
                            await UpdateRatingUseCase(
                              repository:
                                  ref.read(mediaItemRepositoryProvider),
                            ).execute(item.id, rating: rating);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to update rating: $e')),
                              );
                            }
                          }
                          ref.invalidate(mediaItemProvider(itemId));
                        },
                      ),
                    ),
                    if (item.criticScore != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${item.criticScore!.toStringAsFixed(1)}/10 ${item.criticSource ?? ""}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    MetadataSection(item: item),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
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
              ref.read(selectedItemProvider.notifier).clear();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
