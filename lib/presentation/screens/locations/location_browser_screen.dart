// Location browser — manages the physical-location hierarchy
// (Room → Shelf → Box → Slot) and shows what items live where.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/presentation/providers/location_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class LocationBrowserScreen extends ConsumerWidget {
  const LocationBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocations = ref.watch(allLocationsProvider);
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const Text('Locations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref, parent: null),
        icon: const Icon(Icons.add),
        label: const Text('New location'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const ScreenHeader(
                title: 'Locations',
                subtitle:
                    'Track where each item physically lives — Room, Shelf, '
                    'Box, Slot.',
              ),
            Expanded(
              child: asyncLocations.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (locations) {
                  if (locations.isEmpty) return const _EmptyState();
                  return _LocationTree(locations: locations);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('No locations yet',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tap "New location" to add a Room, Shelf, Box or Slot.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTree extends ConsumerWidget {
  const _LocationTree({required this.locations});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group children by parentId for O(N) tree assembly.
    final byParent = <String?, List<Location>>{};
    for (final l in locations) {
      byParent.putIfAbsent(l.parentId, () => []).add(l);
    }
    final roots = byParent[null] ?? const [];

    return ListView(
      children: [
        for (final root in roots)
          _LocationNode(node: root, byParent: byParent),
      ],
    );
  }
}

class _LocationNode extends ConsumerWidget {
  const _LocationNode({required this.node, required this.byParent});

  final Location node;
  final Map<String?, List<Location>> byParent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = byParent[node.id] ?? const [];
    if (children.isEmpty) {
      return ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(node.name),
        trailing: _NodeMenu(node: node),
      );
    }
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(node.name),
      trailing: _NodeMenu(node: node),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: [
        for (final child in children)
          _LocationNode(node: child, byParent: byParent),
      ],
    );
  }
}

class _NodeMenu extends ConsumerWidget {
  const _NodeMenu({required this.node});

  final Location node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'add_child':
            await _showCreateDialog(context, ref, parent: node);
          case 'rename':
            await _showRenameDialog(context, ref, node);
          case 'delete':
            await _confirmDelete(context, ref, node);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'add_child', child: Text('Add child')),
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

Future<void> _showCreateDialog(
  BuildContext context,
  WidgetRef ref, {
  required Location? parent,
}) async {
  final controller = TextEditingController();
  final String? result;
  try {
    result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parent == null
            ? 'New top-level location'
            : 'New child of "${parent.name}"'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Living room, Shelf A, Box 3',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }
  if (result == null || result.isEmpty) return;
  await ref
      .read(locationActionsProvider)
      .create(name: result, parentId: parent?.id);
}

Future<void> _showRenameDialog(
    BuildContext context, WidgetRef ref, Location node) async {
  final controller = TextEditingController(text: node.name);
  final String? result;
  try {
    result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename location'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }
  if (result == null || result.isEmpty || result == node.name) return;
  await ref.read(locationActionsProvider).rename(node, result);
}

Future<void> _confirmDelete(
    BuildContext context, WidgetRef ref, Location node) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete "${node.name}"?'),
      content: const Text(
          'Items assigned to this location will keep their reference but '
          'the location will no longer appear in the tree. Children are '
          'not deleted automatically.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await ref.read(locationActionsProvider).delete(node.id);
}
