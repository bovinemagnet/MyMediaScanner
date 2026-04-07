// Mapper between BatchQueueItemsTableData (Drift) and BatchItem (provider).
//
// Handles manual JSON serialisation for MetadataResult and ScanResult since
// these Freezed models do not use @JsonSerializable.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';

/// Maps a [BatchItem] to a Drift companion for persistence.
BatchQueueItemsTableCompanion batchItemToCompanion(
  BatchItem item,
  String sessionId,
  int sortOrder,
) {
  return BatchQueueItemsTableCompanion(
    id: Value(item.id),
    sessionId: Value(sessionId),
    barcode: Value(item.barcode),
    barcodeType: Value(item.barcodeType),
    status: Value(item.status.name),
    scannedAt: Value(item.scannedAt.millisecondsSinceEpoch),
    metadataJson: Value(item.metadata != null
        ? jsonEncode(_metadataResultToMap(item.metadata!))
        : null),
    scanResultJson: Value(item.scanResult != null
        ? jsonEncode(_scanResultToMap(item.scanResult!))
        : null),
    sortOrder: Value(sortOrder),
  );
}

/// Maps a Drift row back to a [BatchItem].
BatchItem batchItemFromRow(BatchQueueItemsTableData row) {
  MetadataResult? metadata;
  if (row.metadataJson != null) {
    metadata = _metadataResultFromMap(
      jsonDecode(row.metadataJson!) as Map<String, dynamic>,
    );
  }

  ScanResult? scanResult;
  if (row.scanResultJson != null) {
    scanResult = _scanResultFromMap(
      jsonDecode(row.scanResultJson!) as Map<String, dynamic>,
    );
  }

  return BatchItem(
    id: row.id,
    barcode: row.barcode,
    barcodeType: row.barcodeType,
    scannedAt: DateTime.fromMillisecondsSinceEpoch(row.scannedAt),
    status: BatchItemStatus.values.firstWhere(
      (s) => s.name == row.status,
      orElse: () => BatchItemStatus.notFound,
    ),
    metadata: metadata,
    scanResult: scanResult,
  );
}

// ── MetadataResult serialisation ────────────────────────────────────

Map<String, dynamic> _metadataResultToMap(MetadataResult m) {
  return {
    'barcode': m.barcode,
    'barcodeType': m.barcodeType,
    'mediaType': m.mediaType?.name,
    'title': m.title,
    'subtitle': m.subtitle,
    'description': m.description,
    'coverUrl': m.coverUrl,
    'year': m.year,
    'publisher': m.publisher,
    'format': m.format,
    'genres': m.genres,
    'extraMetadata': m.extraMetadata,
    'sourceApis': m.sourceApis,
    'criticScore': m.criticScore,
    'criticSource': m.criticSource,
  };
}

MetadataResult _metadataResultFromMap(Map<String, dynamic> map) {
  return MetadataResult(
    barcode: map['barcode'] as String? ?? '',
    barcodeType: map['barcodeType'] as String? ?? '',
    mediaType: map['mediaType'] != null
        ? MediaType.fromString(map['mediaType'] as String)
        : null,
    title: map['title'] as String?,
    subtitle: map['subtitle'] as String?,
    description: map['description'] as String?,
    coverUrl: map['coverUrl'] as String?,
    year: map['year'] as int?,
    publisher: map['publisher'] as String?,
    format: map['format'] as String?,
    genres: (map['genres'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    extraMetadata: (map['extraMetadata'] as Map<String, dynamic>?) ?? const {},
    sourceApis: (map['sourceApis'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    criticScore: (map['criticScore'] as num?)?.toDouble(),
    criticSource: map['criticSource'] as String?,
  );
}

// ── ScanResult serialisation ────────────────────────────────────────

Map<String, dynamic> _scanResultToMap(ScanResult result) {
  return switch (result) {
    SingleScanResult(:final metadata, :final isDuplicate) => {
        'type': 'single',
        'metadata': _metadataResultToMap(metadata),
        'isDuplicate': isDuplicate,
      },
    MultiMatchScanResult(
      :final candidates,
      :final barcode,
      :final barcodeType
    ) =>
      {
        'type': 'multiMatch',
        'barcode': barcode,
        'barcodeType': barcodeType,
        'candidates': candidates.map(_candidateToMap).toList(),
      },
    NotFoundScanResult(:final barcode, :final barcodeType) => {
        'type': 'notFound',
        'barcode': barcode,
        'barcodeType': barcodeType,
      },
  };
}

ScanResult _scanResultFromMap(Map<String, dynamic> map) {
  final type = map['type'] as String;
  return switch (type) {
    'single' => ScanResult.single(
        metadata: _metadataResultFromMap(
          map['metadata'] as Map<String, dynamic>,
        ),
        isDuplicate: map['isDuplicate'] as bool? ?? false,
      ),
    'multiMatch' => ScanResult.multiMatch(
        barcode: map['barcode'] as String,
        barcodeType: map['barcodeType'] as String,
        candidates: (map['candidates'] as List<dynamic>)
            .map(
                (e) => _candidateFromMap(e as Map<String, dynamic>))
            .toList(),
      ),
    'notFound' => ScanResult.notFound(
        barcode: map['barcode'] as String,
        barcodeType: map['barcodeType'] as String,
      ),
    _ => ScanResult.notFound(
        barcode: map['barcode'] as String? ?? '',
        barcodeType: map['barcodeType'] as String? ?? '',
      ),
  };
}

// ── MetadataCandidate serialisation ─────────────────────────────────

Map<String, dynamic> _candidateToMap(MetadataCandidate c) {
  return {
    'sourceApi': c.sourceApi,
    'sourceId': c.sourceId,
    'title': c.title,
    'subtitle': c.subtitle,
    'coverUrl': c.coverUrl,
    'year': c.year,
    'format': c.format,
    'mediaType': c.mediaType?.name,
  };
}

MetadataCandidate _candidateFromMap(Map<String, dynamic> map) {
  return MetadataCandidate(
    sourceApi: map['sourceApi'] as String? ?? '',
    sourceId: map['sourceId'] as String? ?? '',
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String?,
    coverUrl: map['coverUrl'] as String?,
    year: map['year'] as int?,
    format: map['format'] as String?,
    mediaType: map['mediaType'] != null
        ? MediaType.fromString(map['mediaType'] as String)
        : null,
  );
}
