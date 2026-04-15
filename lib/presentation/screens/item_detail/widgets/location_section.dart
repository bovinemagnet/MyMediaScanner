// Item-detail Location section — shows the breadcrumb path for the item's
// physical location and lets the user reassign or clear it.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/location_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class LocationSection extends ConsumerWidget {
  const LocationSection({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locationId = item.locationId;

    Widget body;
    if (locationId == null) {
      body = Text(
        'No location assigned',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    } else {
      body = Consumer(builder: (context, ref, _) {
        final ancestors = ref.watch(locationAncestorsProvider(locationId));
        return ancestors.when(
          loading: () => const SizedBox(
            height: 16,
            child: LinearProgressIndicator(),
          ),
          error: (e, _) => Text('Error: $e'),
          data: (path) {
            if (path.isEmpty) {
              return Text(
                'Location no longer exists',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                ),
              );
            }
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < path.length; i++) ...[
                  Text(path[i].name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: i == path.length - 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                      )),
                  if (i < path.length - 1)
                    Icon(Icons.chevron_right,
                        size: 16, color: colors.outline),
                ],
              ],
            );
          },
        );
      });
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
                'LOCATION',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _changeLocation(context, ref),
                icon: Icon(
                  locationId == null ? Icons.add_location : Icons.edit_location,
                  size: 18,
                ),
                label: Text(locationId == null ? 'Assign' : 'Change'),
              ),
              if (locationId != null)
                IconButton(
                  tooltip: 'Clear location',
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _saveLocation(ref, null),
                ),
            ],
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }

  Future<void> _changeLocation(BuildContext context, WidgetRef ref) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => const _LocationPickerDialog(),
    );
    if (picked == null) return;
    await _saveLocation(ref, picked);
  }

  Future<void> _saveLocation(WidgetRef ref, String? newLocationId) async {
    final updated = item.copyWith(
      locationId: newLocationId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await ref.read(mediaItemRepositoryProvider).update(updated);
  }
}

class _LocationPickerDialog extends ConsumerWidget {
  const _LocationPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocations = ref.watch(allLocationsProvider);
    return AlertDialog(
      title: const Text('Pick a location'),
      content: SizedBox(
        width: 360,
        height: 400,
        child: asyncLocations.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (locations) {
            if (locations.isEmpty) {
              return const Center(
                child: Text('No locations defined yet.'),
              );
            }
            final byParent = <String?, List<Location>>{};
            for (final l in locations) {
              byParent.putIfAbsent(l.parentId, () => []).add(l);
            }
            return ListView(
              children: [
                for (final root in byParent[null] ?? const [])
                  _PickerNode(node: root, byParent: byParent),
              ],
            );
          },
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

class _PickerNode extends StatelessWidget {
  const _PickerNode({required this.node, required this.byParent});

  final Location node;
  final Map<String?, List<Location>> byParent;

  @override
  Widget build(BuildContext context) {
    final children = byParent[node.id] ?? const [];
    if (children.isEmpty) {
      return ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(node.name),
        onTap: () => Navigator.pop(context, node.id),
      );
    }
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(node.name),
      trailing: TextButton(
        onPressed: () => Navigator.pop(context, node.id),
        child: const Text('Pick'),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: [
        for (final child in children)
          _PickerNode(node: child, byParent: byParent),
      ],
    );
  }
}
