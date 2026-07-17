import 'package:audio_defect_detector/audio_defect_detector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
import 'package:mymediascanner/presentation/providers/text_scale_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/gnudb_settings_section.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_account_sync_section.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_lists_section.dart';
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
            children: const [
              ApiKeyForm(),
              TmdbAccountSyncSection(),
              TmdbListsSection(),
            ],
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

          _SectionCard(
            title: 'Maintenance',
            colors: colors,
            theme: theme,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Trash'),
                subtitle: const Text(
                    'Restore or permanently delete items you removed '
                    'from the collection'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/trash'),
              ),
              ListTile(
                leading: const Icon(Icons.merge_type),
                title: const Text('Find duplicates'),
                subtitle: const Text(
                    'Scan the library for items with the same barcode '
                    'or a near-identical title and year'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/dedupe'),
              ),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Backup & restore'),
                subtitle: const Text(
                    'Copy the local database to a portable file, or '
                    'restore from a previously-saved backup'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/backup'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FLAC Library section (desktop only)
          _SectionCard(
            title: 'Accessibility',
            colors: colors,
            theme: theme,
            children: const [_TextScaleSection()],
          ),
          const SizedBox(height: 16),

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

          // Danger zone — Material wrapper (not Container) so the inner
          // ListTile's tap ripple has a Material surface to paint on.
          Material(
            color: colors.errorContainer.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colors.error.withValues(alpha: 0.2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final repo = ref.read(syncRepositoryProvider);
              if (repo == null) {
                messenger.showSnackBar(const SnackBar(
                  content:
                      Text('Configure PostgreSQL first to reset.'),
                ));
                return;
              }
              try {
                await repo.resetLocalDatabase();
                // The reset can take seconds (full pull from Postgres).
                // If the user navigated away from Settings during the
                // await, the SnackBar must not fire on a torn-down
                // context — `messenger` is captured pre-await but we
                // still check `context.mounted` as the canonical guard.
                if (!context.mounted) return;
                messenger.showSnackBar(const SnackBar(
                  content: Text('Local data replaced with remote.'),
                ));
              } on Exception catch (e) {
                if (!context.mounted) return;
                messenger.showSnackBar(SnackBar(
                  content: Text('Reset failed: $e'),
                ));
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Tappable palette cards shown at the top of the Preferences section.
/// Each card renders a miniature of the palette — surface, a primary pill,
/// and three media-type dots — so users can compare before committing.
class _PaletteTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFamily =
        ref.watch(themeChoiceProvider.select((c) => c.family));
    final theme = Theme.of(context);

    Widget card({
      required String label,
      required ThemeFamily family,
      required Color surface,
      required Color primary,
      required Color container,
      required List<Color> mediaDots,
      required Color labelColor,
    }) {
      return Expanded(
        child: _PaletteCard(
          label: label,
          selected: currentFamily == family,
          surface: surface,
          primary: primary,
          container: container,
          mediaDots: mediaDots,
          labelColor: labelColor,
          onTap: () =>
              ref.read(themeChoiceProvider.notifier).setFamily(family),
        ),
      );
    }

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
              card(
                label: 'Classic',
                family: ThemeFamily.classic,
                surface: AppColors.lightSurface,
                primary: AppColors.lightPrimary,
                container: AppColors.lightSurfaceContainerHigh,
                mediaDots: const [
                  AppColors.filmColor,
                  AppColors.musicColor,
                  AppColors.bookColor,
                ],
                labelColor: AppColors.lightOnSurface,
              ),
              const SizedBox(width: 10),
              card(
                label: 'Popcorn',
                family: ThemeFamily.popcorn,
                surface: AppColors.popcornSurface,
                primary: AppColors.popcornPrimary,
                container: AppColors.popcornSurfaceContainer,
                mediaDots: const [
                  Color(0xFFFF5E3A),
                  Color(0xFFA06DFF),
                  Color(0xFF00C478),
                ],
                labelColor: AppColors.popcornOnSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              card(
                label: 'Kinetic',
                family: ThemeFamily.kinetic,
                surface: AppColors.kineticDarkSurface,
                primary: AppColors.kineticDarkPrimary,
                container: AppColors.kineticDarkSurfaceContainerHigh,
                mediaDots: const [
                  Color(0xFFFF6E6E),
                  Color(0xFFC08CFF),
                  Color(0xFF5BD6A0),
                ],
                labelColor: AppColors.kineticDarkOnSurface,
              ),
              const SizedBox(width: 10),
              card(
                label: 'Vault',
                family: ThemeFamily.vault,
                surface: AppColors.vaultDarkSurface,
                primary: AppColors.vaultDarkPrimary,
                container: AppColors.vaultDarkSurfaceContainerHigh,
                mediaDots: const [
                  Color(0xFFE0654C),
                  Color(0xFFB98BE0),
                  Color(0xFF6FC58C),
                ],
                labelColor: AppColors.vaultDarkOnSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              card(
                label: 'Index',
                family: ThemeFamily.cobalt,
                surface: AppColors.indexDarkSurface,
                primary: AppColors.indexDarkPrimary,
                container: AppColors.indexDarkSurfaceContainerHigh,
                mediaDots: const [
                  Color(0xFFFF6B6B),
                  Color(0xFFA98BFF),
                  Color(0xFF3FD18A),
                ],
                labelColor: AppColors.indexDarkOnSurface,
              ),
              const Expanded(child: SizedBox()),
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
    required this.labelColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color surface;
  final Color primary;
  final Color container;
  final List<Color> mediaDots;
  final Color labelColor;
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
                        color: labelColor,
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
      // Drop the default 16dp side padding (matching the ReplayGain tiles
      // below) so the three-segment brightness control doesn't starve the
      // title column and force "Theme" to wrap character-by-character (#98).
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon(currentBrightness)),
      title: const Text('Theme', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        label(currentBrightness),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
    // Material (not Container) so ListTile children get an actual
    // Material ancestor to paint ink ripples on. A Container with a
    // background colour swallows the splash.
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
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

  /// One-shot seed flags — once we've written the stored value into a
  /// controller, never overwrite it again. The earlier `text.isEmpty`
  /// guard re-seeded the field if the user cleared it, clobbering an
  /// in-progress edit on the next rebuild (e.g. when
  /// `ripScanNotifierProvider` re-emits scan progress).
  bool _pathSeeded = false;
  bool _flacBinarySeeded = false;

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

    // Initialise text fields from stored values exactly once.
    pathAsync.whenData((path) {
      if (!_pathSeeded && path != null) {
        _pathController.text = path;
        _pathSeeded = true;
      } else if (!_pathSeeded && path == null) {
        // Mark seeded even when the stored value is null so a delayed
        // user edit isn't overwritten by a later null re-emission.
        _pathSeeded = true;
      }
    });

    flacBinaryAsync.whenData((path) {
      if (!_flacBinarySeeded && path != null) {
        _flacBinaryController.text = path;
        _flacBinarySeeded = true;
      } else if (!_flacBinarySeeded && path == null) {
        _flacBinarySeeded = true;
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
                  // setPickedPath also captures a security-scoped
                  // bookmark while the picker's sandbox grant is live,
                  // so the folder stays readable after a restart.
                  await ref
                      .read(ripLibraryPathProvider.notifier)
                      .setPickedPath(path);
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

class _TextScaleSection extends ConsumerWidget {
  const _TextScaleSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scaleAsync = ref.watch(textScaleProvider);
    final notifier = ref.read(textScaleProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Text size', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Stacks on top of the platform text-size setting so the whole '
            'app scales together with the rest of your device.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          scaleAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed: $e'),
            data: (factor) => Wrap(
              spacing: 8,
              children: [
                for (final option in const [1.0, 1.15, 1.3, 1.5])
                  ChoiceChip(
                    label: Text(
                      option == 1.0
                          ? 'Default'
                          : '${(option * 100).round()}%',
                    ),
                    selected: factor == option,
                    onSelected: (_) => notifier.setFactor(option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
