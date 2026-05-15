// Backup + restore UI for the local database.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/services/backup_service.dart';

final _backupServiceProvider = Provider<BackupService>(
  (ref) => const BackupService(),
);

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backups capture the full local database. Restoring '
              'overwrites the currently-active database — restart the '
              'app afterwards so it reopens from the restored file.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('backup-create-button'),
              onPressed: _busy ? null : _createBackup,
              icon: const Icon(Icons.save_alt),
              label: const Text('Create backup'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('backup-restore-button'),
              onPressed: _busy ? null : _restoreBackup,
              icon: const Icon(Icons.restore),
              label: const Text('Restore from backup file'),
            ),
            const SizedBox(height: 24),
            if (_busy) const LinearProgressIndicator(),
            if (_statusMessage != null && !_busy)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _statusMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      final destination = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose backup destination folder',
      );
      if (destination == null) return;
      final path = await ref
          .read(_backupServiceProvider)
          .createBackup(destination);
      setState(() => _statusMessage = 'Backup saved at $path');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace database?'),
        content: const Text(
          'Restoring overwrites your current local data. Make sure you '
          'have an export of any unsynced work first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choose backup `.db` file',
      );
      final path = result?.files.single.path;
      if (path == null) return;
      await ref.read(_backupServiceProvider).restoreFromBackup(path);
      setState(() => _statusMessage =
          'Restore complete. Restart the app for the changes to take effect.');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
