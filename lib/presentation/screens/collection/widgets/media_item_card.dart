import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_layout_extension.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';
import 'package:mymediascanner/presentation/widgets/procedural_cover_placeholder.dart';

class MediaItemCard extends StatelessWidget {
  const MediaItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isLent = false,
    this.isRipped = false,
    this.contextMenuActions = const [],
  });

  final MediaItem item;
  final VoidCallback onTap;
  final bool isLent;
  final bool isRipped;
  final List<ContextMenuAction> contextMenuActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mediaColors = context.mediaColors;
    final useProceduralCovers = context.layoutFlags.proceduralCovers;

    Widget placeholder() => useProceduralCovers
        ? ProceduralCoverPlaceholder(
            title: item.title,
            mediaType: item.mediaType,
          )
        : Container(
            color: colors.surfaceContainerHighest,
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
          );

    return DesktopContextMenu(
      actions: contextMenuActions,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: item.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                            errorWidget: (_, _, _) => placeholder(),
                          )
                        : placeholder(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: mediaColors.solidFor(item.mediaType),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.mediaType.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (item.userRating != null) ...[
                              const Spacer(),
                              Icon(Icons.star,
                                  size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 2),
                              Text(
                                item.userRating!.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.year != null)
                          Text(
                            '${item.year}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isLent)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Lent',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isRipped)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: mediaColors.book.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.album,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
