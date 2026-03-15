import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

/// Supported export formats.
enum ExportFormat { csv, json }

/// Exports the full collection as CSV or JSON to a file.
///
/// Author: Paul Snow
/// @since 0.0.0
class ExportCollectionUseCase {
  const ExportCollectionUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  /// Generates the export content as a [String] in the given [format].
  Future<String> generateContent(ExportFormat format) async {
    final items = await _repo.watchAll().first;
    final activeItems = items.where((item) => !item.deleted).toList();

    return switch (format) {
      ExportFormat.csv => _toCsv(activeItems),
      ExportFormat.json => _toJson(activeItems),
    };
  }

  /// Generates content and writes it to a file in [outputDirectory].
  /// Returns the full path of the written file.
  Future<String> execute({
    required ExportFormat format,
    required String outputDirectory,
  }) async {
    final content = await generateContent(format);
    final extension = format == ExportFormat.csv ? 'csv' : 'json';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'my_media_collection_$timestamp.$extension';
    final filePath = '$outputDirectory/$fileName';

    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(filePath);
    await file.writeAsString(content);

    return filePath;
  }

  String _toCsv(List<MediaItem> items) {
    const header =
        'barcode,barcodeType,mediaType,title,subtitle,year,publisher,'
        'format,genres,userRating,userReview,dateAdded,dateScanned';

    final rows = items.map((item) {
      return [
        _escapeCsv(item.barcode),
        _escapeCsv(item.barcodeType),
        _escapeCsv(item.mediaType.name),
        _escapeCsv(item.title),
        _escapeCsv(item.subtitle ?? ''),
        item.year?.toString() ?? '',
        _escapeCsv(item.publisher ?? ''),
        _escapeCsv(item.format ?? ''),
        _escapeCsv(item.genres.join(';')),
        item.userRating?.toString() ?? '',
        _escapeCsv(item.userReview ?? ''),
        item.dateAdded.toString(),
        item.dateScanned.toString(),
      ].join(',');
    });

    return [header, ...rows].join('\n');
  }

  String _toJson(List<MediaItem> items) {
    final list = items.map((item) {
      return <String, dynamic>{
        'barcode': item.barcode,
        'barcodeType': item.barcodeType,
        'mediaType': item.mediaType.name,
        'title': item.title,
        'subtitle': item.subtitle,
        'description': item.description,
        'coverUrl': item.coverUrl,
        'year': item.year,
        'publisher': item.publisher,
        'format': item.format,
        'genres': item.genres,
        'extraMetadata': item.extraMetadata,
        'sourceApis': item.sourceApis,
        'userRating': item.userRating,
        'userReview': item.userReview,
        'dateAdded': item.dateAdded,
        'dateScanned': item.dateScanned,
        'updatedAt': item.updatedAt,
      };
    }).toList();

    return const JsonEncoder.withIndent('  ').convert(list);
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
