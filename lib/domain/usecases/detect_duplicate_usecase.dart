import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

enum DuplicateKind { exactBarcode, fuzzyTitle, none }

class DuplicateMatch {
  const DuplicateMatch(this.kind, this.candidates);
  final DuplicateKind kind;
  final List<MediaItem> candidates;
}

class DetectDuplicateUsecase {
  DetectDuplicateUsecase(this._repo);
  final IMediaItemRepository _repo;

  static const double _fuzzyThreshold = 0.85;

  Future<DuplicateMatch> call({
    required String barcode,
    required String? title,
    int? year,
    String? excludeId,
  }) async {
    final byBarcode = await _repo.findByBarcode(barcode);
    final exact = byBarcode.where((e) => e.id != excludeId).toList();
    if (exact.isNotEmpty) {
      return DuplicateMatch(DuplicateKind.exactBarcode, exact);
    }
    // Skip fuzzy matching when no real title is available — otherwise a
    // placeholder like "Unknown" would false-positive against existing
    // "Unknown"-titled items.
    if (title == null || title.isEmpty) {
      return const DuplicateMatch(DuplicateKind.none, []);
    }
    final candidates = await _repo.findByTitleYear(title, year);
    final fuzzy = candidates.where((c) {
      if (c.id == excludeId) return false;
      return _similarity(c.title, title) >= _fuzzyThreshold;
    }).toList();
    if (fuzzy.isNotEmpty) {
      return DuplicateMatch(DuplicateKind.fuzzyTitle, fuzzy);
    }
    return const DuplicateMatch(DuplicateKind.none, []);
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
