// Scans the whole library for duplicate items, grouping matches.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';

/// A set of items that match each other under [kind]. Always two or more.
class DuplicateGroup {
  const DuplicateGroup({required this.kind, required this.items});

  final DuplicateKind kind;
  final List<MediaItem> items;
}

class ScanDuplicatesUseCase {
  const ScanDuplicatesUseCase({
    required IMediaItemRepository repository,
    double fuzzyThreshold = 0.85,
  })  : _repo = repository,
        _fuzzyThreshold = fuzzyThreshold;

  final IMediaItemRepository _repo;
  final double _fuzzyThreshold;

  /// Returns groups of duplicates — items sharing a barcode, or fuzzy
  /// title matches within the same year. Singletons are omitted.
  Future<List<DuplicateGroup>> execute() async {
    final all = await _repo.watchAll().first;
    final owned = all
        .where((i) =>
            !i.deleted &&
            i.ownershipStatus == OwnershipStatus.owned)
        .toList();

    final groups = <DuplicateGroup>[];
    final assigned = <String>{};

    // Exact-barcode buckets first.
    final byBarcode = <String, List<MediaItem>>{};
    for (final item in owned) {
      byBarcode.putIfAbsent(item.barcode, () => []).add(item);
    }
    for (final entry in byBarcode.entries) {
      if (entry.value.length < 2) continue;
      groups.add(DuplicateGroup(
        kind: DuplicateKind.exactBarcode,
        items: entry.value,
      ));
      for (final item in entry.value) {
        assigned.add(item.id);
      }
    }

    // Fuzzy title within same year, excluding items already exact-matched.
    final remaining =
        owned.where((i) => !assigned.contains(i.id)).toList();
    for (var i = 0; i < remaining.length; i++) {
      if (assigned.contains(remaining[i].id)) continue;
      final bucket = <MediaItem>[remaining[i]];
      for (var j = i + 1; j < remaining.length; j++) {
        if (assigned.contains(remaining[j].id)) continue;
        if (remaining[i].year != remaining[j].year) continue;
        if (_similarity(remaining[i].title, remaining[j].title) >=
            _fuzzyThreshold) {
          bucket.add(remaining[j]);
        }
      }
      if (bucket.length >= 2) {
        for (final item in bucket) {
          assigned.add(item.id);
        }
        groups.add(DuplicateGroup(
          kind: DuplicateKind.fuzzyTitle,
          items: bucket,
        ));
      }
    }

    return groups;
  }

  double _similarity(String a, String b) {
    final s1 = a.toLowerCase();
    final s2 = b.toLowerCase();
    final d = _levenshtein(s1, s2);
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - d / maxLen;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final prev = List<int>.generate(b.length + 1, (i) => i);
    final cur = List<int>.filled(b.length + 1, 0);
    for (var i = 0; i < a.length; i++) {
      cur[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        cur[j + 1] = [
          cur[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var k = 0; k < cur.length; k++) {
        prev[k] = cur[k];
      }
    }
    return prev[b.length];
  }
}
