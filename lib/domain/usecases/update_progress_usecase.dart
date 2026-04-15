import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/progress_unit.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

/// Source of "now" for tests.
typedef Clock = DateTime Function();

/// Manages the in-progress lifecycle for a [MediaItem]: start → update →
/// mark complete. Each action persists the change via
/// [IMediaItemRepository.update] and returns the updated item.
class UpdateProgressUseCase {
  UpdateProgressUseCase({
    required IMediaItemRepository repository,
    Clock? clock,
  })  : _repo = repository,
        _clock = clock ?? DateTime.now;

  final IMediaItemRepository _repo;
  final Clock _clock;

  /// Begin tracking. Stamps `startedAt`, sets the unit and (optional)
  /// total, and clears any prior completion. Idempotent on already-
  /// started items: subsequent calls only update the unit/total.
  Future<MediaItem> start(
    MediaItem item, {
    required ProgressUnit unit,
    int? total,
    int initialCurrent = 0,
  }) async {
    final now = _clock().millisecondsSinceEpoch;
    final updated = item.copyWith(
      startedAt: item.startedAt ?? now,
      progressUnit: unit,
      progressTotal: total ?? item.progressTotal,
      progressCurrent: item.progressCurrent ?? initialCurrent,
      completedAt: null,
      consumed: false,
      updatedAt: now,
    );
    await _repo.update(updated);
    return updated;
  }

  /// Update the running counter. Caps at [progressTotal] when known.
  Future<MediaItem> updateCurrent(MediaItem item, int current) async {
    final now = _clock().millisecondsSinceEpoch;
    final total = item.progressTotal;
    final clamped = total != null && current > total ? total : current;
    final updated = item.copyWith(
      progressCurrent: clamped < 0 ? 0 : clamped,
      updatedAt: now,
    );
    await _repo.update(updated);
    return updated;
  }

  /// Mark complete. Stamps `completedAt`, sets `consumed=true`, and
  /// snaps `progressCurrent` to `progressTotal` if the latter is known.
  Future<MediaItem> markComplete(MediaItem item) async {
    final now = _clock().millisecondsSinceEpoch;
    final total = item.progressTotal;
    final updated = item.copyWith(
      completedAt: now,
      consumed: true,
      progressCurrent: total ?? item.progressCurrent,
      updatedAt: now,
    );
    await _repo.update(updated);
    return updated;
  }

  /// Reset progress entirely (clears start, current, completion, consumed).
  Future<MediaItem> reset(MediaItem item) async {
    final now = _clock().millisecondsSinceEpoch;
    final updated = item.copyWith(
      startedAt: null,
      progressCurrent: null,
      progressTotal: null,
      progressUnit: null,
      completedAt: null,
      consumed: false,
      updatedAt: now,
    );
    await _repo.update(updated);
    return updated;
  }
}
