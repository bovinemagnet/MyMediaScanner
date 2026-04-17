/// Riverpod providers for the GnuDB lookup UX.
///
/// The [GnudbLookupNotifier] drives the "Look up on GnuDB" button in the
/// rip album detail dialog. It runs [LookupGnudbForRipUseCase], holds any
/// ambiguous candidates for user selection, then applies the chosen one
/// via [ApplyGnudbResultUseCase].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_api.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/usecases/apply_gnudb_result_usecase.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/domain/usecases/resolve_series_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

/// Provider for the shared [GnudbApi] client.
///
/// The username used for the CDDB "hello" string is read from
/// [gnudbUsernameProvider] so the user can identify themselves to GnuDB;
/// the client falls back to the default when the setting is absent.
final gnudbApiProvider = Provider<GnudbApi>((ref) {
  final user = ref.watch(gnudbUsernameProvider);
  return GnudbApi(user: user);
});

/// Factory for [LookupGnudbForRipUseCase]. The `rootPath` changes with the
/// user's configured rip library, so the use-case is built per call.
LookupGnudbForRipUseCase _buildLookupUseCase(Ref ref, String rootPath) {
  return LookupGnudbForRipUseCase(
    api: ref.read(gnudbApiProvider),
    cacheDao: ref.read(barcodeCacheDaoProvider),
    repository: ref.read(ripLibraryRepositoryProvider),
    rootPath: rootPath,
  );
}

/// Factory for [ApplyGnudbResultUseCase].
ApplyGnudbResultUseCase _buildApplyUseCase(Ref ref) {
  return ApplyGnudbResultUseCase(
    editRipMetadata: EditRipMetadataUseCase(
      repository: ref.read(ripLibraryRepositoryProvider),
      writer: ref.read(metaflacWriterProvider),
    ),
    saveMediaItem: SaveMediaItemUseCase(
      repository: ref.read(mediaItemRepositoryProvider),
      resolveSeries: ResolveSeriesUseCase(
        seriesRepository: ref.read(seriesRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      ),
    ),
    repository: ref.read(ripLibraryRepositoryProvider),
  );
}

/// Status of the GnuDB lookup state machine.
enum GnudbLookupStatus {
  idle,
  computing,
  fetching,
  ambiguous,
  applying,
  complete,
  error,
  noMatch,
}

/// Immutable state for the GnuDB lookup flow.
class GnudbLookupState {
  const GnudbLookupState({
    this.status = GnudbLookupStatus.idle,
    this.candidates = const [],
    this.appliedCandidate,
    this.outcome,
    this.error,
  });

  final GnudbLookupStatus status;
  final List<GnudbCandidate> candidates;
  final GnudbCandidate? appliedCandidate;
  final GnudbApplyOutcome? outcome;
  final String? error;

  GnudbLookupState copyWith({
    GnudbLookupStatus? status,
    List<GnudbCandidate>? candidates,
    GnudbCandidate? appliedCandidate,
    GnudbApplyOutcome? outcome,
    String? error,
  }) =>
      GnudbLookupState(
        status: status ?? this.status,
        candidates: candidates ?? this.candidates,
        appliedCandidate: appliedCandidate ?? this.appliedCandidate,
        outcome: outcome ?? this.outcome,
        error: error,
      );
}

/// Notifier driving the GnuDB lookup button and dialog. Singleton — only
/// one rip album is in the lookup flow at a time.
final gnudbLookupNotifierProvider =
    NotifierProvider<GnudbLookupNotifier, GnudbLookupState>(
  GnudbLookupNotifier.new,
);

class GnudbLookupNotifier extends Notifier<GnudbLookupState> {
  @override
  GnudbLookupState build() {
    return const GnudbLookupState();
  }

  /// Runs the full lookup → apply pipeline for [album] and its [tracks].
  ///
  /// For single-match and cached results the apply step runs automatically.
  /// For multi-match the notifier transitions to [GnudbLookupStatus.ambiguous]
  /// and waits for [selectCandidate] to apply a chosen one.
  Future<void> lookup(RipAlbum album, List<dynamic> tracks) async {
    if (state.status == GnudbLookupStatus.computing ||
        state.status == GnudbLookupStatus.fetching ||
        state.status == GnudbLookupStatus.applying) {
      return;
    }

    state = const GnudbLookupState(status: GnudbLookupStatus.computing);

    final rootPath =
        ref.read(ripLibraryPathProvider).maybeWhen(
                data: (p) => p, orElse: () => null) ??
            '';
    if (rootPath.isEmpty) {
      state = state.copyWith(
        status: GnudbLookupStatus.error,
        error: 'No rip library root configured',
      );
      return;
    }

    final lookupUseCase = _buildLookupUseCase(ref, rootPath);
    state = state.copyWith(status: GnudbLookupStatus.fetching);

    GnudbLookupResult result;
    try {
      result = await lookupUseCase.execute(
        album: album,
        tracks: tracks.cast(),
      );
    } catch (e) {
      state = state.copyWith(
        status: GnudbLookupStatus.error,
        error: e.toString(),
      );
      return;
    }

    switch (result) {
      case GnudbLookupNoMatch():
        state = state.copyWith(status: GnudbLookupStatus.noMatch);
      case GnudbLookupError(:final message):
        state = state.copyWith(
          status: GnudbLookupStatus.error,
          error: message,
        );
      case GnudbLookupSingle(:final candidate):
        await _apply(album, tracks.cast(), candidate);
      case GnudbLookupMulti(:final candidates):
        state = state.copyWith(
          status: GnudbLookupStatus.ambiguous,
          candidates: candidates,
        );
    }
  }

  /// Called from the disambiguation dialog when the user picks a candidate.
  Future<void> selectCandidate(
    RipAlbum album,
    List<dynamic> tracks,
    GnudbCandidate candidate,
  ) async {
    await _apply(album, tracks.cast(), candidate);
  }

  Future<void> _apply(
    RipAlbum album,
    List tracks,
    GnudbCandidate candidate,
  ) async {
    state = state.copyWith(status: GnudbLookupStatus.applying);
    try {
      final apply = _buildApplyUseCase(ref);
      final outcome = await apply.execute(
        album: album,
        tracks: tracks.cast(),
        candidate: candidate,
      );
      state = state.copyWith(
        status: GnudbLookupStatus.complete,
        appliedCandidate: candidate,
        outcome: outcome,
      );
      // Force UI refresh of rip album and track providers.
      ref.invalidate(allRipAlbumsProvider);
      ref.invalidate(ripTracksProvider(album.id));
    } catch (e) {
      state = state.copyWith(
        status: GnudbLookupStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Clears the state back to idle.
  void reset() {
    state = const GnudbLookupState();
  }
}
