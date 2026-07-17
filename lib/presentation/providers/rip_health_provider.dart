// Author: Paul Snow

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// All tracks of non-deleted rip albums, grouped by album ID.
final ripAllTracksByAlbumProvider =
    StreamProvider<Map<String, List<RipTrack>>>((ref) {
  return ref.watch(ripLibraryRepositoryProvider).watchAllTracksByAlbum();
});

/// Derived health per album ID. Albums without a track entry are
/// classified [RipAlbumHealth.notAnalysed] by the lookup helper below.
final ripAlbumHealthMapProvider = Provider<Map<String, RipAlbumHealth>>((ref) {
  final tracksByAlbum =
      ref.watch(ripAllTracksByAlbumProvider).value ?? const {};
  return {
    for (final entry in tracksByAlbum.entries)
      entry.key: classifyRipAlbumHealth(entry.value),
  };
});

/// Health for one album, defaulting to notAnalysed when unknown.
RipAlbumHealth ripAlbumHealthOf(
  Map<String, RipAlbumHealth> healthMap,
  String albumId,
) =>
    healthMap[albumId] ?? RipAlbumHealth.notAnalysed;

/// Library-wide aggregate stats for the header cards.
final ripLibraryHealthStatsProvider = Provider<RipLibraryHealthStats>((ref) {
  final albums = ref.watch(allRipAlbumsProvider).value ?? const [];
  final tracksByAlbum =
      ref.watch(ripAllTracksByAlbumProvider).value ?? const {};
  return computeRipLibraryHealthStats(
    albums: albums,
    tracksByAlbum: tracksByAlbum,
  );
});

/// Health filter chips selection on the rips Library view.
enum RipHealthFilter { all, verified, attention, mismatch, notAnalysed }

extension RipHealthFilterMatch on RipHealthFilter {
  bool matches(RipAlbumHealth health) => switch (this) {
        RipHealthFilter.all => true,
        RipHealthFilter.verified => health == RipAlbumHealth.verified,
        RipHealthFilter.attention => health == RipAlbumHealth.attention,
        RipHealthFilter.mismatch => health == RipAlbumHealth.mismatch,
        RipHealthFilter.notAnalysed => health == RipAlbumHealth.notAnalysed,
      };
}

class RipHealthFilterNotifier extends Notifier<RipHealthFilter> {
  @override
  RipHealthFilter build() => RipHealthFilter.all;

  void set(RipHealthFilter value) => state = value;
}

final ripHealthFilterProvider =
    NotifierProvider<RipHealthFilterNotifier, RipHealthFilter>(
  RipHealthFilterNotifier.new,
);
