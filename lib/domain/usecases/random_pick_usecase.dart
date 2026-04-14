// Random pick usecase: selects a random owned MediaItem matching a filter.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:math';

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/random_pick_filter.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class RandomPickUsecase {
  RandomPickUsecase(this._repo, {Random? rng}) : _rng = rng ?? Random();

  final IMediaItemRepository _repo;
  final Random _rng;

  Future<MediaItem?> call(RandomPickFilter f) async {
    final owned = await _repo.watchByStatus(OwnershipStatus.owned).first;
    final filtered = owned.where((i) {
      if (f.mediaType != null && i.mediaType != f.mediaType) return false;
      if (f.genre != null && !i.genres.contains(f.genre)) return false;
      if (f.unratedOnly && i.userRating != null) return false;
      final runtime = i.extraMetadata['runtime_minutes'];
      if (f.maxRuntimeMinutes != null &&
          runtime is int &&
          runtime > f.maxRuntimeMinutes!) {
        return false;
      }
      final pages = i.extraMetadata['page_count'];
      if (f.maxPageCount != null && pages is int && pages > f.maxPageCount!) {
        return false;
      }
      // shelfId handled via a repo join if needed; YAGNI for v1.
      return true;
    }).toList();
    if (filtered.isEmpty) return null;
    return filtered[_rng.nextInt(filtered.length)];
  }
}
