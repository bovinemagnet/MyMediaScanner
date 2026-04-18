// Batch Editor screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_check_helper.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

// ── Filter tabs ──────────────────────────────────────────────────────

enum _BatchFilter { all, needsReview, confirmed, saved }

class BatchPlaceholderScreen extends ConsumerStatefulWidget {
  const BatchPlaceholderScreen({super.key});

  @override
  ConsumerState<BatchPlaceholderScreen> createState() =>
      _BatchPlaceholderScreenState();
}

class _BatchPlaceholderScreenState
    extends ConsumerState<BatchPlaceholderScreen> {
  _BatchFilter _filter = _BatchFilter.all;

  List<BatchItem> _filterItems(List<BatchItem> items) {
    return switch (_filter) {
      _BatchFilter.all => items,
      _BatchFilter.needsReview => items
          .where((i) =>
              i.status == BatchItemStatus.conflict ||
              i.status == BatchItemStatus.notFound)
          .toList(),
      _BatchFilter.confirmed =>
        items.where((i) => i.status == BatchItemStatus.confirmed).toList(),
      _BatchFilter.saved =>
        items.where((i) => i.status == BatchItemStatus.saved).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final asyncBatchState = ref.watch(batchEditorProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = PlatformCapability.isDesktop;

    return asyncBatchState.when(
      loading: () => Scaffold(
        appBar: isDesktop ? null : AppBar(title: const Text('Batch Editor')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: isDesktop ? null : AppBar(title: const Text('Batch Editor')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text('Failed to load batch data',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      data: (batchState) => _buildContent(
        context,
        batchState,
        theme,
        colors,
        isDesktop,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BatchEditorState batchState,
    ThemeData theme,
    ColorScheme colors,
    bool isDesktop,
  ) {
    final filteredItems = _filterItems(batchState.items);

    // Keyboard shortcuts for undo/redo (desktop only).
    Widget body = _buildBody(
      context,
      batchState,
      filteredItems,
      theme,
      colors,
      isDesktop,
    );

    if (isDesktop) {
      body = Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
              const _UndoIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
                  LogicalKeyboardKey.keyZ):
              const _RedoIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
              const _RedoIntent(),
        },
        child: Actions(
          actions: {
            _UndoIntent: CallbackAction<_UndoIntent>(
              onInvoke: (_) {
                ref.read(batchEditorProvider.notifier).undo();
                return null;
              },
            ),
            _RedoIntent: CallbackAction<_RedoIntent>(
              onInvoke: (_) {
                ref.read(batchEditorProvider.notifier).redo();
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: body),
        ),
      );
    }

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Batch Editor'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed:
                      batchState.canUndo
                          ? () => ref
                              .read(batchEditorProvider.notifier)
                              .undo()
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed:
                      batchState.canRedo
                          ? () => ref
                              .read(batchEditorProvider.notifier)
                              .redo()
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Batch history',
                  onPressed: () => context.go('/batch/history'),
                ),
              ],
            ),
      body: body,
    );
  }

  Widget _buildBody(
    BuildContext context,
    BatchEditorState batchState,
    List<BatchItem> filteredItems,
    ThemeData theme,
    ColorScheme colors,
    bool isDesktop,
  ) {
    if (batchState.items.isEmpty) {
      return _EmptyBatchView(theme: theme, colors: colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + actions
        if (isDesktop)
          ScreenHeader(
            title: 'Batch Editor',
            subtitle: 'Process and validate bulk scans. Review metadata '
                'matches across ${batchState.totalCount} pending '
                'items in current session.',
            actions: [
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo (Ctrl+Z)',
                onPressed: batchState.canUndo
                    ? () => ref.read(batchEditorProvider.notifier).undo()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo (Ctrl+Shift+Z)',
                onPressed: batchState.canRedo
                    ? () => ref.read(batchEditorProvider.notifier).redo()
                    : null,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.history, size: 18),
                label: const Text('History'),
                onPressed: () => context.go('/batch/history'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: batchState.items.isEmpty
                    ? null
                    : () => _confirmDiscard(context, ref),
                child: const Text('Discard Batch'),
              ),
              const SizedBox(width: 8),
              GradientButton(
                onPressed: batchState.confirmedCount > 0
                    ? () => _syncAll(context, ref)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync, size: 18),
                    const SizedBox(width: 6),
                    Text('Sync All (${batchState.confirmedCount})'),
                  ],
                ),
              ),
            ],
          ),

        if (!isDesktop)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: batchState.confirmedCount > 0
                        ? () => _syncAll(context, ref)
                        : null,
                    child:
                        Text('Sync All (${batchState.confirmedCount})'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Discard batch',
                  onPressed: batchState.items.isEmpty
                      ? null
                      : () => _confirmDiscard(context, ref),
                ),
              ],
            ),
          ),

        // Save progress indicator
        if (batchState.saveProgress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: batchState.saveProgress!.fraction,
                  color: colors.primary,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  'Saving item ${batchState.saveProgress!.current} of '
                  '${batchState.saveProgress!.total}\u2026',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

        // Stats cards
        _StatsRow(state: batchState, theme: theme, colors: colors),
        const SizedBox(height: 8),

        // Filter tabs
        _FilterTabs(
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
          state: batchState,
          theme: theme,
          colors: colors,
        ),

        // Items list/table
        Expanded(
          child: batchState.isSaving
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colors.primary),
                      const SizedBox(height: 16),
                      Text('Saving items\u2026',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              : filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items match this filter.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : isDesktop
                      ? _BatchTable(
                          items: filteredItems,
                          theme: theme,
                          colors: colors,
                          onSave: (id) => _saveItem(context, ref, id),
                          onRemove: (id) => ref
                              .read(batchEditorProvider.notifier)
                              .removeItem(id),
                          onResolve: (item) =>
                              _resolveConflict(context, ref, item),
                          onForceKeep: (id) => ref
                              .read(batchEditorProvider.notifier)
                              .forceKeepDuplicate(id),
                        )
                      : _BatchList(
                          items: filteredItems,
                          theme: theme,
                          colors: colors,
                          onSave: (id) => _saveItem(context, ref, id),
                          onRemove: (id) => ref
                              .read(batchEditorProvider.notifier)
                              .removeItem(id),
                          onResolve: (item) =>
                              _resolveConflict(context, ref, item),
                          onForceKeep: (id) => ref
                              .read(batchEditorProvider.notifier)
                              .forceKeepDuplicate(id),
                        ),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Showing ${filteredItems.length} of '
            '${batchState.totalCount} items',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _syncAll(BuildContext context, WidgetRef ref) async {
    // Pre-check each confirmed item for duplicates. If the user cancels
    // on any duplicate, abort the whole bulk save so they can revise the
    // batch before retrying.
    final repository = ref.read(mediaItemRepositoryProvider);
    final state = ref.read(batchEditorProvider).requireValue;
    for (final item in state.items) {
      if (item.metadata == null) continue;
      if (item.status != BatchItemStatus.confirmed) continue;
      final md = item.metadata!;
      final proceed = await confirmSaveOrSkipIfDuplicate(
        context: context,
        repository: repository,
        barcode: md.barcode,
        title: md.title,
        year: md.year,
      );
      if (!context.mounted) return;
      if (!proceed) {
        final cancelledTitle = md.title ?? 'Untitled item';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Bulk save cancelled at '$cancelledTitle'. "
              'Remove or edit that entry and try again.',
            ),
          ),
        );
        return;
      }
    }
    await ref.read(batchEditorProvider.notifier).saveAllConfirmed();
    if (context.mounted) {
      final savedCount =
          ref.read(batchEditorProvider).requireValue.savedCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved $savedCount items to collection.')),
      );
    }
  }

  Future<void> _saveItem(
      BuildContext context, WidgetRef ref, String id) async {
    final repository = ref.read(mediaItemRepositoryProvider);
    final state = ref.read(batchEditorProvider).requireValue;
    final item = state.items.firstWhere((i) => i.id == id);
    if (item.metadata != null) {
      final md = item.metadata!;
      final proceed = await confirmSaveOrSkipIfDuplicate(
        context: context,
        repository: repository,
        barcode: md.barcode,
        title: md.title,
        year: md.year,
      );
      if (!context.mounted) return;
      if (!proceed) return;
    }
    await ref.read(batchEditorProvider.notifier).saveItem(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved to collection')),
      );
    }
  }

  void _confirmDiscard(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard batch?'),
        content: const Text(
            'All unsaved items will be lost. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              ref.read(batchEditorProvider.notifier).clearBatch();
              Navigator.pop(ctx);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _resolveConflict(
      BuildContext context, WidgetRef ref, BatchItem item) {
    if (item.scanResult is MultiMatchScanResult) {
      final multi = item.scanResult as MultiMatchScanResult;
      showDialog(
        context: context,
        builder: (ctx) => _ConflictResolutionDialog(
          item: item,
          candidates: multi.candidates,
          onResolved: (metadata) {
            ref
                .read(batchEditorProvider.notifier)
                .resolveItem(item.id, metadata);
            Navigator.pop(ctx);
          },
        ),
      );
    }
  }
}

// ── Keyboard shortcut intents ───────────────────────────────────────

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

// ═══════════════════════════════════════════════════════════════════════
// Empty state
// ═══════════════════════════════════════════════════════════════════════

class _EmptyBatchView extends StatelessWidget {
  const _EmptyBatchView({required this.theme, required this.colors});

  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dynamic_feed_outlined,
                size: 72,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                'No Batch Items',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Enable batch mode in the scanner to queue\n'
                'multiple items for review here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                onPressed: () => context.go('/scan'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 18),
                    SizedBox(width: 8),
                    Text('Start Scanning'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Stats row
// ═══════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.state,
    required this.theme,
    required this.colors,
  });

  final BatchEditorState state;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          final cards = [
            _MiniStatCard(
              label: 'Total Scans',
              value: '${state.totalCount}',
              icon: Icons.data_usage,
              iconColor: colors.primary,
              theme: theme,
              colors: colors,
            ),
            _MiniStatCard(
              label: 'Auto Matches',
              value: '${state.autoMatchRate.toStringAsFixed(1)}%',
              icon: Icons.check_circle,
              iconColor: context.mediaColors.book,
              theme: theme,
              colors: colors,
            ),
            _MiniStatCard(
              label: 'Needs Review',
              value: '${state.needsReviewCount}',
              icon: Icons.warning,
              iconColor: state.needsReviewCount > 0
                  ? colors.error
                  : colors.onSurfaceVariant,
              theme: theme,
              colors: colors,
              highlight: state.needsReviewCount > 0,
            ),
          ];

          if (isWide) {
            return Row(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i < cards.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          }
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.theme,
    required this.colors,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final ThemeData theme;
  final ColorScheme colors;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: colors.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? colors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Filter tabs
// ═══════════════════════════════════════════════════════════════════════

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.onSelected,
    required this.state,
    required this.theme,
    required this.colors,
  });

  final _BatchFilter selected;
  final ValueChanged<_BatchFilter> onSelected;
  final BatchEditorState state;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tab('All Items', _BatchFilter.all, state.totalCount),
          _tab('Needs Review', _BatchFilter.needsReview,
              state.needsReviewCount),
          _tab('Confirmed', _BatchFilter.confirmed, state.confirmedCount),
          _tab('Saved', _BatchFilter.saved, state.savedCount),
        ],
      ),
    );
  }

  Widget _tab(String label, _BatchFilter filter, int count) {
    final isActive = selected == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? colors.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              count > 0 ? '$label ($count)' : label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Desktop table view
// ═══════════════════════════════════════════════════════════════════════

class _BatchTable extends StatelessWidget {
  const _BatchTable({
    required this.items,
    required this.theme,
    required this.colors,
    required this.onSave,
    required this.onRemove,
    required this.onResolve,
    required this.onForceKeep,
  });

  final List<BatchItem> items;
  final ThemeData theme;
  final ColorScheme colors;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onRemove;
  final ValueChanged<BatchItem> onResolve;
  final ValueChanged<String> onForceKeep;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 56), // cover
                Expanded(
                  flex: 3,
                  child: _headerLabel('Item Metadata'),
                ),
                Expanded(flex: 2, child: _headerLabel('Identifiers')),
                Expanded(child: _headerLabel('Status')),
                const SizedBox(width: 100, child: _HeaderLabel('Actions')),
              ],
            ),
          ),
          // Table body
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _BatchTableRow(
                  item: item,
                  theme: theme,
                  colors: colors,
                  onSave: () => onSave(item.id),
                  onRemove: () => onRemove(item.id),
                  onResolve: () => onResolve(item),
                  onForceKeep: () => onForceKeep(item.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.end,
    );
  }
}

