// Bottom sheet for the random pick feature. Lets the user tweak the filter
// and roll for a random owned item.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/random_pick_filter.dart';
import 'package:mymediascanner/presentation/providers/random_pick_provider.dart';

class RandomPickSheet extends ConsumerStatefulWidget {
  const RandomPickSheet({super.key});

  @override
  ConsumerState<RandomPickSheet> createState() => _RandomPickSheetState();
}

class _RandomPickSheetState extends ConsumerState<RandomPickSheet> {
  MediaType? _mediaType;
  final _genreCtl = TextEditingController();
  final _runtimeCtl = TextEditingController();
  final _pagesCtl = TextEditingController();
  bool _unratedOnly = false;

  @override
  void dispose() {
    _genreCtl.dispose();
    _runtimeCtl.dispose();
    _pagesCtl.dispose();
    super.dispose();
  }

  RandomPickFilter _buildFilter() {
    final genre = _genreCtl.text.trim();
    return RandomPickFilter(
      mediaType: _mediaType,
      genre: genre.isEmpty ? null : genre,
      maxRuntimeMinutes: int.tryParse(_runtimeCtl.text.trim()),
      maxPageCount: int.tryParse(_pagesCtl.text.trim()),
      unratedOnly: _unratedOnly,
    );
  }

  Future<void> _roll() async {
    final notifier = ref.read(randomPickProvider.notifier);
    notifier.updateFilter(_buildFilter());
    await notifier.roll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pickAsync = ref.watch(randomPickProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick something for me',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MediaType?>(
              initialValue: _mediaType,
              decoration: const InputDecoration(labelText: 'Media type'),
              items: [
                const DropdownMenuItem<MediaType?>(
                  value: null,
                  child: Text('Any'),
                ),
                ...MediaType.values
                    .where((t) => t != MediaType.unknown)
                    .map((t) => DropdownMenuItem<MediaType?>(
                          value: t,
                          child: Text(t.label),
                        )),
              ],
              onChanged: (v) => setState(() => _mediaType = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _genreCtl,
              decoration: const InputDecoration(labelText: 'Genre (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _runtimeCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max runtime (minutes)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pagesCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max pages'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unrated only'),
              value: _unratedOnly,
              onChanged: (v) => setState(() => _unratedOnly = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('random-pick-roll-button'),
                onPressed: pickAsync.isLoading ? null : _roll,
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Roll'),
              ),
            ),
            const SizedBox(height: 16),
            pickAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Error: $e',
                  style: TextStyle(color: colors.error)),
              data: (item) {
                if (item == null) {
                  return Text(
                    'Configure a filter and tap Roll.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  );
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
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(item.subtitle!,
                            style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('random-pick-reroll-button'),
                            onPressed: pickAsync.isLoading ? null : _roll,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Re-roll'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            key: const ValueKey('random-pick-open-button'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/collection/item/${item.id}');
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
