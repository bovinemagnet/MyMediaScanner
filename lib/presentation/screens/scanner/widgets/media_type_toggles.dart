import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';

/// Toggle switches for enabling/disabling media type lookups during scanning.
class MediaTypeToggles extends ConsumerWidget {
  const MediaTypeToggles({super.key});

  static const _types = <(MediaType, String, IconData)>[
    (MediaType.music, 'CD', Icons.album),
    (MediaType.film, 'DVD/Blu-ray', Icons.movie),
    (MediaType.tv, 'TV', Icons.tv),
    (MediaType.book, 'Book', Icons.menu_book),
    (MediaType.game, 'Game', Icons.sports_esports),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      scannerProvider.select((s) => s.enabledMediaTypes),
    );
    final mediaColors = context.mediaColors;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _types.map((entry) {
        final (type, label, icon) = entry;
        final colour = mediaColors.solidFor(type);
        final isOn = enabled.contains(type);
        return FilterChip(
          avatar: Icon(icon, size: 18, color: isOn ? colour : Colors.grey),
          label: Text(label),
          selected: isOn,
          selectedColor: colour.withAlpha(40),
          checkmarkColor: colour,
          onSelected: (_) =>
              ref.read(scannerProvider.notifier).toggleMediaType(type),
        );
      }).toList(),
    );
  }
}
