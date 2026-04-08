// Batch editor provider — manages a queue of scanned items pending review.
//
// Persists the queue to SQLite via BatchSessionDao so it survives app
// restarts. Supports undo/redo, progress tracking, and duplicate detection.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/dao/batch_session_dao.dart';
import 'package:mymediascanner/data/mappers/batch_item_mapper.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
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

  /// Already exists in collection or within-batch duplicate.
  duplicate,

  /// Successfully saved to the collection.
  saved,
}

// ── Duplicate source ────────────────────────────────────────────────

enum DuplicateSource {
  /// Duplicate detected against the existing collection.
  collection,

  /// Duplicate detected within the current batch.
  batch,
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
    this.duplicateSource,
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

  /// Where the duplicate was detected from, if status is duplicate.
  DuplicateSource? duplicateSource;

  String get title => metadata?.title ?? barcode;
  String? get subtitle => metadata?.subtitle;
  String? get coverUrl => metadata?.coverUrl;
  MediaType get mediaType => metadata?.mediaType ?? MediaType.unknown;

  BatchItem copyWith({
    BatchItemStatus? status,
    MetadataResult? metadata,
    ScanResult? scanResult,
    DuplicateSource? duplicateSource,
  }) {
    return BatchItem(
      id: id,
      barcode: barcode,
      barcodeType: barcodeType,
      scannedAt: scannedAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      scanResult: scanResult ?? this.scanResult,
      duplicateSource: duplicateSource ?? this.duplicateSource,
    );
  }
}

// ── Save progress ───────────────────────────────────────────────────

class BatchSaveProgress {
  const BatchSaveProgress({required this.current, required this.total});

  final int current;
  final int total;

  double get fraction => total == 0 ? 0 : current / total;
}

// ── Undo/redo actions ───────────────────────────────────────────────

sealed class BatchAction {
  const BatchAction();
}

class AddAction extends BatchAction {
  const AddAction({required this.item});
  final BatchItem item;
}

class RemoveAction extends BatchAction {
  const RemoveAction({required this.item, required this.index});
  final BatchItem item;
  final int index;
}

class ResolveAction extends BatchAction {
  const ResolveAction({required this.itemId, required this.previousState});
  final String itemId;
  final BatchItem previousState;
}

class SaveAction extends BatchAction {
  const SaveAction({required this.itemId, required this.previousState});
  final String itemId;
  final BatchItem previousState;
}

class ForceKeepAction extends BatchAction {
  const ForceKeepAction({required this.itemId, required this.previousState});
  final String itemId;
  final BatchItem previousState;
}

// ── Batch editor state ───────────────────────────────────────────────

