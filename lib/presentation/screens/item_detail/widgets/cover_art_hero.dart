import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoverArtHero extends StatelessWidget {
  const CoverArtHero({super.key, required this.imageUrl, required this.tag});

  final String? imageUrl;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              height: 300,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.broken_image, size: 100),
            )
          : Container(
              height: 300,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 100),
            ),
    );
  }
}
