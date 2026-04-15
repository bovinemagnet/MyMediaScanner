// Label printing — batch-select media items or locations, pick a sheet
// preset, preview and export the generated PDF.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/label_sheet_preset.dart';
import 'package:mymediascanner/domain/entities/label_target.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/services/label_pdf_generator.dart';
import 'package:mymediascanner/presentation/providers/location_provider.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';
import 'package:printing/printing.dart';

enum _LabelSource { items, locations }

class LabelPrintScreen extends ConsumerStatefulWidget {
  const LabelPrintScreen({super.key});

  @override
  ConsumerState<LabelPrintScreen> createState() => _LabelPrintScreenState();
}

class _LabelPrintScreenState extends ConsumerState<LabelPrintScreen> {
  _LabelSource _source = _LabelSource.locations;
  LabelSheetPreset _preset = LabelSheetPresets.a4_24;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformCapability.isDesktop;
    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const Text('Print labels')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const ScreenHeader(
                title: 'Print labels',
                subtitle:
                    'Generate a printable sheet of QR labels for your '
                    'locations or items.',
              ),
            _Toolbar(
              source: _source,
              preset: _preset,
              onSourceChanged: (s) => setState(() {
                _source = s;
                _selectedIds.clear();
              }),
              onPresetChanged: (p) => setState(() => _preset = p),
              selectedCount: _selectedIds.length,
              onPreview: _selectedIds.isEmpty ? null : _preview,
            ),
            const SizedBox(height: 12),
            Expanded(child: _source == _LabelSource.locations
                ? _LocationSelector(
                    selected: _selectedIds,
                    onToggle: _toggle,
                  )
                : _ItemSelector(
                    selected: _selectedIds,
                    onToggle: _toggle,
                  )),
          ],
        ),
      ),
    );
  }

  void _toggle(String id, bool on) {
    setState(() {
      if (on) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _preview() async {
    final targets = <LabelTarget>[];
    if (_source == _LabelSource.locations) {
      final all = ref.read(allLocationsProvider).value ?? const <Location>[];
      for (final l in all) {
        if (_selectedIds.contains(l.id)) {
          targets.add(LabelTarget(
            qrPayload: LabelTarget.locationPayload(l.id),
            title: l.name,
            subtitle: 'Location',
          ));
        }
      }
    } else {
      final all = ref.read(ownedItemsProvider).value ?? const <MediaItem>[];
      for (final item in all) {
        if (_selectedIds.contains(item.id)) {
          targets.add(LabelTarget(
            qrPayload: LabelTarget.itemPayload(item.id),
            title: item.title,
            subtitle: item.publisher ?? item.format,
          ));
        }
      }
    }

    const generator = LabelPdfGenerator();
    final bytes = await generator.generate(
      targets: targets,
      preset: _preset,
    );
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'mymediascanner-labels',
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.source,
    required this.preset,
    required this.onSourceChanged,
    required this.onPresetChanged,
    required this.selectedCount,
    required this.onPreview,
  });

  final _LabelSource source;
  final LabelSheetPreset preset;
  final ValueChanged<_LabelSource> onSourceChanged;
  final ValueChanged<LabelSheetPreset> onPresetChanged;
  final int selectedCount;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<_LabelSource>(
          segments: const [
            ButtonSegment(
              value: _LabelSource.locations,
              icon: Icon(Icons.place_outlined),
              label: Text('Locations'),
            ),
            ButtonSegment(
              value: _LabelSource.items,
              icon: Icon(Icons.library_music_outlined),
              label: Text('Items'),
            ),
          ],
          selected: {source},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onSourceChanged(s.first),
        ),
        DropdownButton<LabelSheetPreset>(
          value: preset,
          items: [
            for (final p in LabelSheetPresets.builtIn)
              DropdownMenuItem(value: p, child: Text(p.name)),
          ],
          onChanged: (p) {
            if (p != null) onPresetChanged(p);
          },
        ),
        Text('$selectedCount selected'),
        FilledButton.icon(
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Preview / print'),
          onPressed: onPreview,
        ),
      ],
    );
  }
}

class _LocationSelector extends ConsumerWidget {
  const _LocationSelector({required this.selected, required this.onToggle});

  final Set<String> selected;
  final void Function(String id, bool on) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allLocationsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (locations) {
        if (locations.isEmpty) {
          return const Center(child: Text('No locations defined yet.'));
        }
        return ListView.separated(
          itemCount: locations.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final l = locations[i];
            final isSelected = selected.contains(l.id);
            return CheckboxListTile(
              value: isSelected,
              title: Text(l.name),
              subtitle: Text(LabelTarget.locationPayload(l.id)),
              onChanged: (v) => onToggle(l.id, v ?? false),
            );
          },
        );
      },
    );
  }
}

class _ItemSelector extends ConsumerWidget {
  const _ItemSelector({required this.selected, required this.onToggle});

  final Set<String> selected;
  final void Function(String id, bool on) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownedItemsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
              child: Text('No owned items in the collection.'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final item = items[i];
            final isSelected = selected.contains(item.id);
            return CheckboxListTile(
              value: isSelected,
              title: Text(item.title, maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(LabelTarget.itemPayload(item.id)),
              onChanged: (v) => onToggle(item.id, v ?? false),
            );
          },
        );
      },
    );
  }
}