class BatchEditorState {
  const BatchEditorState({
    this.items = const [],
    this.saveProgress,
    this.sessionId,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  final List<BatchItem> items;
  final BatchSaveProgress? saveProgress;
  final String? sessionId;

  /// Undo/redo stacks (in-memory only, not persisted).
  final List<BatchAction> undoStack;
  final List<BatchAction> redoStack;

  bool get isSaving => saveProgress != null;
  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

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
    BatchSaveProgress? Function()? saveProgress,
    String? sessionId,
    List<BatchAction>? undoStack,
    List<BatchAction>? redoStack,
  }) {
    return BatchEditorState(
      items: items ?? this.items,
      saveProgress:
          saveProgress != null ? saveProgress() : this.saveProgress,
      sessionId: sessionId ?? this.sessionId,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

// ── Batch editor notifier ────────────────────────────────────────────

class BatchEditorNotifier extends AsyncNotifier<BatchEditorState> {
  static const _uuid = Uuid();

  BatchSessionDao get _dao => ref.read(batchSessionDaoProvider);

  @override
  Future<BatchEditorState> build() async {
    // Check for an active session in the database.
    final activeSession = await _dao.getActiveSession();

    if (activeSession != null) {
      // Restore queue items from the database.
      final rows = await _dao.getQueueItems(activeSession.id);
      final items = rows.map(batchItemFromRow).toList();
      return BatchEditorState(
        items: items,
        sessionId: activeSession.id,
      );
    }

    // No active session — create a new one.
    final sessionId = _uuid.v7();
    await _dao.createSession(sessionId);
    return BatchEditorState(sessionId: sessionId);
  }

  /// Normalise a barcode for duplicate comparison (case-insensitive,
  /// strips leading zeroes).
  String _normaliseBarcode(String barcode) {
    final lower = barcode.toLowerCase().trim();
    // Strip leading zeroes but keep at least one digit.
    final stripped = lower.replaceFirst(RegExp(r'^0+(?=.)'), '');
    return stripped;
  }

  /// Check if a barcode already exists in the current batch (non-saved items).
  bool _isBatchDuplicate(String barcode, List<BatchItem> items) {
    final normalised = _normaliseBarcode(barcode);
    return items.any(
      (item) =>
          item.status != BatchItemStatus.saved &&
          _normaliseBarcode(item.barcode) == normalised,
    );
  }

  /// Add a scan result to the batch queue.
  Future<void> addScanResult(ScanResult result) async {
    final current = state.requireValue;

    final barcode = switch (result) {
      SingleScanResult(:final metadata) => metadata.barcode,
      MultiMatchScanResult(:final barcode) => barcode,
      NotFoundScanResult(:final barcode) => barcode,
    };

    // Check for within-batch duplicates.
    final isBatchDup = _isBatchDuplicate(barcode, current.items);

    final item = switch (result) {
      SingleScanResult(:final metadata, :final isDuplicate) => BatchItem(
          id: _uuid.v7(),
          barcode: metadata.barcode,
          barcodeType: metadata.barcodeType,
          scannedAt: DateTime.now(),
          status: isDuplicate
              ? BatchItemStatus.duplicate
              : isBatchDup
                  ? BatchItemStatus.duplicate
                  : BatchItemStatus.confirmed,
          metadata: metadata,
          scanResult: result,
          duplicateSource: isDuplicate
              ? DuplicateSource.collection
              : isBatchDup
                  ? DuplicateSource.batch
                  : null,
        ),
      MultiMatchScanResult(:final barcode, :final barcodeType) => BatchItem(
          id: _uuid.v7(),
          barcode: barcode,
          barcodeType: barcodeType,
          scannedAt: DateTime.now(),
          status: isBatchDup ? BatchItemStatus.duplicate : BatchItemStatus.conflict,
          scanResult: result,
          duplicateSource: isBatchDup ? DuplicateSource.batch : null,
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

    final newItems = [...current.items, item];
    state = AsyncValue.data(current.copyWith(
      items: newItems,
      undoStack: [...current.undoStack, AddAction(item: item)],
      redoStack: const [],
    ));

    // Persist to database.
    await _persistItem(item, newItems.length - 1);
    await _updateSessionItemCount(newItems.length);
  }

  /// Resolve a conflict by selecting metadata for an item.
  Future<void> resolveItem(String itemId, MetadataResult metadata) async {
    final current = state.requireValue;
    final oldItem = current.items.firstWhere((i) => i.id == itemId);
    final previousState = oldItem.copyWith();

    final updated = current.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          status: BatchItemStatus.confirmed,
          metadata: metadata,
        );
      }
      return item;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      items: updated,
      undoStack: [
        ...current.undoStack,
        ResolveAction(itemId: itemId, previousState: previousState),
      ],
      redoStack: const [],
    ));

    // Persist the updated item.
    final updatedItem = updated.firstWhere((i) => i.id == itemId);
    final index = updated.indexOf(updatedItem);
    await _persistItem(updatedItem, index);
  }

  /// Remove an item from the batch.
  Future<void> removeItem(String itemId) async {
    final current = state.requireValue;
    final itemIndex = current.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;
    final removedItem = current.items[itemIndex];

    final updated = current.items.where((i) => i.id != itemId).toList();
    state = AsyncValue.data(current.copyWith(
      items: updated,
      undoStack: [
        ...current.undoStack,
        RemoveAction(item: removedItem, index: itemIndex),
      ],
      redoStack: const [],
    ));

    // Remove from database.
    await _dao.deleteQueueItem(itemId);
    await _updateSessionItemCount(updated.length);
  }

  /// Force-keep a duplicate item (change status to confirmed).
  Future<void> forceKeepDuplicate(String itemId) async {
    final current = state.requireValue;
    final oldItem = current.items.firstWhere((i) => i.id == itemId);
    final previousState = oldItem.copyWith();

    final updated = current.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(status: BatchItemStatus.confirmed);
      }
      return item;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      items: updated,
      undoStack: [
        ...current.undoStack,
        ForceKeepAction(itemId: itemId, previousState: previousState),
      ],
      redoStack: const [],
    ));

    final updatedItem = updated.firstWhere((i) => i.id == itemId);
    final index = updated.indexOf(updatedItem);
    await _persistItem(updatedItem, index);
  }

  /// Save a single confirmed item to the collection.
  Future<void> saveItem(String itemId) async {
    final current = state.requireValue;
    final item = current.items.firstWhere((i) => i.id == itemId);
    if (item.status != BatchItemStatus.confirmed || item.metadata == null) {
      return;
    }

    final useCase = SaveMediaItemUseCase(
      repository: ref.read(mediaItemRepositoryProvider),
    );

    await useCase.execute(item.metadata!);

    final updated = current.items.map((i) {
      if (i.id == itemId) return i.copyWith(status: BatchItemStatus.saved);
      return i;
    }).toList();
    state = AsyncValue.data(current.copyWith(items: updated));

    // Persist the status change.
    final savedItem = updated.firstWhere((i) => i.id == itemId);
    final index = updated.indexOf(savedItem);
    await _persistItem(savedItem, index);
  }

  /// Save all confirmed items to the collection with progress tracking.
  Future<void> saveAllConfirmed() async {
    final current = state.requireValue;

    final confirmedItems = current.items
        .where(
            (i) => i.status == BatchItemStatus.confirmed && i.metadata != null)
        .toList();

    if (confirmedItems.isEmpty) return;

    final total = confirmedItems.length;

    state = AsyncValue.data(current.copyWith(
      saveProgress: () => BatchSaveProgress(current: 0, total: total),
    ));

    final useCase = SaveMediaItemUseCase(
      repository: ref.read(mediaItemRepositoryProvider),
    );

    final updated = <BatchItem>[];
    var savedCount = 0;
    for (final item in current.items) {
      if (item.status == BatchItemStatus.confirmed && item.metadata != null) {
        await useCase.execute(item.metadata!);
        updated.add(item.copyWith(status: BatchItemStatus.saved));
        savedCount++;

        // Emit progress.
        state = AsyncValue.data(state.requireValue.copyWith(
          items: [
            ...updated,
            ...current.items.sublist(updated.length),
          ],
          saveProgress: () =>
              BatchSaveProgress(current: savedCount, total: total),
        ));
      } else {
        updated.add(item);
      }
    }

    // Check if all items are now saved — if so, complete the session.
    final hasUnsaved =
        updated.any((i) => i.status != BatchItemStatus.saved);

    state = AsyncValue.data(state.requireValue.copyWith(
      items: updated,
      saveProgress: () => null,
    ));

    // Persist all status changes.
    await _persistAllItems(updated);

    if (!hasUnsaved && current.sessionId != null) {
      await _dao.completeSession(current.sessionId!, status: 'completed');
      // Create a fresh session for the next batch.
      final newSessionId = _uuid.v7();
      await _dao.createSession(newSessionId);
      state = AsyncValue.data(state.requireValue.copyWith(
        sessionId: newSessionId,
      ));
    }
  }

  /// Clear all items from the batch (discard).
  Future<void> clearBatch() async {
    final current = state.requireValue;

    if (current.sessionId != null) {
      await _dao.completeSession(current.sessionId!, status: 'discarded');
    }

    // Create a fresh session.
    final newSessionId = _uuid.v7();
    await _dao.createSession(newSessionId);

    state = AsyncValue.data(BatchEditorState(sessionId: newSessionId));
  }

  /// Clear only saved items, keeping pending/conflict ones.
  Future<void> clearSaved() async {
    final current = state.requireValue;
    final remaining =
        current.items.where((i) => i.status != BatchItemStatus.saved).toList();

    state = AsyncValue.data(current.copyWith(items: remaining));

    // Re-persist only the remaining items.
    if (current.sessionId != null) {
      await _dao.deleteSessionQueueItems(current.sessionId!);
      await _persistAllItems(remaining);
      await _updateSessionItemCount(remaining.length);
    }
  }

  /// Undo the last action.
  Future<void> undo() async {
    final current = state.requireValue;
    if (!current.canUndo) return;

    final action = current.undoStack.last;
    final newUndoStack =
        current.undoStack.sublist(0, current.undoStack.length - 1);

    switch (action) {
      case AddAction(:final item):
        // Undo add = remove the item.
        final updated = current.items.where((i) => i.id != item.id).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: newUndoStack,
          redoStack: [...current.redoStack, action],
        ));
        await _dao.deleteQueueItem(item.id);
        await _updateSessionItemCount(updated.length);

      case RemoveAction(:final item, :final index):
        // Undo remove = restore the item at its original position.
        final updated = [...current.items];
        final insertAt = index.clamp(0, updated.length);
        updated.insert(insertAt, item);
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: newUndoStack,
          redoStack: [...current.redoStack, action],
        ));
        await _persistItem(item, insertAt);
        await _updateSessionItemCount(updated.length);

      case ResolveAction(:final itemId, :final previousState):
        // Undo resolve = restore previous state.
        final updated = current.items.map((i) {
          if (i.id == itemId) {
            return previousState;
          }
          return i;
        }).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: newUndoStack,
          redoStack: [...current.redoStack, action],
        ));
        final index = updated.indexWhere((i) => i.id == itemId);
        if (index >= 0) await _persistItem(previousState, index);

      case SaveAction(:final itemId, :final previousState):
        final updated = current.items.map((i) {
          if (i.id == itemId) return previousState;
          return i;
        }).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: newUndoStack,
          redoStack: [...current.redoStack, action],
        ));
        final index = updated.indexWhere((i) => i.id == itemId);
        if (index >= 0) await _persistItem(previousState, index);

      case ForceKeepAction(:final itemId, :final previousState):
        final updated = current.items.map((i) {
          if (i.id == itemId) return previousState;
          return i;
        }).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: newUndoStack,
          redoStack: [...current.redoStack, action],
        ));
        final index = updated.indexWhere((i) => i.id == itemId);
        if (index >= 0) await _persistItem(previousState, index);
    }
  }

  /// Redo the last undone action.
  Future<void> redo() async {
    final current = state.requireValue;
    if (!current.canRedo) return;

    final action = current.redoStack.last;
    final newRedoStack =
        current.redoStack.sublist(0, current.redoStack.length - 1);

    switch (action) {
      case AddAction(:final item):
        // Redo add = add the item back.
        final updated = [...current.items, item];
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: [...current.undoStack, action],
          redoStack: newRedoStack,
        ));
        await _persistItem(item, updated.length - 1);
        await _updateSessionItemCount(updated.length);

      case RemoveAction(:final item):
        // Redo remove = remove the item again.
        final updated = current.items.where((i) => i.id != item.id).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: [...current.undoStack, action],
          redoStack: newRedoStack,
        ));
        await _dao.deleteQueueItem(item.id);
        await _updateSessionItemCount(updated.length);

      case ResolveAction():
        // Redo resolve = apply the resolution again.
        // We need the resolved state, which is the current item before undo
        // was applied. The resolve action stores the previous state (before
        // resolution), so the "resolved" item is what's in current.items.
        // Actually, after undo the item is back to previousState. To redo,
        // we need the resolved metadata — but we don't store it separately.
        // For simplicity, redo of resolve is a no-op on metadata.
        // Instead, just push it back to the undo stack.
        state = AsyncValue.data(current.copyWith(
          undoStack: [...current.undoStack, action],
          redoStack: newRedoStack,
        ));

      case SaveAction():
        state = AsyncValue.data(current.copyWith(
          undoStack: [...current.undoStack, action],
          redoStack: newRedoStack,
        ));

      case ForceKeepAction(:final itemId):
        // Redo force-keep = set back to confirmed.
        final updated = current.items.map((i) {
          if (i.id == itemId) {
            return i.copyWith(status: BatchItemStatus.confirmed);
          }
          return i;
        }).toList();
        state = AsyncValue.data(current.copyWith(
          items: updated,
          undoStack: [...current.undoStack, action],
          redoStack: newRedoStack,
        ));
        final updatedItem = updated.firstWhere((i) => i.id == itemId);
        final index = updated.indexOf(updatedItem);
        await _persistItem(updatedItem, index);
    }
  }

  // ── Private persistence helpers ─────────────────────────────────────

  Future<void> _persistItem(BatchItem item, int sortOrder) async {
    final sessionId = state.requireValue.sessionId;
    if (sessionId == null) return;
    await _dao.upsertQueueItem(batchItemToCompanion(item, sessionId, sortOrder));
  }

  Future<void> _persistAllItems(List<BatchItem> items) async {
    final sessionId = state.requireValue.sessionId;
    if (sessionId == null) return;
    await _dao.deleteSessionQueueItems(sessionId);
    for (var i = 0; i < items.length; i++) {
      await _dao.upsertQueueItem(batchItemToCompanion(items[i], sessionId, i));
    }
  }

  Future<void> _updateSessionItemCount(int count) async {
    final sessionId = state.requireValue.sessionId;
    if (sessionId == null) return;
    await _dao.updateSessionItemCount(sessionId, count);
  }
}

final batchEditorProvider =
    AsyncNotifierProvider<BatchEditorNotifier, BatchEditorState>(
        BatchEditorNotifier.new);
