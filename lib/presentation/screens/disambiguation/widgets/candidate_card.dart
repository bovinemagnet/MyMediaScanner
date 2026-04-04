import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';

class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onTap,
  });

  final MetadataCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      label: _accessibilityLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Cover art
                Container(
                  width: 64,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: candidate.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: candidate.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const SizedBox.shrink(),
                          errorWidget: (_, _, _) =>
                              const _PlaceholderCover(),
                        )
                      : const _PlaceholderCover(),
                ),
                const SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (candidate.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          candidate.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (candidate.year != null)
                            Text(
                              '${candidate.year}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          if (candidate.year != null &&
                              candidate.format != null)
                            const SizedBox(width: 8),
                          if (candidate.format != null)
                            Chip(
                              label: Text(candidate.format!),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              labelStyle: theme.textTheme.labelSmall,
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              candidate.sourceApi,
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 20, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _accessibilityLabel {
    final parts = <String>[candidate.title];
    if (candidate.subtitle != null) parts.add(candidate.subtitle!);
    if (candidate.year != null) parts.add('${candidate.year}');
    if (candidate.format != null) parts.add(candidate.format!);
    parts.add('from ${candidate.sourceApi}');
    return parts.join(', ');
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Icon(
        Icons.album,
        color: colors.onSurfaceVariant,
        size: 28,
      ),
    );
  }
}
