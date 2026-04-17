// Static HTML export — bundle the collection as a portable website.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/data/services/static_export_writer.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/services/static_export_service.dart';
import 'package:mymediascanner/presentation/providers/recommendations_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';
import 'package:url_launcher/url_launcher.dart';

class StaticExportScreen extends ConsumerStatefulWidget {
  const StaticExportScreen({super.key});

  @override
  ConsumerState<StaticExportScreen> createState() =>
      _StaticExportScreenState();
}

class _StaticExportScreenState extends ConsumerState<StaticExportScreen> {
  final _titleController = TextEditingController(text: 'My collection');
  final _privateTagController = TextEditingController(text: 'private');
  bool _bundleCovers = false;
  bool _running = false;
  int _progressDone = 0;
  int _progressTotal = 0;
  String? _resultPath;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _privateTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformCapability.isDesktop;
    final theme = Theme.of(context);

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const Text('Export collection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const ScreenHeader(
                title: 'Export collection',
                subtitle:
                    'Bundle the collection as a static HTML site with a '
                    'searchable grid and per-item pages. Private items '
                    '(tagged) are excluded.',
              ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Site title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _privateTagController,
                    decoration: const InputDecoration(
                      labelText: 'Private tag (excluded from export)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Download and bundle cover art'),
                    subtitle: const Text(
                        'Fetches every cover URL. Without this the export '
                        'references the original hosts, which may 404 later.'),
                    value: _bundleCovers,
                    onChanged: _running
                        ? null
                        : (v) => setState(() => _bundleCovers = v),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(_running
                        ? 'Exporting…'
                        : 'Choose folder and export'),
                    onPressed: _running ? null : _export,
                  ),
                  if (_running || _progressTotal > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progressTotal == 0
                          ? null
                          : _progressDone / _progressTotal,
                    ),
                    const SizedBox(height: 4),
                    Text('$_progressDone / $_progressTotal',
                        style: theme.textTheme.bodySmall),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: TextStyle(
                            color: theme.colorScheme.error)),
                  ],
                  if (_resultPath != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.surfaceContainerHigh,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Export complete',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            SelectableText(_resultPath!),
                            const SizedBox(height: 12),
                            Row(children: [
                              FilledButton.tonalIcon(
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('Open index.html'),
                                onPressed: () => _launch(_resultPath!),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose export folder',
    );
    if (dirPath == null) return;

    setState(() {
      _running = true;
      _progressDone = 0;
      _progressTotal = 0;
      _errorMessage = null;
      _resultPath = null;
    });

    try {
      final items = ref.read(ownedItemsProvider).value ?? <MediaItem>[];
      final writer = StaticExportWriter();
      final indexPath = await writer.write(
        targetDir: Directory(dirPath),
        items: items,
        options: StaticExportOptions(
          title: _titleController.text.trim().isEmpty
              ? 'My collection'
              : _titleController.text.trim(),
          privateTag: _privateTagController.text.trim().isEmpty
              ? 'private'
              : _privateTagController.text.trim(),
          bundleCovers: _bundleCovers,
        ),
        onProgress: (done, total) {
          if (mounted) {
            setState(() {
              _progressDone = done;
              _progressTotal = total;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _running = false;
          _resultPath = indexPath;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _running = false;
          _errorMessage = 'Export failed: $e';
        });
      }
    }
  }

  Future<void> _launch(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
