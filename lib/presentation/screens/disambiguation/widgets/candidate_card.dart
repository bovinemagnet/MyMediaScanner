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
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: candidate.coverUrl != null
                      ? Image.network(
                          candidate.coverUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
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
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (candidate.year != null)
                            Text(
                              '${candidate.year}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                          Chip(
                            label: Text(candidate.sourceApi),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelStyle: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    return Container(
      width: 64,
      height: 64,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.album,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
