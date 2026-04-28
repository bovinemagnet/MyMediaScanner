import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/progress_unit.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
import 'package:uuid/uuid.dart';

class MediaItemRepositoryImpl implements IMediaItemRepository {
  MediaItemRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
    MirrorOwnershipChangeUseCase? mirror,
    bool Function()? readMirrorEnabled,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao,
        _mirror = mirror,
        _readMirrorEnabled = readMirrorEnabled;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  final MirrorOwnershipChangeUseCase? _mirror;
  final bool Function()? _readMirrorEnabled;
  static const _uuid = Uuid();

  @override
  Stream<List<MediaItem>> watchAll({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  }) {
    final useFts =
        searchQuery != null && searchQuery.trim().length >= 2;
    final hasTagFilter = tagIds != null && tagIds.isNotEmpty;

    final Stream<List<MediaItemsTableData>> baseStream = useFts
        ? _mediaItemsDao.watchSearch(searchQuery)
        : _mediaItemsDao.watchAll(
            mediaType: mediaType?.name,
            tagIds: tagIds,
            sortBy: sortBy,
            ascending: ascending,
          );

    // FTS path skips the DAO-level tag filter (the FTS query joins only
    // `media_items_fts`), so we have to apply tagIds in-memory by looking
    // up the assignments. This is rare — full-text search + tag filter
    // — and a single small read per emission.
    Future<Set<String>> resolveTaggedIds() async {
      if (!useFts || !hasTagFilter) return const <String>{};
      final assignments = await (_db.select(_db.mediaItemTagsTable)
            ..where((t) => t.tagId.isIn(tagIds)))
          .get();
      return assignments.map((a) => a.mediaItemId).toSet();
    }

    return baseStream.asyncMap((rows) async {
      final taggedIds = await resolveTaggedIds();
      return rows
          .where((r) =>
              useFts ||
              mediaType == null ||
              r.mediaType == mediaType.name)
          .where((r) =>
              // For very short queries (< 2 chars), fall back to in-memory filter
              useFts ||
              searchQuery == null ||
              r.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .where((r) =>
              !useFts || !hasTagFilter || taggedIds.contains(r.id))
          .map(_fromRow)
          .toList();
    });
  }

  AppDatabase get _db => _mediaItemsDao.attachedDatabase;

  @override
  Stream<List<MediaItem>> watchByStatus(OwnershipStatus status) {
    return _mediaItemsDao
        .watchByStatus(status)
        .map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Stream<List<MediaItem>> watchInProgress() {
    return _mediaItemsDao
        .watchInProgress()
        .map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<MediaItem?> getById(String id) async {
    final row = await _mediaItemsDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<bool> barcodeExists(String barcode) {
    return _mediaItemsDao.barcodeExists(barcode);
  }

  @override
  Future<int> countByBarcode(String barcode) {
    return _mediaItemsDao.countByBarcode(barcode);
  }

  @override
  Future<List<MediaItem>> findByBarcode(String barcode) async {
    final rows = await _mediaItemsDao.findByBarcode(barcode);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<MediaItem>> findByTitleYear(String title, int? year) async {
    final rows = await _mediaItemsDao.findByTitleYear(title, year);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(MediaItem item) async {
    // Atomic: the row write and its sync_log entry must commit together,
    // or both roll back. A crash between the two left the local mutation
    // permanently invisible to `pushChanges` (which only iterates
    // pending log rows), so re-edits couldn't recover the data.
    await _mediaItemsDao.transaction(() async {
      await _mediaItemsDao.insertItem(_toCompanion(item));
      await _logSync('media_item', item.id, 'insert', item);
    });
  }

  @override
  Future<void> update(MediaItem item) async {
    final previous = await getById(item.id);
    await _mediaItemsDao.transaction(() async {
      await _mediaItemsDao.updateItem(_toCompanion(item));
      await _logSync('media_item', item.id, 'update', item);
    });
    _maybeMirrorOnTransition(previous, item);
  }

  @override
  Future<void> softDelete(String id) async {
    final previous = await getById(id);
    final now = DateTime.now().millisecondsSinceEpoch;
    await _mediaItemsDao.transaction(() async {
      await _mediaItemsDao.softDelete(id, now);
      await _syncLogDao.insertLog(SyncLogTableCompanion(
        id: Value(_uuid.v7()),
        entityType: const Value('media_item'),
        entityId: Value(id),
        operation: const Value('delete'),
        payloadJson: Value(jsonEncode({'id': id, 'deleted': 1})),
        createdAt: Value(now),
      ));
    });
    if (previous != null) {
      _maybeMirrorOnSoftDelete(previous);
    }
  }

  @override
  Future<List<MediaItem>> getUnsynced() async {
    final rows = await _mediaItemsDao.getUnsynced();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> markSynced(String id, int syncedAt) {
    return _mediaItemsDao.markSynced(id, syncedAt);
  }

  MediaItem _fromRow(MediaItemsTableData row) {
    return MediaItem(
      id: row.id,
      barcode: row.barcode,
      barcodeType: row.barcodeType,
      mediaType: MediaType.fromString(row.mediaType),
      title: row.title,
      subtitle: row.subtitle,
      description: row.description,
      coverUrl: row.coverUrl,
      year: row.year,
      publisher: row.publisher,
      format: row.format,
      genres: _parseStringList(jsonDecode(row.genres)),
      extraMetadata: _parseMap(jsonDecode(row.extraMetadata)),
      sourceApis: _parseStringList(jsonDecode(row.sourceApis)),
      userRating: row.userRating,
      userReview: row.userReview,
      criticScore: row.criticScore,
      criticSource: row.criticSource,
      ownershipStatus: OwnershipStatus.fromString(row.ownershipStatus) ??
          OwnershipStatus.owned,
      condition: ItemCondition.fromString(row.condition),
      pricePaid: row.pricePaid,
      acquiredAt: row.acquiredAt,
      retailer: row.retailer,
      locationId: row.locationId,
      seriesId: row.seriesId,
      seriesPosition: row.seriesPosition,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      progressUnit: ProgressUnit.fromString(row.progressUnit),
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      consumed: row.consumed == 1,
      dateAdded: row.dateAdded,
      dateScanned: row.dateScanned,
      updatedAt: row.updatedAt,
      syncedAt: row.syncedAt,
      deleted: row.deleted == 1,
    );
  }

  static List<String> _parseStringList(dynamic decoded) {
    if (decoded is List) return decoded.whereType<String>().toList();
    return [];
  }

  static Map<String, dynamic> _parseMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    return {};
  }

  MediaItemsTableCompanion _toCompanion(MediaItem item) {
    return MediaItemsTableCompanion(
      id: Value(item.id),
      barcode: Value(item.barcode),
      barcodeType: Value(item.barcodeType),
      mediaType: Value(item.mediaType.name),
      title: Value(item.title),
      subtitle: Value(item.subtitle),
      description: Value(item.description),
      coverUrl: Value(item.coverUrl),
      year: Value(item.year),
      publisher: Value(item.publisher),
      format: Value(item.format),
      genres: Value(jsonEncode(item.genres)),
      extraMetadata: Value(jsonEncode(item.extraMetadata)),
      sourceApis: Value(jsonEncode(item.sourceApis)),
      userRating: Value(item.userRating),
      userReview: Value(item.userReview),
      criticScore: Value(item.criticScore),
      criticSource: Value(item.criticSource),
      ownershipStatus: Value(item.ownershipStatus.name),
      condition: Value(item.condition?.name),
      pricePaid: Value(item.pricePaid),
      acquiredAt: Value(item.acquiredAt),
      retailer: Value(item.retailer),
      locationId: Value(item.locationId),
      seriesId: Value(item.seriesId),
      seriesPosition: Value(item.seriesPosition),
      progressCurrent: Value(item.progressCurrent),
      progressTotal: Value(item.progressTotal),
      progressUnit: Value(item.progressUnit?.dbValue),
      startedAt: Value(item.startedAt),
      completedAt: Value(item.completedAt),
      consumed: Value(item.consumed ? 1 : 0),
      dateAdded: Value(item.dateAdded),
      dateScanned: Value(item.dateScanned),
      updatedAt: Value(item.updatedAt),
      syncedAt: Value(item.syncedAt),
      deleted: Value(item.deleted ? 1 : 0),
    );
  }

  Future<void> _logSync(
      String entityType, String entityId, String operation, MediaItem item) {
    return _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      // Store a full row snapshot. `PostgresSyncClient.buildBatchUpsertSql`
      // derives both the INSERT columns and the ON CONFLICT update set
      // from the payload keys; if we persist only a subset here, every
      // other column on the server will be NULL on INSERT or left stale
      // on UPDATE.
      payloadJson: Value(jsonEncode(_toSyncPayload(item))),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Fires `mirror.add` or `mirror.remove` when the ownership state of
  /// a `media_items` row crosses the `owned` boundary. Gated on the
  /// mirror toggle, presence of a TMDB ID, and movie media type.
  ///
  /// Fire-and-forget — failures land on the bridge row's `last_error`.
  void _maybeMirrorOnTransition(MediaItem? previous, MediaItem next) {
    final mirror = _mirror;
    final readEnabled = _readMirrorEnabled;
    if (mirror == null || readEnabled == null) return;
    if (!readEnabled()) return;

    final wasOwned = previous?.ownershipStatus == OwnershipStatus.owned;
    final isOwned = next.ownershipStatus == OwnershipStatus.owned;
    if (wasOwned == isOwned) return; // no transition

    final tmdbId = next.extraMetadata['tmdb_id'];
    if (tmdbId is! int) return;
    final mediaType = next.extraMetadata['media_type'];
    if (mediaType != 'movie') return;

    if (isOwned) {
      unawaited(mirror.add(tmdbId: tmdbId).catchError((_) {
        return const TmdbPushResult(success: false);
      }));
    } else {
      unawaited(mirror.remove(tmdbId: tmdbId).catchError((_) {
        return const TmdbPushResult(success: false);
      }));
    }
  }

  /// Fires `mirror.remove` when an owned movie is soft-deleted.
  void _maybeMirrorOnSoftDelete(MediaItem previous) {
    final mirror = _mirror;
    final readEnabled = _readMirrorEnabled;
    if (mirror == null || readEnabled == null) return;
    if (!readEnabled()) return;
    if (previous.ownershipStatus != OwnershipStatus.owned) return;

    final tmdbId = previous.extraMetadata['tmdb_id'];
    if (tmdbId is! int) return;
    final mediaType = previous.extraMetadata['media_type'];
    if (mediaType != 'movie') return;

    unawaited(mirror.remove(tmdbId: tmdbId).catchError((_) {
      return const TmdbPushResult(success: false);
    }));
  }

  /// Produce a snake_case map of every sync-relevant field on [item], in
  /// the shape expected by the PostgreSQL `media_items` table.
  static Map<String, dynamic> _toSyncPayload(MediaItem item) {
    return <String, dynamic>{
      'id': item.id,
      'barcode': item.barcode,
      'barcode_type': item.barcodeType,
      'media_type': item.mediaType.name,
      'title': item.title,
      'subtitle': item.subtitle,
      'description': item.description,
      'cover_url': item.coverUrl,
      'year': item.year,
      'publisher': item.publisher,
      'format': item.format,
      'genres': jsonEncode(item.genres),
      'extra_metadata': jsonEncode(item.extraMetadata),
      'source_apis': jsonEncode(item.sourceApis),
      'user_rating': item.userRating,
      'user_review': item.userReview,
      'critic_score': item.criticScore,
      'critic_source': item.criticSource,
      'ownership_status': item.ownershipStatus.name,
      'condition': item.condition?.name,
      'price_paid': item.pricePaid,
      'acquired_at': item.acquiredAt,
      'retailer': item.retailer,
      'location_id': item.locationId,
      'series_id': item.seriesId,
      'series_position': item.seriesPosition,
      'progress_current': item.progressCurrent,
      'progress_total': item.progressTotal,
      'progress_unit': item.progressUnit?.dbValue,
      'started_at': item.startedAt,
      'completed_at': item.completedAt,
      'consumed': item.consumed ? 1 : 0,
      'date_added': item.dateAdded,
      'date_scanned': item.dateScanned,
      'updated_at': item.updatedAt,
      'deleted': item.deleted ? 1 : 0,
    };
  }
}
