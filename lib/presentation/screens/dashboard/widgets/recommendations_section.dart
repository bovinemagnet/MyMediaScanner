// "Recommended next" dashboard section — picks unconsumed owned items
// the scorer ranks highest, with reason chips per recommendation.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/recommendation.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';

class RecommendationsSection extends ConsumerWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topRecommendationsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'RECOMMENDED NEXT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/wishlist-suggestions'),
                      child: const Text('Suggestions for wishlist →'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final rec in recommendations)
                  _RecommendationTile(rec: rec),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: rec.item.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                rec.item.coverUrl!,
                width: 36,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(width: 36),
              ),
            )
          : const Icon(Icons.movie_outlined),
      title: Text(rec.item.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final reason in rec.reasons.take(2))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                reason.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: Text('${(rec.score * 100).round()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          )),
      onTap: () => context.go('/collection/item/${rec.item.id}'),
    );
  }
}
