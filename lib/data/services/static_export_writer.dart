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
///  * persisting every `relative-path → bytes` pair under [targetDir].
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

  /// Write the export. Returns the absolute path to the generated
  /// `index.html`.
  Future<String> write({
    required Directory targetDir,
    required List<MediaItem> items,
    StaticExportOptions options = const StaticExportOptions(),
    void Function(int done, int total)? onProgress,
  }) async {
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    Map<String, Uint8List> covers = const {};
    if (options.bundleCovers) {
      covers = await _fetchCovers(items, onProgress: onProgress);
    }

    final bundle = _service.build(
      items: items,
      options: options,
      covers: covers,
    );

    final total = bundle.length;
    var done = 0;
    onProgress?.call(done, total);

    for (final e in bundle.entries) {
      final file = File(p.join(targetDir.path, e.key));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(e.value);
      done++;
      onProgress?.call(done, total);
    }

    return p.join(targetDir.path, 'index.html');
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
