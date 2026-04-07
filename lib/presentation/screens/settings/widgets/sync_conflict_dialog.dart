import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';

/// A modal dialog that presents detected sync conflicts and allows
/// the user to choose per-field resolutions (keep local, keep remote,
/// or keep both).
class SyncConflictDialog extends ConsumerStatefulWidget {
  const SyncConflictDialog({
    super.key,
    required this.conflicts,
  });

  final List<SyncConflict> conflicts;

  /// Show the dialog and return true if conflicts were resolved.
  static Future<bool> show(
    BuildContext context,
    List<SyncConflict> conflicts,
  ) async {
    if (conflicts.isEmpty) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SyncConflictDialog(conflicts: conflicts),
    );
    return result ?? false;
  }

  @override
  ConsumerState<SyncConflictDialog> createState() =>
      _SyncConflictDialogState();
}

class _SyncConflictDialogState extends ConsumerState<SyncConflictDialog> {
  late List<SyncConflict> _resolutions;

  @override
  void initState() {
    super.initState();
    _resolutions = List.of(widget.conflicts);
  }

  void _setResolution(int index, ConflictResolution resolution) {
    setState(() {
      _resolutions[index] = _resolutions[index].copyWith(
        resolution: resolution,
      );
    });
  }

  void _applyAllLocal() {
    setState(() {
      _resolutions = _resolutions
          .map((c) => c.copyWith(resolution: ConflictResolution.keepLocal))
          .toList();
    });
  }

  void _applyAllRemote() {
    setState(() {
      _resolutions = _resolutions
          .map((c) => c.copyWith(resolution: ConflictResolution.keepRemote))
          .toList();
    });
  }

  Future<void> _resolve() async {
    await ref
        .read(syncConflictsProvider.notifier)
        .resolveConflicts(_resolutions);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: colors.error),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Sync Conflicts Detected'),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_resolutions.length} field(s) have conflicting changes. '
              'Choose which version to keep for each field.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Bulk actions
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _applyAllLocal,
                  icon: const Icon(Icons.phone_android, size: 16),
                  label: const Text('All Local'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _applyAllRemote,
                  icon: const Icon(Icons.cloud, size: 16),
                  label: const Text('All Remote'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Conflict list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _resolutions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conflict = _resolutions[index];
                  return _ConflictRow(
                    conflict: conflict,
                    onResolutionChanged: (r) => _setResolution(index, r),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _resolve,
          child: const Text('Resolve'),
        ),
      ],
    );
  }
}

class _ConflictRow extends StatelessWidget {
  const _ConflictRow({
    required this.conflict,
    required this.onResolutionChanged,
  });

  final SyncConflict conflict;
  final ValueChanged<ConflictResolution> onResolutionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field name and entity info
          Text(
            '${conflict.entityType} / ${conflict.fieldName}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Values side by side
          Row(
            children: [
              Expanded(
                child: _ValueCard(
                  label: 'Local',
                  value: '${conflict.localValue ?? '(empty)'}',
                  isSelected:
                      conflict.resolution == ConflictResolution.keepLocal,
                  colour: colors.tertiary,
                  onTap: () =>
                      onResolutionChanged(ConflictResolution.keepLocal),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueCard(
                  label: 'Remote',
                  value: '${conflict.remoteValue ?? '(empty)'}',
                  isSelected:
                      conflict.resolution == ConflictResolution.keepRemote,
                  colour: colors.secondary,
                  onTap: () =>
                      onResolutionChanged(ConflictResolution.keepRemote),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.colour,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final Color colour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colour.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colour
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelected)
                  Icon(Icons.check_circle, size: 14, color: colour),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colour,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
