import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoverArtHero extends StatelessWidget {
  const CoverArtHero({super.key, required this.imageUrl, required this.tag});

  final String? imageUrl;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Hero(
      tag: tag,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.surfaceContainerHighest,
        ),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 320,
                fit: BoxFit.contain,
                placeholder: (_, _) => SizedBox(
                  height: 320,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => SizedBox(
                  height: 320,
                  child: Icon(Icons.broken_image,
                      size: 64, color: colors.onSurfaceVariant),
                ),
              )
            : SizedBox(
                height: 320,
                child: Icon(Icons.image_not_supported,
                    size: 64, color: colors.onSurfaceVariant),
              ),
      ),
    );
  }
}