class _BatchTableRow extends StatelessWidget {
  const _BatchTableRow({
    required this.item,
    required this.theme,
    required this.colors,
    required this.onSave,
    required this.onRemove,
    required this.onResolve,
    required this.onForceKeep,
  });

  final BatchItem item;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onSave;
  final VoidCallback onRemove;
  final VoidCallback onResolve;
  final VoidCallback onForceKeep;

  @override
  Widget build(BuildContext context) {
    final isSaved = item.status == BatchItemStatus.saved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Opacity(
        opacity: isSaved ? 0.5 : 1.0,
        child: Row(
          children: [
            // Cover art
            _CoverThumbnail(
              imageUrl: item.coverUrl,
              hasConflict: item.status == BatchItemStatus.conflict,
              colors: colors,
            ),
            const SizedBox(width: 12),
            // Metadata
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.status == BatchItemStatus.conflict)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'CONFLICT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.error,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Identifiers
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.barcode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.barcodeType.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            Expanded(
              child: _StatusBadge(
                  status: item.status,
                  duplicateSource: item.duplicateSource,
                  theme: theme,
                  colors: colors),
            ),
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.status == BatchItemStatus.conflict)
                    _ActionButton(
                      label: 'Resolve',
                      color: colors.primary,
                      onTap: onResolve,
                    )
                  else if (item.status == BatchItemStatus.confirmed)
                    _ActionButton(
                      label: 'Save',
                      color: colors.primary,
                      onTap: onSave,
                    )
                  else if (item.status == BatchItemStatus.duplicate)
                    _ActionButton(
                      label: 'Keep',
                      color: colors.tertiary,
                      onTap: onForceKeep,
                    ),
                  if (!isSaved) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: colors.onSurfaceVariant),
                      onPressed: onRemove,
                      tooltip: 'Remove',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Mobile list view
// ═══════════════════════════════════════════════════════════════════════

class _BatchList extends StatelessWidget {
  const _BatchList({
    required this.items,
    required this.theme,
    required this.colors,
    required this.onSave,
    required this.onRemove,
    required this.onResolve,
    required this.onForceKeep,
  });

  final List<BatchItem> items;
  final ThemeData theme;
  final ColorScheme colors;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onRemove;
  final ValueChanged<BatchItem> onResolve;
  final ValueChanged<String> onForceKeep;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSaved = item.status == BatchItemStatus.saved;

        return Opacity(
          opacity: isSaved ? 0.5 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _CoverThumbnail(
                  imageUrl: item.coverUrl,
                  hasConflict: item.status == BatchItemStatus.conflict,
                  colors: colors,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.barcode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _StatusBadge(
                        status: item.status,
                        duplicateSource: item.duplicateSource,
                        theme: theme,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                if (item.status == BatchItemStatus.conflict)
                  IconButton(
                    icon: Icon(Icons.edit, color: colors.primary, size: 20),
                    tooltip: 'Resolve',
                    onPressed: () => onResolve(item),
                  )
                else if (item.status == BatchItemStatus.confirmed)
                  IconButton(
                    icon: Icon(Icons.check, color: colors.primary, size: 20),
                    tooltip: 'Save',
                    onPressed: () => onSave(item.id),
                  )
                else if (item.status == BatchItemStatus.duplicate)
                  IconButton(
                    icon: Icon(Icons.check_circle_outline,
                        color: colors.tertiary, size: 20),
                    tooltip: 'Keep Anyway',
                    onPressed: () => onForceKeep(item.id),
                  ),
                if (!isSaved)
                  IconButton(
                    icon: Icon(Icons.close,
                        color: colors.onSurfaceVariant, size: 20),
                    tooltip: 'Remove',
                    onPressed: () => onRemove(item.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Shared components
// ═══════════════════════════════════════════════════════════════════════

class _CoverThumbnail extends StatelessWidget {
  const _CoverThumbnail({
    required this.imageUrl,
    required this.hasConflict,
    required this.colors,
  });

  final String? imageUrl;
  final bool hasConflict;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: hasConflict
            ? Border.all(color: colors.error.withValues(alpha: 0.4))
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => Icon(
                Icons.broken_image,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Icon(
              Icons.image_not_supported,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          if (hasConflict)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Icon(
                  Icons.priority_high,
                  size: 16,
                  color: colors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.duplicateSource,
    required this.theme,
    required this.colors,
  });

  final BatchItemStatus status;
  final DuplicateSource? duplicateSource;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final bookColour = context.mediaColors.book;
    final (label, bgColor, fgColor) = switch (status) {
      BatchItemStatus.confirmed => (
          'Confirmed',
          bookColour.withValues(alpha: 0.15),
          bookColour,
        ),
      BatchItemStatus.conflict => (
          'Review',
          colors.error.withValues(alpha: 0.15),
          colors.error,
        ),
      BatchItemStatus.notFound => (
          'Not Found',
          colors.outline.withValues(alpha: 0.15),
          colors.outline,
        ),
      BatchItemStatus.duplicate => (
          duplicateSource == DuplicateSource.batch
              ? 'Batch Dup'
              : 'Duplicate',
          colors.tertiary.withValues(alpha: 0.15),
          colors.tertiary,
        ),
      BatchItemStatus.saved => (
          'Saved',
          colors.primary.withValues(alpha: 0.15),
          colors.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Conflict resolution dialog
// ═══════════════════════════════════════════════════════════════════════

class _ConflictResolutionDialog extends ConsumerWidget {
  const _ConflictResolutionDialog({
    required this.item,
    required this.candidates,
    required this.onResolved,
  });

  final BatchItem item;
  final List<MetadataCandidate> candidates;
  final ValueChanged<MetadataResult> onResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: const Text('Resolve Conflict'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multiple matches found for barcode ${item.barcode}. '
              'Select the correct item:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...candidates.map((candidate) => ListTile(
                  leading: candidate.coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: candidate.coverUrl!,
                            width: 40,
                            height: 56,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.image, size: 24),
                          ),
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(candidate.title),
                  subtitle: Text(
                    [
                      candidate.subtitle,
                      if (candidate.year != null) '${candidate.year}',
                    ].whereType<String>().join(' \u2022 '),
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () async {
                    final repo = ref.read(metadataRepositoryProvider);
                    final detail = await repo.fetchCandidateDetail(
                      candidate,
                      item.barcode,
                      item.barcodeType,
                    );
                    if (detail != null) {
                      onResolved(detail);
                    }
                  },
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
