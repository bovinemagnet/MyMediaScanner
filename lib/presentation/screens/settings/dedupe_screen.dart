// Duplicate-detection dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';
import 'package:mymediascanner/domain/usecases/scan_duplicates_usecase.dart';
import 'package:mymediascanner/presentation/providers/dedupe_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class DedupeScreen extends ConsumerWidget {
  const DedupeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dedupeGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find duplicates'),
        actions: [
          IconButton(
            tooltip: 'Rescan',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dedupeGroupsProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(dedupeGroupsProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              message: 'No duplicates found in your collection.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _DuplicateGroupCard(group: groups[index]),
          );
        },
      ),
    );
  }
}

class _DuplicateGroupCard extends ConsumerStatefulWidget {
  const _DuplicateGroupCard({required this.group});

  final DuplicateGroup group;

  @override
  ConsumerState<_DuplicateGroupCard> createState() =>
      _DuplicateGroupCardState();
}

class _DuplicateGroupCardState extends ConsumerState<_DuplicateGroupCard> {
  String? _keepId;

  @override
  void initState() {
    super.initState();
    _keepId = widget.group.items.first.id;
  }

  String get _kindLabel => switch (widget.group.kind) {
        DuplicateKind.exactBarcode => 'Same barcode',
        DuplicateKind.fuzzyTitle => 'Same title + year',
        DuplicateKind.none => 'Unknown',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _kindLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // RadioGroup owns the selected value + change callback. The
          // child RadioListTiles only declare `value`; groupValue and
          // onChanged on individual tiles are deprecated.
          RadioGroup<String>(
            groupValue: _keepId,
            onChanged: (v) => setState(() => _keepId = v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in widget.group.items)
                  RadioListTile<String>(
                    key: Key('dedupe-radio-${item.id}'),
                    contentPadding: EdgeInsets.zero,
                    value: item.id,
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.mediaType.name} • barcode ${item.barcode}'
                      '${item.year != null ? ' • ${item.year}' : ''}',
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: _keepId == null ? null : _merge,
              icon: const Icon(Icons.merge_type, size: 18),
              label: const Text('Keep selected, trash the rest'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _merge() async {
    final keep = _keepId;
    if (keep == null) return;
    final repo = ref.read(mediaItemRepositoryProvider);
    final toRemove = widget.group.items.where((i) => i.id != keep);
    for (final MediaItem item in toRemove) {
      await repo.softDelete(item.id);
    }
    ref.invalidate(dedupeGroupsProvider);
  }
}
