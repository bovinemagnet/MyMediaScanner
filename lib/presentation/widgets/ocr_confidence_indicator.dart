import 'package:flutter/material.dart';

/// Displays an OCR confidence score with visual feedback.
///
/// - High confidence (>= 0.80): green tonal container with tick icon
/// - Medium confidence (0.50-0.79): amber tonal container with info icon
/// - Low confidence (< 0.50): red tonal container with warning icon
class OcrConfidenceIndicator extends StatelessWidget {
  const OcrConfidenceIndicator({
    super.key,
    required this.confidence,
    this.searchTermUsed,
  });

  final double confidence;
  final String? searchTermUsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (icon, colour, label) = _getIndicatorStyle(colors);
    final percentage = (confidence * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colour, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text recognised from cover ($percentage% confidence)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colour,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (searchTermUsed != null && searchTermUsed!.isNotEmpty)
                  Text(
                    'Searched: "$searchTermUsed"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _getIndicatorStyle(ColorScheme colors) {
    if (confidence >= 0.80) {
      return (
        Icons.check_circle_outline,
        Colors.green,
        'High confidence — results should be accurate',
      );
    } else if (confidence >= 0.50) {
      return (
        Icons.info_outline,
        Colors.amber.shade700,
        'Medium confidence — please verify the details',
      );
    } else {
      return (
        Icons.warning_amber_outlined,
        colors.error,
        'Low confidence — consider entering details manually',
      );
    }
  }
}
