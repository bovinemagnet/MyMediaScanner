import 'dart:async';

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/resolve_series_usecase.dart';
import 'package:uuid/uuid.dart';

class SaveMediaItemUseCase {
  const SaveMediaItemUseCase({
    required IMediaItemRepository repository,
    ResolveSeriesUseCase? resolveSeries,
    MirrorOwnershipChangeUseCase? mirror,
    bool Function()? readMirrorEnabled,
  })  : _repo = repository,
        _resolveSeries = resolveSeries,
        _mirror = mirror,
        _readMirrorEnabled = readMirrorEnabled;

  final IMediaItemRepository _repo;
  final ResolveSeriesUseCase? _resolveSeries;

  /// Optional mirror hook — only injected via the canonical provider.
  /// Inline constructions (batch, import, gnudb) leave this null and
  /// receive no mirror behaviour.
  final MirrorOwnershipChangeUseCase? _mirror;

  /// Callback that reads the current mirror-ownership toggle at save time,
  /// keeping this use case decoupled from Riverpod.
  final bool Function()? _readMirrorEnabled;

  static const _uuid = Uuid();

  Future<MediaItem> execute(
    MetadataResult metadata, {
    OwnershipStatus ownershipStatus = OwnershipStatus.owned,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = MediaItem(
      id: _uuid.v7(),
      barcode: metadata.barcode,
      barcodeType: metadata.barcodeType,
      mediaType: metadata.mediaType ?? MediaType.unknown,
      title: metadata.title ?? 'Unknown',
      subtitle: metadata.subtitle,
      description: metadata.description,
      coverUrl: metadata.coverUrl,
      year: metadata.year,
      publisher: metadata.publisher,
      format: metadata.format,
      genres: metadata.genres,
      extraMetadata: metadata.extraMetadata,
      sourceApis: metadata.sourceApis,
      criticScore: metadata.criticScore,
      criticSource: metadata.criticSource,
      ownershipStatus: ownershipStatus,
      // Only stamp acquiredAt when the item actually enters the collection.
      acquiredAt:
          ownershipStatus == OwnershipStatus.owned ? now : null,
      dateAdded: now,
      dateScanned: now,
      updatedAt: now,
    );

    await _repo.save(item);

    // Fire-and-forget mirror trigger: replicate ownership to the user's
    // private TMDB list when all conditions hold. A failed push must NOT
    // fail the local save — the item is the source of truth.
    //
    // NOTE: remove-from-mirror on transition away-from-owned is NOT wired
    // here because SaveMediaItemUseCase always creates NEW items — it never
    // receives the previous ownership state. Slice 3 will add the remove
    // path via a dedicated update-ownership use case.
    if (ownershipStatus == OwnershipStatus.owned) {
      final mirror = _mirror;
      final mirrorEnabled = _readMirrorEnabled?.call() ?? false;
      if (mirror != null && mirrorEnabled) {
        final tmdbId = _asInt(item.extraMetadata['tmdb_id']);
        final mediaType = item.extraMetadata['media_type'];
        if (tmdbId != null && mediaType == 'movie') {
          unawaited(
            mirror.add(tmdbId: tmdbId).catchError((_) {
              // Silent — UI surfaces errors via lastError on the bridge row.
              return const TmdbPushResult(success: false);
            }),
          );
        }
      }
    }

    final resolveSeries = _resolveSeries;
    if (resolveSeries != null) {
      return resolveSeries.execute(item, metadata);
    }
    return item;
  }

  /// Safely coerces [value] to [int]. Handles the case where JSON round-trips
  /// deserialise numeric fields as [double] on some platforms.
  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
