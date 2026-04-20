// Import screen — bulk-import collections from Goodreads, Discogs,
// Letterboxd or Trakt exports.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/presentation/providers/import_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportSource _source = ImportSource.goodreads;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importNotifierProvider);
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: const Text('Import')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                const ScreenHeader(
                  title: 'Import collection',
                  subtitle:
                      'Bulk-import items from a Goodreads, Discogs, '
                      'Letterboxd or Trakt export.',
                ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ImportState state) {
    return switch (state.phase) {
      ImportPhase.idle => _buildIdle(),
      ImportPhase.parsing => const _CenteredSpinner(label: 'Parsing file…'),
      ImportPhase.enriching => _buildEnriching(state),
      ImportPhase.ready => _buildPreview(state),
      ImportPhase.saving => const _CenteredSpinner(label: 'Saving items…'),
      ImportPhase.done => _buildDone(state),
      ImportPhase.error => _buildError(state),
    };
  }

  Widget _buildIdle() {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Source', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<ImportSource>(
              initialValue: _source,
              items: ImportSource.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.displayName} (.${s.fileExtension})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _source = v ?? _source),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose file…'),
              onPressed: _pickFile,
            ),
            const SizedBox(height: 16),
            Text(
              _hintFor(_source),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hintFor(ImportSource source) => switch (source) {
    ImportSource.goodreads =>
      'Goodreads: My Books → Import and export → Export Library.',
    ImportSource.discogs => 'Discogs: Collection → Export. Choose CSV format.',
    ImportSource.letterboxd =>
      'Letterboxd: Settings → Import & Export → Export your data. '
          'Use the watched.csv file.',
    ImportSource.trakt =>
      'Trakt: Settings → Account → JSON export of watched movies or '
          'shows.',
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: [_source.fileExtension],
      type: FileType.custom,
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    String content;
    if (file.bytes != null) {
      content = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      return;
    }

    if (!mounted) return;
    await ref
        .read(importNotifierProvider.notifier)
        .startImport(source: _source, content: content);
  }

  Widget _buildEnriching(ImportState state) {
    final total = state.rows.length;
    final done = state.enrichedCount;
    final ratio = total == 0 ? 0.0 : done / total;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 320, child: LinearProgressIndicator(value: ratio)),
          const SizedBox(height: 12),
          Text('Enriching $done of $total…'),
        ],
      ),
    );
  }

  Widget _buildPreview(ImportState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(importNotifierProvider.notifier);

    final acceptedCount = state.rows
        .where((r) => r.accepted && r.enriched != null)
        .length;
    final notFoundCount = state.rows
        .where((r) => r.status == ImportRowStatus.notFound)
        .length;
    final duplicateCount = state.rows
        .where((r) => r.status == ImportRowStatus.duplicate)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusChip(
              label: '$acceptedCount accepted',
              color: colors.primary,
            ),
            if (notFoundCount > 0)
              _StatusChip(
                label: '$notFoundCount not found',
                color: colors.tertiary,
              ),
            if (duplicateCount > 0)
              _StatusChip(
                label: '$duplicateCount duplicates',
                color: colors.outline,
              ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  notifier.setAcceptedWhere((r) => r.enriched != null, true),
              child: const Text('Accept all enriched'),
            ),
            TextButton(
              onPressed: () =>
                  notifier.setAcceptedWhere((r) => r.enriched == null, false),
              child: const Text('Reject not-found'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: state.rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = state.rows[index];
              return _ImportRowTile(
                row: row,
                onAcceptedChanged: (v) => notifier.toggleAccepted(index, v),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => notifier.reset(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(
                'Save $acceptedCount item'
                '${acceptedCount == 1 ? '' : 's'}',
              ),
              onPressed: acceptedCount == 0
                  ? null
                  : () => notifier.saveAccepted(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDone(ImportState state) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 64),
          const SizedBox(height: 12),
          Text(
            'Imported ${state.savedCount} items',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () =>
                    ref.read(importNotifierProvider.notifier).reset(),
                child: const Text('Import another'),
              ),
              FilledButton(
                onPressed: () => context.go('/collection'),
                child: const Text('View collection'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(ImportState state) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 12),
          Text(state.errorMessage ?? 'Unknown error'),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => ref.read(importNotifierProvider.notifier).reset(),
            child: const Text('Start over'),
          ),
        ],
      ),
    );
  }
}

class _ImportRowTile extends StatelessWidget {
  const _ImportRowTile({required this.row, required this.onAcceptedChanged});

  final ImportRow row;
  final ValueChanged<bool> onAcceptedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enrichedTitle = row.enriched?.title;
    final hasEnrichment = row.enriched != null;
    final canAccept = hasEnrichment;

    final statusLabel = switch (row.status) {
      ImportRowStatus.pending => 'Pending',
      ImportRowStatus.enriched => 'Found',
      ImportRowStatus.notFound => 'Not found',
      ImportRowStatus.duplicate => 'Already in collection',
      ImportRowStatus.error => 'Error',
    };
    final statusColor = switch (row.status) {
      ImportRowStatus.enriched => colors.primary,
      ImportRowStatus.notFound => colors.tertiary,
      ImportRowStatus.duplicate => colors.outline,
      ImportRowStatus.error => colors.error,
      ImportRowStatus.pending => colors.outline,
    };

    return ListTile(
      leading: Checkbox(
        value: row.accepted && canAccept,
        onChanged: canAccept ? (v) => onAcceptedChanged(v ?? false) : null,
      ),
      title: Text(enrichedTitle ?? row.rawTitle ?? '(untitled)'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (row.rawAuthor != null) Text(row.rawAuthor!),
          if (row.errorMessage != null)
            Text(row.errorMessage!, style: TextStyle(color: colors.error)),
        ],
      ),
      trailing: Text(
        statusLabel,
        style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

class _CenteredSpinner extends StatelessWidget {
  const _CenteredSpinner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(label),
        ],
      ),
    );
  }
}
