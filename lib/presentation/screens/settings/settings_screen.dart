import 'package:audio_defect_detector/audio_defect_detector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/gnudb_settings_section.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_status_tile.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isDesktop)
            const ScreenHeader(
              title: 'Settings',
              subtitle:
                  'Manage your API keys, sync configuration, and preferences.',
              padding: EdgeInsets.only(bottom: 16),
            ),

          // Sync section
          _SectionCard(
            title: 'Sync',
            colors: colors,
            theme: theme,
            children: [
              const SyncStatusTile(),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('PostgreSQL Configuration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/postgres'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Sync History'),
                subtitle: const Text('View past sync operations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/sync-log'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // API Keys section
          _SectionCard(
            title: 'API Integrations',
            colors: colors,
            theme: theme,
            children: const [ApiKeyForm()],
          ),
          const SizedBox(height: 16),

          // GnuDB section — per-disc metadata lookup configuration
          _SectionCard(
            title: 'GnuDB',
            colors: colors,
            theme: theme,
            children: const [GnudbSettingsSection()],
          ),
          const SizedBox(height: 16),

          // Import section — bulk-import collections from external services
          _SectionCard(
            title: 'Import',
            colors: colors,
            theme: theme,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Import from external collection'),
                subtitle:
                    const Text('Goodreads, Discogs, Letterboxd or Trakt'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/import'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Printing section — QR labels for shelves, boxes, items
          _SectionCard(
            title: 'Printing',
            colors: colors,
            theme: theme,
            children: [
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text('Print labels'),
                subtitle: const Text(
                    'QR labels for locations or items, preview and export as PDF'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/labels'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Export section — static HTML bundle
          _SectionCard(
            title: 'Export',
            colors: colors,
            theme: theme,
            children: [
              ListTile(
                leading: const Icon(Icons.public_outlined),
                title: const Text('Static HTML export'),
                subtitle: const Text(
                    'Portable website bundle with filter controls; drop '
                    'into any static host or open locally'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/export'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FLAC Library section (desktop only)
          if (isDesktop) ...[
            _SectionCard(
              title: 'FLAC Library',
              colors: colors,
              theme: theme,
              children: const [_FlacLibrarySection()],
            ),
            const SizedBox(height: 16),
          ],

          // Playback section
          _SectionCard(
            title: 'Playback',
            colors: colors,
            theme: theme,
            children: const [_ReplayGainSection()],
          ),
          const SizedBox(height: 16),

          // Preferences section
          _SectionCard(
            title: 'Preferences',
            colors: colors,
            theme: theme,
            children: [
              _PaletteTile(),
              _ThemeModeTile(),
            ],
          ),
          const SizedBox(height: 16),

          // Danger zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danger Zone',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.error,
                    )),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.warning, color: colors.error),
                  title: const Text('Reset & Re-sync'),
                  subtitle:
                      const Text('Replace local data with remote'),
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Borrowers
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Borrowers'),
            subtitle: const Text('Manage people you lend items to'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/borrowers'),
          ),

          const SizedBox(height: 16),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ${AppConstants.appName}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset local database?'),
        content: const Text(
            'This will replace all local data with data from your PostgreSQL server. This cannot be undone.'),
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
              Navigator.pop(ctx);
              // Trigger full re-sync SYNC-09
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Tappable palette cards (Classic / Popcorn) shown at the top of the
/// Preferences section. Each card renders a miniature of the palette —
/// surface, a primary pill, and three media-type dots — so users can
/// compare side-by-side before committing.
class _PaletteTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFamily =
        ref.watch(themeChoiceProvider.select((c) => c.family));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palette',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PaletteCard(
                  label: 'Classic',
                  selected: currentFamily == ThemeFamily.classic,
                  surface: AppColors.lightSurface,
                  primary: AppColors.lightPrimary,
                  container: AppColors.lightSurfaceContainerHigh,
                  mediaDots: const [
                    AppColors.filmColor,
                    AppColors.musicColor,
                    AppColors.bookColor,
                  ],
                  onTap: () => ref
                      .read(themeChoiceProvider.notifier)
                      .setFamily(ThemeFamily.classic),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PaletteCard(
                  label: 'Popcorn',
                  selected: currentFamily == ThemeFamily.popcorn,
                  surface: AppColors.popcornSurface,
                  primary: AppColors.popcornPrimary,
                  container: AppColors.popcornSurfaceContainer,
                  mediaDots: const [
                    Color(0xFFFF5E3A),
                    Color(0xFFA06DFF),
                    Color(0xFF00C478),
                  ],
                  onTap: () => ref
                      .read(themeChoiceProvider.notifier)
                      .setFamily(ThemeFamily.popcorn),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.label,
    required this.selected,
    required this.surface,
    required this.primary,
    required this.container,
    required this.mediaDots,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color surface;
  final Color primary;
  final Color container;
  final List<Color> mediaDots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label palette',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ringColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Primary pill
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              // Faux card
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: container,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final dot in mediaDots) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        // Both palette cards render a light surface, so a
                        // fixed dark ink colour reads correctly regardless
                        // of the outer theme's brightness.
                        color: AppColors.popcornOnSurface,
                      ),
                    ),
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

class _ThemeModeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBrightness =
        ref.watch(themeChoiceProvider.select((c) => c.brightness));

    String label(ThemeBrightness b) => switch (b) {
          ThemeBrightness.system => 'System default',
          ThemeBrightness.light => 'Light',
          ThemeBrightness.dark => 'Dark',
        };

    IconData icon(ThemeBrightness b) => switch (b) {
          ThemeBrightness.system => Icons.brightness_auto,
          ThemeBrightness.light => Icons.light_mode,
          ThemeBrightness.dark => Icons.dark_mode,
        };

    return ListTile(
      leading: Icon(icon(currentBrightness)),
      title: const Text('Theme'),
      subtitle: Text(label(currentBrightness)),
      trailing: SegmentedButton<ThemeBrightness>(
        segments: const [
          ButtonSegment(
            value: ThemeBrightness.system,
            icon: Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeBrightness.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeBrightness.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {currentBrightness},
        onSelectionChanged: (selection) {
          ref
              .read(themeChoiceProvider.notifier)
              .setBrightness(selection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ReplayGain section
// ---------------------------------------------------------------------------

class _ReplayGainSection extends ConsumerWidget {
  const _ReplayGainSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(replayGainModeProvider);
    final preamp = ref.watch(replayGainPreampProvider);
    final preventClipping = ref.watch(preventClippingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ReplayGain Mode
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('ReplayGain Mode'),
          subtitle: const Text('Normalise track loudness'),
          trailing: SegmentedButton<ReplayGainMode>(
            segments: const [
              ButtonSegment(
                value: ReplayGainMode.off,
                label: Text('Off'),
              ),
              ButtonSegment(
                value: ReplayGainMode.track,
                label: Text('Track'),
              ),
              ButtonSegment(
                value: ReplayGainMode.album,
                label: Text('Album'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              ref
                  .read(replayGainModeProvider.notifier)
                  .setMode(selection.first);
            },
            showSelectedIcon: false,
          ),
        ),

        // Pre-amp
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Pre-amp: ${preamp >= 0 ? '+' : ''}${preamp.toStringAsFixed(1)} dB'),
          subtitle: Slider(
            value: preamp,
            min: -6.0,
            max: 6.0,
            divisions: 24,
            label: '${preamp >= 0 ? '+' : ''}${preamp.toStringAsFixed(1)} dB',
            onChanged: (value) {
              ref.read(replayGainPreampProvider.notifier).setPreamp(value);
            },
          ),
        ),

        // Prevent clipping
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Prevent Clipping'),
          subtitle: const Text('Reduce gain when peak would exceed 0 dBFS'),
          value: preventClipping,
          onChanged: (value) {
            ref
                .read(preventClippingProvider.notifier)
                .setPreventClipping(value);
          },
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.colors,
    required this.theme,
    required this.children,
  });

  final String title;
  final ColorScheme colors;
  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FlacLibrarySection extends ConsumerStatefulWidget {
  const _FlacLibrarySection();

  @override
  ConsumerState<_FlacLibrarySection> createState() =>
      _FlacLibrarySectionState();
}

class _FlacLibrarySectionState extends ConsumerState<_FlacLibrarySection> {
  final _pathController = TextEditingController();
  final _flacBinaryController = TextEditingController();

  @override
  void dispose() {
    _pathController.dispose();
    _flacBinaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pathAsync = ref.watch(ripLibraryPathProvider);
    final scanState = ref.watch(ripScanNotifierProvider);
    final flacBinaryAsync = ref.watch(flacBinaryPathOverrideProvider);
    final clickSensitivityAsync = ref.watch(clickDetectionSensitivityProvider);

    // Initialise text field from stored path
    pathAsync.whenData((path) {
      if (path != null && _pathController.text.isEmpty) {
        _pathController.text = path;
      }
    });

    flacBinaryAsync.whenData((path) {
      if (path != null && _flacBinaryController.text.isEmpty) {
        _flacBinaryController.text = path;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  labelText: 'Library root path',
                  hintText: '/path/to/flac/library',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  ref.read(ripLibraryPathProvider.notifier).setPath(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Browse\u2026',
              onPressed: () async {
                final path =
                    await FilePicker.platform.getDirectoryPath();
                if (path != null) {
                  _pathController.text = path;
                  await ref.read(ripLibraryPathProvider.notifier).setPath(path);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: scanState.status == RipScanStatus.scanning
                  ? null
                  : () {
                      final path = _pathController.text.trim();
                      if (path.isNotEmpty) {
                        ref
                            .read(ripLibraryPathProvider.notifier)
                            .setPath(path);
                        ref
                            .read(ripScanNotifierProvider.notifier)
                            .startScan(path);
                      }
                    },
              child: const Text('Scan Now'),
            ),
            const SizedBox(width: 16),
            if (scanState.status == RipScanStatus.scanning) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning\u2026 ${scanState.albumsScanned}/${scanState.totalDirectories} albums',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (scanState.status == RipScanStatus.complete &&
                scanState.error == null)
              Text(
                '${scanState.albumsScanned} albums scanned, '
                '${scanState.matchedCount} matched',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (scanState.status == RipScanStatus.complete &&
                scanState.error != null)
              Text(
                'Error: ${scanState.error}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // flac binary path override
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _flacBinaryController,
                decoration: const InputDecoration(
                  labelText: 'flac binary path (optional)',
                  hintText: '/opt/homebrew/bin/flac',
                  helperText: 'Leave empty to use flac from PATH',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  ref
                      .read(flacBinaryPathOverrideProvider.notifier)
                      .setPath(value.trim());
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Browse\u2026',
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  dialogTitle: 'Select flac binary',
                );
                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  _flacBinaryController.text = path;
                  await ref
                      .read(flacBinaryPathOverrideProvider.notifier)
                      .setPath(path);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Click detection sensitivity
        Text('Click detection sensitivity',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        clickSensitivityAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (sensitivity) => SegmentedButton<Sensitivity>(
            segments: const [
              ButtonSegment(value: Sensitivity.low, label: Text('Low')),
              ButtonSegment(
                  value: Sensitivity.medium, label: Text('Medium')),
              ButtonSegment(value: Sensitivity.high, label: Text('High')),
            ],
            selected: {sensitivity},
            onSelectionChanged: (selected) {
              ref
                  .read(clickDetectionSensitivityProvider.notifier)
                  .setSensitivity(selected.first);
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Higher sensitivity catches more defects but may flag legitimate transients.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}
