// Export action bar for the insights dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/insights_export_provider.dart';

/// Row of export buttons for CSV and JSON formats.
class ExportActionBar extends ConsumerWidget {
  const ExportActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final exportState = ref.watch(insightsExportProvider);
    final isExporting = exportState.status == ExportStatus.exporting;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPORT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExporting
                      ? null
                      : () => _export(context, ref, ExportFormat.csv),
                  icon: const Icon(Icons.table_chart, size: 18),
                  label: const Text('Export CSV'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExporting
                      ? null
                      : () => _export(context, ref, ExportFormat.json),
                  icon: const Icon(Icons.data_object, size: 18),
                  label: const Text('Export JSON'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final filePath =
        await ref.read(insightsExportProvider.notifier).export(format);

    if (filePath != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Collection exported to $filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      final error = ref.read(insightsExportProvider).error ?? 'Unknown error';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
