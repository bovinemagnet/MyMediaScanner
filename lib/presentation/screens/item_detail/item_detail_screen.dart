import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/refresh_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/return_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/borrower_picker_dialog.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/cover_art_hero.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/metadata_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/tag_chips.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

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
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshMetadata(context, ref, item),
                tooltip: 'Refresh metadata',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/item/${item.id}/edit'),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CoverArtHero(
                      imageUrl: item.coverUrl, tag: 'cover-${item.id}'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(item.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                if (item.subtitle != null)
                  Center(
                    child: Text(item.subtitle!,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: StarRatingWidget(
                    rating: item.userRating ?? 0,
                    onChanged: (rating) {
                      UpdateRatingUseCase(
                              repository:
                                  ref.read(mediaItemRepositoryProvider))
                          .execute(item.id, rating: rating);
                      ref.invalidate(mediaItemProvider(itemId));
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                _LendingSection(mediaItemId: item.id),
                const SizedBox(height: 16),
                MetadataSection(item: item),
              ],
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing metadata\u2026')),
    );
    try {
      await RefreshMetadataUseCase(
        metadataRepository: ref.read(metadataRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      ).execute(item);
      ref.invalidate(mediaItemProvider(itemId));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Metadata refreshed')),
          );
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
                      repository: ref.read(mediaItemRepositoryProvider))
                  .execute(itemId);
              if (context.mounted) {
                Navigator.pop(ctx);
                context.go('/');
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
            final borrowers =
                allBorrowersAsync.value ?? [];
            final borrower = borrowers
                .where((b) => b.id == activeLoan.borrowerId)
                .firstOrNull;
            final borrowerName = borrower?.name ?? 'Unknown';
            final lentDate = dateFormat.format(
                DateTime.fromMillisecondsSinceEpoch(activeLoan.lentAt));

            return Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lent to $borrowerName',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text('Since $lentDate',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        ReturnItemUseCase(
                                repository: ref.read(loanRepositoryProvider))
                            .execute(activeLoan.id);
                      },
                      child: const Text('Return'),
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
            final pastLoans =
                loans.where((l) => l.returnedAt != null).toList();
            if (pastLoans.isEmpty) return const SizedBox.shrink();

            final borrowers =
                allBorrowersAsync.value ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('History',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                ...pastLoans.map((loan) {
                  final borrower = borrowers
                      .where((b) => b.id == loan.borrowerId)
                      .firstOrNull;
                  final name = borrower?.name ?? 'Unknown';
                  final lent = dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(loan.lentAt));
                  final returned = dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          loan.returnedAt!));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('$name: $lent \u2013 $returned',
                        style: Theme.of(context).textTheme.bodySmall),
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
