import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
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
            ScreenHeader(
              title: 'Settings',
              subtitle:
                  'Manage your API keys, sync configuration, and preferences.',
              padding: const EdgeInsets.only(bottom: 16),
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

          // Preferences section
          _SectionCard(
            title: 'Preferences',
            colors: colors,
            theme: theme,
            children: [
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
            title: Text('About ${AppConstants.appName}'),
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

class _ThemeModeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    String label(ThemeMode mode) => switch (mode) {
          ThemeMode.system => 'System default',
          ThemeMode.light => 'Light',
          ThemeMode.dark => 'Dark',
        };

    IconData icon(ThemeMode mode) => switch (mode) {
          ThemeMode.system => Icons.brightness_auto,
          ThemeMode.light => Icons.light_mode,
          ThemeMode.dark => Icons.dark_mode,
        };

    return ListTile(
      leading: Icon(icon(currentMode)),
      title: const Text('Theme'),
      subtitle: Text(label(currentMode)),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {currentMode},
        onSelectionChanged: (selection) {
          ref.read(themeModeProvider.notifier).setMode(selection.first);
        },
        showSelectedIcon: false,
      ),
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
    final clickThresholdAsync = ref.watch(clickDetectionThresholdProvider);

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
                  ref.read(ripLibraryPathProvider.notifier).setPath(path);
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
                  ref
                      .read(flacBinaryPathOverrideProvider.notifier)
                      .setPath(path);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Click detection threshold slider
        Text('Click detection threshold',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        clickThresholdAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (threshold) => Row(
            children: [
              Expanded(
                child: Slider(
                  value: threshold,
                  min: 4.0,
                  max: 16.0,
                  divisions: 24,
                  label: threshold.toStringAsFixed(1),
                  onChanged: (value) {
                    ref
                        .read(clickDetectionThresholdProvider.notifier)
                        .setThreshold(value);
                  },
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  threshold.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Higher values reduce false positives; lower values catch more clicks.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}
