// Batch runner that sweeps the collection and fills missing cover art.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/fetch_missing_cover_usecase.dart';

/// Progress snapshot emitted during a [FillMissingCoversUseCase] run.
class FillCoversProgress {
  const FillCoversProgress({
    required this.processed,
    required this.total,
    required this.updated,
    required this.notFound,
    this.currentTitle,
    this.cancelled = false,
  });

  /// Number of items processed so far (updated + notFound).
  final int processed;

  /// Total number of items in the batch.
  final int total;

  /// Items whose cover was successfully fetched and saved.
  final int updated;

  /// Items for which no cover could be found via any path.
  final int notFound;

  /// Title of the item currently being processed, if any.
  final String? currentTitle;

  /// Whether the run was cancelled before completion.
  final bool cancelled;

  double get fraction => total == 0 ? 1.0 : processed / total;
  bool get isDone => processed >= total || cancelled;
}

/// Iterates every non-deleted [MediaItem] whose `coverUrl` is missing and
/// runs [FetchMissingCoverUseCase] against each.
///
/// Throttles between requests to stay friendly to the underlying metadata
/// APIs (MusicBrainz in particular is aggressive about rate limiting).
class FillMissingCoversUseCase {
  FillMissingCoversUseCase({
    required IMediaItemRepository mediaItemRepository,
    required FetchMissingCoverUseCase fetchCover,
    Duration throttle = const Duration(milliseconds: 400),
  })  : _items = mediaItemRepository,
        _fetchCover = fetchCover,
        _throttle = throttle;

  final IMediaItemRepository _items;
  final FetchMissingCoverUseCase _fetchCover;
  final Duration _throttle;

  bool _cancelled = false;

  /// Requests the in-flight batch to stop after the current item.
  void cancel() {
    _cancelled = true;
  }

  /// Returns a stream of [FillCoversProgress] snapshots. The stream emits
  /// once on enter, once per item, and finishes with a terminal snapshot
  /// where [FillCoversProgress.isDone] is true.
  Stream<FillCoversProgress> execute() async* {
    _cancelled = false;
    final all = await _items.watchAll().first;
    final pending = all
        .where((i) =>
            !i.deleted && (i.coverUrl == null || i.coverUrl!.isEmpty))
        .toList();
    final total = pending.length;

    var updated = 0;
    var notFound = 0;

    yield FillCoversProgress(
      processed: 0,
      total: total,
      updated: 0,
      notFound: 0,
    );

    for (var i = 0; i < pending.length; i++) {
      if (_cancelled) {
        yield FillCoversProgress(
          processed: updated + notFound,
          total: total,
          updated: updated,
          notFound: notFound,
          cancelled: true,
        );
        return;
      }

      final item = pending[i];
      final outcome = await _fetchCover.execute(item);
      if (outcome == FetchCoverOutcome.updated) {
        updated++;
      } else {
        // alreadyHasCover shouldn't happen (we filter above) but counts
        // as notFound from the UI's perspective.
        notFound++;
      }

      yield FillCoversProgress(
        processed: updated + notFound,
        total: total,
        updated: updated,
        notFound: notFound,
        currentTitle: item.title,
      );

      if (i < pending.length - 1) {
        await Future<void>.delayed(_throttle);
      }
    }
  }
}
