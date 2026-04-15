// Wishlist suggestions — TMDB trending entries the user does not yet
// own, ranked against their taste profile.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class WishlistSuggestionsScreen extends ConsumerWidget {
  const WishlistSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wishlistSuggestionsProvider);
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(title: const Text('Wishlist suggestions')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const ScreenHeader(
                title: 'Wishlist suggestions',
                subtitle:
                    'Trending titles you do not yet own, ranked against '
                    'the genres and series you collect.',
              ),
            Expanded(
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (suggestions) {
                  if (suggestions.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) =>
                        _SuggestionTile(suggestion: suggestions[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tips_and_updates_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No suggestions yet',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Add a TMDB API key in Settings and rate a few items so the '
              'scorer has something to learn from.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile({required this.suggestion});

  final WishlistSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: suggestion.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                suggestion.coverUrl!,
                width: 48,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported),
              ),
            )
          : const Icon(Icons.movie_outlined),
      title: Text(suggestion.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestion.year != null)
            Text('${suggestion.year}',
                style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final reason in suggestion.reasons.take(3))
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reason.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: FilledButton.tonalIcon(
        icon: const Icon(Icons.favorite_border, size: 18),
        label: const Text('Wishlist'),
        onPressed: () => _addToWishlist(context, ref, suggestion),
      ),
    );
  }

  Future<void> _addToWishlist(
      BuildContext context, WidgetRef ref, WishlistSuggestion s) async {
    final usecase = ref.read(saveMediaItemUseCaseProvider);
    final metadata = MetadataResult(
      barcode: s.externalId,
      barcodeType: 'TMDB',
      mediaType: MediaType.film,
      title: s.title,
      coverUrl: s.coverUrl,
      year: s.year,
      genres: s.genres,
      sourceApis: const ['tmdb'],
    );
    await usecase.execute(metadata, ownershipStatus: OwnershipStatus.wishlist);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${s.title} added to wishlist')),
    );
    // Refresh suggestions so the just-added entry disappears.
    ref.invalidate(wishlistSuggestionsProvider);
  }
}
