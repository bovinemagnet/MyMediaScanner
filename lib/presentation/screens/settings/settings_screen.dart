import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_status_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync section
          Text('Sync', style: Theme.of(context).textTheme.titleMedium),
          const SyncStatusTile(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('PostgreSQL Configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/postgres'),
          ),
          const Divider(height: 32),

          // API Keys section
          const ApiKeyForm(),
          const Divider(height: 32),

          // FLAC Library section (desktop only)
          if (PlatformCapability.isDesktop) ...[
            Text('FLAC Library',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _FlacLibrarySection(),
            const Divider(height: 32),
          ],

          // Preferences section
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Theme — placeholder for full implementation
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // Theme picker — SET-07
            },
          ),

          const Divider(height: 32),

          // Danger zone
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: Icon(Icons.warning,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Reset & Re-sync'),
            subtitle: const Text('Replace local data with remote'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(height: 32),

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
