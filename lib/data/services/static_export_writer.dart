import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/services/static_export_service.dart';
import 'package:path/path.dart' as p;

/// Writes a [StaticExportService] bundle to a directory on disk.
///
/// Responsibilities:
///  * optionally fetching cover URLs over HTTP into a `covers` map;
///  * invoking [StaticExportService.build] to render the HTML;
///  * persisting every `relative-path → bytes` pair under [targetDir];
///  * removing files a previous export generated that the current one
///    does not, so an item made private or deleted since then is no
///    longer published. Generated paths are recorded in
///    [manifestFileName]; files the writer did not generate are never
///    touched.
///
/// Progress is reported via [onProgress] with `(done, total)` counts.
class StaticExportWriter {
  StaticExportWriter({
    StaticExportService? service,
    Dio? dio,
  })  : _service = service ?? const StaticExportService(),
        _dio = dio ?? Dio();

  final StaticExportService _service;
  final Dio _dio;

  /// Lists the files the last export generated, relative to the target.
  static const manifestFileName = '.mymediascanner-export.json';

  /// Write the export. Returns the absolute path to the generated
  /// `index.html`.
  Future<String> write({
    required Directory targetDir,
    required List<MediaItem> items,
    Map<String, List<String>> tagsByItemId = const {},
    StaticExportOptions options = const StaticExportOptions(),
    void Function(int done, int total)? onProgress,
  }) async {
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    Map<String, Uint8List> covers = const {};
    if (options.bundleCovers) {
      // Only fetch covers for items the service will actually render —
      // private-tagged and soft-deleted items are excluded from the
      // export, so their covers should never be downloaded either (#101).
      final visible = _service.visibleItems(items, options,
          tagsByItemId: tagsByItemId);
      covers = await _fetchCovers(visible, onProgress: onProgress);
    }

    final bundle = _service.build(
      items: items,
      tagsByItemId: tagsByItemId,
      options: options,
      covers: covers,
    );

    final total = bundle.length;
    var done = 0;
    onProgress?.call(done, total);

    final canonicalRoot = p.canonicalize(targetDir.path);
    final previousFiles = await _readManifest(targetDir);

    for (final e in bundle.entries) {
      // Defence-in-depth: the keys come from [StaticExportService.build]
      // which is in-tree, but a future change there could regress the
      // contract — and a path-traversal bug in the writer is a much
      // sharper failure than one in the service.
      final key = e.key;
      final resolved = _resolveInside(canonicalRoot, targetDir, key);
      if (resolved == null) {
        throw StateError(
            'StaticExportWriter: refusing unsafe bundle key "$key"');
      }
      final file = File(resolved);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(e.value);
      done++;
      onProgress?.call(done, total);
    }

    // Remove what the previous export generated but this one did not.
    // Manifest entries are read back from disk, so they get the same
    // containment check and are skipped, not trusted, when unsafe.
    for (final key in previousFiles.difference(bundle.keys.toSet())) {
      final resolved = _resolveInside(canonicalRoot, targetDir, key);
      if (resolved == null) continue;
      final stale = File(resolved);
      if (await stale.exists()) await stale.delete();
    }

    await File(p.join(targetDir.path, manifestFileName)).writeAsString(
        jsonEncode({'files': bundle.keys.toList()..sort()}));

    return p.join(targetDir.path, 'index.html');
  }

  /// Resolves [key] under [targetDir], or returns null when it is
  /// absolute, contains `..`, or otherwise lands outside the target.
  static String? _resolveInside(
    String canonicalRoot,
    Directory targetDir,
    String key,
  ) {
    if (key.isEmpty ||
        p.isAbsolute(key) ||
        key.split(p.separator).any((s) => s == '..') ||
        key.split('/').any((s) => s == '..')) {
      return null;
    }
    final resolved = p.canonicalize(p.join(targetDir.path, key));
    return p.isWithin(canonicalRoot, resolved) ? resolved : null;
  }

  /// Paths recorded by the previous export, or empty when there is no
  /// readable manifest (first export, or a folder exported by a build
  /// that predates the manifest).
  static Future<Set<String>> _readManifest(Directory targetDir) async {
    final file = File(p.join(targetDir.path, manifestFileName));
    if (!await file.exists()) return const {};
    try {
      final decoded = jsonDecode(await file.readAsString());
      final files = decoded is Map ? decoded['files'] : null;
      if (files is! List) return const {};
      return {for (final f in files) if (f is String) f};
    } on FormatException {
      return const {};
    }
  }

  Future<Map<String, Uint8List>> _fetchCovers(
    List<MediaItem> items, {
    void Function(int done, int total)? onProgress,
  }) async {
    final targets = <MediaItem>[];
    for (final item in items) {
      if (item.coverUrl != null && item.coverUrl!.isNotEmpty) {
        targets.add(item);
      }
    }
    final covers = <String, Uint8List>{};
    var done = 0;
    final total = targets.length;
    onProgress?.call(done, total);

    for (final item in targets) {
      try {
        final response = await _dio.get<List<int>>(
          item.coverUrl!,
          options: Options(responseType: ResponseType.bytes),
        );
        final data = response.data;
        if (data != null && data.isNotEmpty) {
          final ext = _extFromUrl(item.coverUrl!);
          covers['${item.id}$ext'] = Uint8List.fromList(data);
        }
      } on Exception {
        // Skip failed downloads; the HTML falls back to an empty
        // placeholder because the map lookup will miss.
      }
      done++;
      onProgress?.call(done, total);
    }
    return covers;
  }

  static String _extFromUrl(String url) {
    final q = url.indexOf('?');
    final clean = q >= 0 ? url.substring(0, q) : url;
    final slash = clean.lastIndexOf('/');
    final name = slash >= 0 ? clean.substring(slash + 1) : clean;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.jpg';
    final ext = name.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};
    return allowed.contains(ext) ? ext : '.jpg';
  }
}
