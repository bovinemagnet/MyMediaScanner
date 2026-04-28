import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_state_dto.dart';
import 'package:mymediascanner/domain/entities/tmdb_account_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';

class TmdbAccountMapper {
  TmdbAccountMapper._();

  /// Pull: TMDB rating (0.5–10) → local rating (0–5). Halving is exact.
  static double? tmdbToLocalRating(double? tmdb) =>
      tmdb == null ? null : tmdb / 2;

  /// Push (slice 2): local rating (0–5) → TMDB rating (0.5–10).
  /// Clamped to TMDB's legal range so a 0-star local rating is still a
  /// valid TMDB write.
  static double localToTmdbRating(double local) {
    final raw = local * 2;
    if (raw < 0.5) return 0.5;
    if (raw > 10.0) return 10.0;
    return raw;
  }

  static TmdbAccountState fromAccountStateDto(
    TmdbAccountStateDto dto, {
    required String mediaType,
  }) {
    return TmdbAccountState(
      tmdbId: dto.id,
      mediaType: mediaType,
      favorite: dto.favorite,
      watchlist: dto.watchlist,
      rating: dto.ratingValue,
    );
  }

  /// Build a Drift companion for upserting a single bucket-row.
  /// Used by `ImportTmdbAccountUseCase` for first import and "Sync now".
  ///
  /// Critical: non-applicable flag fields use `Value.absent()` so the
  /// DAO's pass-through `_dropPresent` upsert preserves existing
  /// values from other buckets when the same TMDB ID appears in
  /// multiple buckets (e.g. a movie that's both rated and favourited).
  static TmdbAccountSyncItemsTableCompanion bucketCompanion(
    TmdbAccountListItemDto dto, {
    required TmdbBridgeBucket bucket,
    required String mediaType,
    required String? existingId,
  }) {
    final id = existingId ?? _uuidV4();
    final now = DateTime.now().millisecondsSinceEpoch;
    return TmdbAccountSyncItemsTableCompanion(
      id: Value(id),
      tmdbId: Value(dto.id),
      tmdbMediaType: Value(mediaType),
      titleSnapshot: Value(dto.title ?? dto.name),
      posterPathSnapshot: Value(dto.posterPath),
      tmdbRating: bucket == TmdbBridgeBucket.rated
          ? Value(dto.rating)
          : const Value.absent(),
      watchlist: bucket == TmdbBridgeBucket.watchlist
          ? const Value(true)
          : const Value.absent(),
      favorite: bucket == TmdbBridgeBucket.favourite
          ? const Value(true)
          : const Value.absent(),
      lastPulledAt: Value(now),
      updatedAt: Value(now),
    );
  }

  /// Build a Drift companion for an enrichment upsert from a single
  /// `/account_states` payload. Used by `EnrichScanWithTmdbAccountUseCase`.
  ///
  /// Unlike `bucketCompanion`, this writes ALL flag fields explicitly
  /// (including `false` values) because an enrichment fetch represents
  /// the complete current state of the title on TMDB — flags must be
  /// able to flip from true → false when the user removes a title from
  /// their TMDB watchlist or favourites.
  static TmdbAccountSyncItemsTableCompanion accountStateCompanion(
    TmdbAccountStateDto dto, {
    required String mediaType,
    required String? existingId,
    String? titleSnapshot,
    String? posterPathSnapshot,
    String? mediaItemId,
  }) {
    final id = existingId ?? _uuidV4();
    final now = DateTime.now().millisecondsSinceEpoch;
    return TmdbAccountSyncItemsTableCompanion(
      id: Value(id),
      tmdbId: Value(dto.id),
      tmdbMediaType: Value(mediaType),
      mediaItemId:
          mediaItemId == null ? const Value.absent() : Value(mediaItemId),
      titleSnapshot:
          titleSnapshot == null ? const Value.absent() : Value(titleSnapshot),
      posterPathSnapshot: posterPathSnapshot == null
          ? const Value.absent()
          : Value(posterPathSnapshot),
      tmdbRating: Value(dto.ratingValue),
      watchlist: Value(dto.watchlist),
      favorite: Value(dto.favorite),
      accountStateJson: Value(jsonEncode(dto.toJson())),
      lastPulledAt: Value(now),
      updatedAt: Value(now),
    );
  }

  static TmdbBridgeItem rowToBridgeItem(TmdbAccountSyncItemsTableData row) {
    final ids = (jsonDecode(row.listIdsJson) as List).cast<int>();
    return TmdbBridgeItem(
      id: row.id,
      mediaItemId: row.mediaItemId,
      tmdbId: row.tmdbId,
      mediaType: row.tmdbMediaType,
      title: row.titleSnapshot,
      posterPath: row.posterPathSnapshot,
      tmdbRating: row.tmdbRating,
      watchlist: row.watchlist,
      favorite: row.favorite,
      listIds: ids,
      lastPulledAt: row.lastPulledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.lastPulledAt!),
      lastError: row.lastError,
    );
  }

  // Local UUIDv4-ish to avoid pulling in another dependency. The bridge
  // table id is internal-only — collision risk on a single device is
  // effectively zero.
  static String _uuidV4() {
    final r =
        DateTime.now().microsecondsSinceEpoch ^ identityHashCode(Object());
    final hex = r.toRadixString(16).padLeft(16, '0');
    return 'tmb-${hex.substring(0, 8)}-${hex.substring(8, 12)}'
        '-${hex.substring(12, 16)}-'
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }
}
