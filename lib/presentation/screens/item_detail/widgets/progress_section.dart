// Item-detail Progress section — start, update, mark-complete actions
// for tracking reading/watching progress.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/progress_unit.dart';
import 'package:mymediascanner/presentation/providers/progress_provider.dart';

class ProgressSection extends ConsumerWidget {
  const ProgressSection({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final usecase = ref.read(updateProgressUseCaseProvider);

    final isStarted = item.startedAt != null;
    final isComplete = item.completedAt != null;
    final current = item.progressCurrent;
    final total = item.progressTotal;
    final unit = item.progressUnit?.label;
    final ratio = (current != null && total != null && total > 0)
        ? (current / total).clamp(0.0, 1.0)
        : null;

    String statusLine;
    if (isComplete) {
      statusLine = 'Completed';
    } else if (isStarted) {
      if (current != null && total != null && unit != null) {
        statusLine = '$unit $current of $total';
      } else if (current != null && unit != null) {
        statusLine = '$unit $current';
      } else {
        statusLine = 'Started';
      }
    } else {
      statusLine = 'Not started';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROGRESS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (isStarted && !isComplete)
                TextButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Mark complete'),
                  onPressed: () => usecase.markComplete(item),
                ),
              if (isComplete)
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                  onPressed: () => usecase.reset(item),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(statusLine, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          if (ratio != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: ratio, minHeight: 6),
            ),
          const SizedBox(height: 12),
          if (!isStarted)
            FilledButton.tonalIcon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(item.mediaType == MediaType.book
                  ? 'Start reading'
                  : 'Start watching'),
              onPressed: () => _showStartDialog(context, ref, item),
            )
          else if (!isComplete)
            FilledButton.tonalIcon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Update progress'),
              onPressed: () => _showUpdateDialog(context, ref, item),
            ),
        ],
      ),
    );
  }
}

Future<void> _showStartDialog(
    BuildContext context, WidgetRef ref, MediaItem item) async {
  final defaultUnit = switch (item.mediaType) {
    MediaType.book => ProgressUnit.page,
    MediaType.tv => ProgressUnit.episode,
    _ => ProgressUnit.minute,
  };
  final initialTotal = item.progressTotal;

  final result = await showDialog<_StartResult>(
    context: context,
    builder: (_) => _StartDialog(
      defaultUnit: defaultUnit,
      initialTotal: initialTotal,
      mediaType: item.mediaType,
    ),
  );
  if (result == null) return;
  await ref.read(updateProgressUseCaseProvider).start(
        item,
        unit: result.unit,
        total: result.total,
      );
}

Future<void> _showUpdateDialog(
    BuildContext context, WidgetRef ref, MediaItem item) async {
  final controller =
      TextEditingController(text: item.progressCurrent?.toString() ?? '0');
  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
          'Update ${item.progressUnit?.label.toLowerCase() ?? 'progress'}'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: item.progressTotal != null
              ? 'Current (max ${item.progressTotal})'
              : 'Current',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(ctx, int.tryParse(controller.text.trim())),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // Defer disposal to the next frame so the dialog's exit animation can
  // read the controller one last time without hitting a
  // disposed-controller assertion.
  WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  if (result == null) return;
  await ref.read(updateProgressUseCaseProvider).updateCurrent(item, result);
}

class _StartResult {
  const _StartResult({required this.unit, required this.total});
  final ProgressUnit unit;
  final int? total;
}

class _StartDialog extends StatefulWidget {
  const _StartDialog({
    required this.defaultUnit,
    required this.initialTotal,
    required this.mediaType,
  });

  final ProgressUnit defaultUnit;
  final int? initialTotal;
  final MediaType mediaType;

  @override
  State<_StartDialog> createState() => _StartDialogState();
}

class _StartDialogState extends State<_StartDialog> {
  late ProgressUnit _unit;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _unit = widget.defaultUnit;
    _totalController = TextEditingController(
      text: widget.initialTotal?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = switch (widget.mediaType) {
      MediaType.book => [ProgressUnit.page, ProgressUnit.chapter],
      MediaType.tv => [ProgressUnit.episode, ProgressUnit.minute],
      _ => ProgressUnit.values,
    };

    return AlertDialog(
      title: Text(widget.mediaType == MediaType.book
          ? 'Start reading'
          : 'Start watching'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ProgressUnit>(
            initialValue: _unit,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: [
              for (final u in units)
                DropdownMenuItem(value: u, child: Text(u.label)),
            ],
            onChanged: (v) => setState(() => _unit = v ?? _unit),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _totalController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Total (optional)',
              hintText: 'e.g. 320 pages, 24 episodes',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _StartResult(
              unit: _unit,
              total: int.tryParse(_totalController.text.trim()),
            ),
          ),
          child: const Text('Start'),
        ),
      ],
    );
  }
}
