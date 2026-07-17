// Author: Paul Snow

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_coverage.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// All music items in the collection — the denominator for rip coverage.
final ripCoverageMusicItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref
      .watch(mediaItemRepositoryProvider)
      .watchAll(mediaType: MediaType.music);
});

/// Music items categorised by rip coverage, reusing the library-wide
/// all-tracks stream so quality-issue escalation stays in sync with analysis.
final ripCoverageEntriesProvider = Provider<List<RipCoverageEntry>>((ref) {
  final items = ref.watch(ripCoverageMusicItemsProvider).value ?? const [];
  final albums = ref.watch(allRipAlbumsProvider).value ?? const [];
  final tracksByAlbum =
      ref.watch(ripAllTracksByAlbumProvider).value ?? const {};
  return categoriseRipCoverage(
    items: items,
    albums: albums,
    tracksByAlbum: tracksByAlbum,
  );
});

/// Aggregate coverage stats for the Coverage tab header cards.
final ripCoverageStatsProvider = Provider<RipCoverageStats>((ref) {
  return computeRipCoverageStats(ref.watch(ripCoverageEntriesProvider));
});
