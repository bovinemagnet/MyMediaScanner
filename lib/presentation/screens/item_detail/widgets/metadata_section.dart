import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = item.extraMetadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.description != null) ...[
          Text('Description', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(item.description!),
          const SizedBox(height: 16),
        ],
        _row('Format', item.format),
        _row('Publisher', item.publisher),
        _row('Year', item.year?.toString()),
        _row('Barcode', '${item.barcode} (${item.barcodeType})'),
        if (item.genres.isNotEmpty)
          _row('Genres', item.genres.join(', ')),

        // Type-specific fields
        if (item.mediaType == MediaType.film ||
            item.mediaType == MediaType.tv) ...[
          _row('Director', extra['director'] as String?),
          _row('Runtime', extra['runtime_minutes'] != null
              ? '${extra['runtime_minutes']} min'
              : null),
        ],
        if (item.mediaType == MediaType.music) ...[
          _row('Artist', (extra['artists'] as List?)?.join(', ')),
          _row('Label', extra['label'] as String?),
        ],
        if (item.mediaType == MediaType.book) ...[
          _row('Author', (extra['authors'] as List?)?.join(', ')),
          _row('Pages', extra['page_count']?.toString()),
          _row('ISBN', extra['isbn13'] as String? ?? extra['isbn10'] as String?),
        ],
      ],
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
