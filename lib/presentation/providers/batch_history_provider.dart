// Batch history provider — loads past batch sessions from the database.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/dao/batch_session_dao.dart';
import 'package:mymediascanner/data/mappers/batch_item_mapper.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';

// ── Summary model ───────────────────────────────────────────────────

class BatchSessionSummary {
  const BatchSessionSummary({
    required this.id,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.itemCount,
    this.savedCount = 0,
    this.items = const [],
  });

  final String id;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String status;
  final int itemCount;
  final int savedCount;

  /// Items from this session (loaded on demand when expanded).
  final List<BatchItem> items;
}

// ── Notifier ────────────────────────────────────────────────────────

class BatchHistoryNotifier extends AsyncNotifier<List<BatchSessionSummary>> {
  static const _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;

  BatchSessionDao get _dao => ref.read(batchSessionDaoProvider);

  @override
  Future<List<BatchSessionSummary>> build() async {
    _offset = 0;
    _hasMore = true;
    return _loadPage();
  }

  Future<List<BatchSessionSummary>> _loadPage() async {
    final sessions =
        await _dao.getSessionHistory(limit: _pageSize, offset: _offset);
    if (sessions.length < _pageSize) _hasMore = false;

    final summaries = <BatchSessionSummary>[];
    for (final session in sessions) {
      final items = await _dao.getQueueItems(session.id);
      final batchItems = items.map(batchItemFromRow).toList();
      final savedCount =
          batchItems.where((i) => i.status == BatchItemStatus.saved).length;

      summaries.add(BatchSessionSummary(
        id: session.id,
        createdAt: DateTime.fromMillisecondsSinceEpoch(session.createdAt),
        completedAt: session.completedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.completedAt!)
            : null,
        status: session.status,
        itemCount: session.itemCount,
        savedCount: savedCount,
        items: batchItems,
      ));
    }

    return summaries;
  }

  /// Loads the next page of history.
  Future<void> loadMore() async {
    if (!_hasMore) return;
    _offset += _pageSize;

    final current = state.value ?? [];
    final nextPage = await _loadPage();
    state = AsyncValue.data([...current, ...nextPage]);
  }

  bool get hasMore => _hasMore;
}

final batchHistoryProvider =
    AsyncNotifierProvider<BatchHistoryNotifier, List<BatchSessionSummary>>(
        BatchHistoryNotifier.new);
