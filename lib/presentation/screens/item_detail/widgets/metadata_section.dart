import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = item.extraMetadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.description != null) ...[
          _SectionContainer(
            colors: colors,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DESCRIPTION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                Text(item.description!,
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Core metadata
        _SectionContainer(
          colors: colors,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DETAILS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 12),
              _row(theme, colors, 'Format', item.format),
              _row(theme, colors, 'Publisher', item.publisher),
              _row(theme, colors, 'Year', item.year?.toString()),
              _row(theme, colors, 'Barcode',
                  '${item.barcode} (${item.barcodeType})'),
              if (item.genres.isNotEmpty)
                _row(theme, colors, 'Genres', item.genres.join(', ')),

              // Type-specific fields
              if (item.mediaType == MediaType.film ||
                  item.mediaType == MediaType.tv) ...[
                _row(theme, colors, 'Director',
                    extra['director'] as String?),
                _row(
                    theme,
                    colors,
                    'Runtime',
                    extra['runtime_minutes'] != null
                        ? '${extra['runtime_minutes']} min'
                        : null),
              ],
              if (item.mediaType == MediaType.music) ...[
                _row(theme, colors, 'Artist',
                    (extra['artists'] as List?)?.join(', ')),
                _row(
                    theme, colors, 'Label', extra['label'] as String?),
              ],
              if (item.mediaType == MediaType.book) ...[
                _row(theme, colors, 'Author',
                    (extra['authors'] as List?)?.join(', ')),
                _row(theme, colors, 'Pages',
                    extra['page_count']?.toString()),
                _row(
                    theme,
                    colors,
                    'ISBN',
                    extra['isbn13'] as String? ??
                        extra['isbn10'] as String?),
              ],
            ],
          ),
        ),

        // Source APIs
        if (item.sourceApis.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionContainer(
            colors: colors,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOURCES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.sourceApis
                      .map((api) => Chip(
                            label: Text(api),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(
      ThemeData theme, ColorScheme colors, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.colors,
    required this.child,
  });

  final ColorScheme colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
