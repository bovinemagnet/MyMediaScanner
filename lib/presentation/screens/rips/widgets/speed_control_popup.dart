/// Speed control popup widget for selecting playback speed.
///
/// Displays a set of preset speed buttons and a fine-grained slider,
/// wired to [playbackActionProvider] to update the audio engine and
/// [playbackSpeedProvider] to persist the selection.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/playback_speed_provider.dart';

/// Predefined speed presets shown as quick-select buttons.
const _presets = [0.75, 1.0, 1.25, 1.5];

/// Popup panel for selecting playback speed with preset buttons and a slider.
class SpeedControlPopup extends ConsumerWidget {
  /// Creates a [SpeedControlPopup].
  const SpeedControlPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYBACK SPEED',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          // Preset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presets.map((preset) {
              final isSelected = (speed - preset).abs() < 0.01;
              return _PresetButton(
                label: '$preset×',
                selected: isSelected,
                onTap: () => _setSpeed(ref, preset),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Fine-grained slider
          Slider(
            value: speed.clamp(0.5, 2.0),
            min: 0.5,
            max: 2.0,
            divisions: 30,
            label: '${speed.toStringAsFixed(2)}×',
            onChanged: (value) => _setSpeed(ref, value),
          ),
          Center(
            child: Text(
              '${speed.toStringAsFixed(2)}×',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setSpeed(WidgetRef ref, double speed) {
    ref.read(playbackActionProvider.notifier).setSpeed(speed);
  }
}

/// A compact preset speed button.
class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.15),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.primary : colors.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
