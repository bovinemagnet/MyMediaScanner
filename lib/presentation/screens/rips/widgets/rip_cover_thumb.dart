/// Square album-cover thumbnail for the rip library.
///
/// Renders the locally cached cover image at [coverPath]; falls back
/// to a tonal disc-icon placeholder when there is no cover or the
/// cached file cannot be loaded.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';

import 'package:flutter/material.dart';

class RipCoverThumb extends StatelessWidget {
  const RipCoverThumb({
    super.key,
    required this.coverPath,
    this.size = 76,
  });

  /// Absolute path of the cached cover image, or null when the album
  /// has no artwork.
  final String? coverPath;

  /// Width and height of the square thumbnail.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: size,
      height: size,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.album,
        size: size * 0.45,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final path = coverPath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: path == null
          ? placeholder
          : Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
