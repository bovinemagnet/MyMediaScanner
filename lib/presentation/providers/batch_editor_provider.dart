// Batch editor provider — manages a queue of scanned items pending review.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

// ── Status enum ──────────────────────────────────────────────────────

enum BatchItemStatus {
  /// Metadata auto-matched with high confidence.
  confirmed,

  /// Multiple metadata matches — needs user disambiguation.
  conflict,

  /// No metadata found for this barcode.
  notFound,

  /// Already exists in collection.
  duplicate,

  /// Successfully saved to the collection.
  saved,
}

// ── Batch item model ─────────────────────────────────────────────────

class BatchItem {
  BatchItem({
    required this.id,
    required this.barcode,
    required this.barcodeType,
    required this.status,
    required this.scannedAt,
    this.metadata,
    this.scanResult,
  });

  final String id;
  final String barcode;
  final String barcodeType;
  final DateTime scannedAt;
  BatchItemStatus status;

  /// Resolved metadata (available when status is confirmed or saved).
  MetadataResult? metadata;

  /// Original scan result (kept for conflict resolution).
  ScanResult? scanResult;

  String get title => metadata?.title ?? barcode;
  String? get subtitle => metadata?.subtitle;
  String? get coverUrl => metadata?.coverUrl;
  MediaType get mediaType => metadata?.mediaType ?? MediaType.unknown;

  BatchItem copyWith({
    BatchItemStatus? status,
    MetadataResult? metadata,
    ScanResult? scanResult,
  }) {
    return BatchItem(
      id: id,
      barcode: barcode,
      barcodeType: barcodeType,
      scannedAt: scannedAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      scanResult: scanResult ?? this.scanResult,
    );
  }
}

// ── Batch editor state ───────────────────────────────────────────────

class BatchEditorState {
  const BatchEditorState({
    this.items = const [],
    this.isSaving = false,
  });

  final List<BatchItem> items;
  final bool isSaving;

  int get totalCount => items.length;
  int get confirmedCount =>
      items.where((i) => i.status == BatchItemStatus.confirmed).length;
  int get conflictCount =>
      items.where((i) => i.status == BatchItemStatus.conflict).length;
  int get notFoundCount =>
      items.where((i) => i.status == BatchItemStatus.notFound).length;
  int get duplicateCount =>
      items.where((i) => i.status == BatchItemStatus.duplicate).length;
  int get savedCount =>
      items.where((i) => i.status == BatchItemStatus.saved).length;
  int get needsReviewCount => conflictCount + notFoundCount;

  double get autoMatchRate {
    if (totalCount == 0) return 0;
    return (confirmedCount + savedCount + duplicateCount) / totalCount * 100;
  }

  BatchEditorState copyWith({
    List<BatchItem>? items,
    bool? isSaving,
  }) {
    return BatchEditorState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// ── Batch editor notifier ────────────────────────────────────────────

class BatchEditorNotifier extends Notifier<BatchEditorState> {
  static const _uuid = Uuid();

  @override
  BatchEditorState build() => const BatchEditorState();

  /// Add a scan result to the batch queue.
  void addScanResult(ScanResult result) {
    final item = switch (result) {
      SingleScanResult(:final metadata, :final isDuplicate) => BatchItem(
          id: _uuid.v7(),
          barcode: metadata.barcode,
          barcodeType: metadata.barcodeType,
          scannedAt: DateTime.now(),
          status:
              isDuplicate ? BatchItemStatus.duplicate : BatchItemStatus.confirmed,
          metadata: metadata,
          scanResult: result,
        ),
      MultiMatchScanResult(:final barcode, :final barcodeType) => BatchItem(
          id: _uuid.v7(),
          barcode: barcode,
          barcodeType: barcodeType,
          scannedAt: DateTime.now(),
          status: BatchItemStatus.conflict,
          scanResult: result,
        ),
      NotFoundScanResult(:final barcode, :final barcodeType) => BatchItem(
          id: _uuid.v7(),
          barcode: barcode,
          barcodeType: barcodeType,
          scannedAt: DateTime.now(),
          status: BatchItemStatus.notFound,
          scanResult: result,
        ),
    };

    state = state.copyWith(items: [...state.items, item]);
  }

  /// Resolve a conflict by selecting metadata for an item.
  void resolveItem(String itemId, MetadataResult metadata) {
    final updated = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          status: BatchItemStatus.confirmed,
          metadata: metadata,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Remove an item from the batch.
  void removeItem(String itemId) {
    final updated = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: updated);
  }

  /// Save a single confirmed item to the collection.
  Future<void> saveItem(String itemId) async {
    final item = state.items.firstWhere((i) => i.id == itemId);
    if (item.status != BatchItemStatus.confirmed || item.metadata == null) {
      return;
    }

    final useCase = SaveMediaItemUseCase(
      repository: ref.read(mediaItemRepositoryProvider),
    );

    await useCase.execute(item.metadata!);

    final updated = state.items.map((i) {
      if (i.id == itemId) return i.copyWith(status: BatchItemStatus.saved);
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Save all confirmed items to the collection.
  Future<void> saveAllConfirmed() async {
    state = state.copyWith(isSaving: true);

    final useCase = SaveMediaItemUseCase(
      repository: ref.read(mediaItemRepositoryProvider),
    );

    final updated = <BatchItem>[];
    for (final item in state.items) {
      if (item.status == BatchItemStatus.confirmed && item.metadata != null) {
        await useCase.execute(item.metadata!);
        updated.add(item.copyWith(status: BatchItemStatus.saved));
      } else {
        updated.add(item);
      }
    }

    state = BatchEditorState(items: updated, isSaving: false);
  }

  /// Clear all items from the batch.
  void clearBatch() {
    state = const BatchEditorState();
  }

  /// Clear only saved items, keeping pending/conflict ones.
  void clearSaved() {
    final remaining =
        state.items.where((i) => i.status != BatchItemStatus.saved).toList();
    state = state.copyWith(items: remaining);
  }
}

final batchEditorProvider =
    NotifierProvider<BatchEditorNotifier, BatchEditorState>(
        BatchEditorNotifier.new);
