import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:uuid/uuid.dart';

class MediaItemRepositoryImpl implements IMediaItemRepository {
  MediaItemRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
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

    final Stream<List<MediaItemsTableData>> baseStream = useFts
        ? _mediaItemsDao.watchSearch(searchQuery)
        : _mediaItemsDao.watchAll();

    return baseStream.map(
      (rows) => rows
          .where((r) => mediaType == null || r.mediaType == mediaType.name)
          .where((r) =>
              // For very short queries (< 2 chars), fall back to in-memory filter
              useFts ||
              searchQuery == null ||
              r.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .map(_fromRow)
          .toList(),
    );
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
  Future<void> save(MediaItem item) async {
    await _mediaItemsDao.insertItem(_toCompanion(item));
    await _logSync('media_item', item.id, 'insert', item);
  }

  @override
  Future<void> update(MediaItem item) async {
    await _mediaItemsDao.updateItem(_toCompanion(item));
    await _logSync('media_item', item.id, 'update', item);
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _mediaItemsDao.softDelete(id, now);
    await _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('media_item'),
      entityId: Value(id),
      operation: const Value('delete'),
      payloadJson: Value(jsonEncode({'id': id, 'deleted': 1})),
      createdAt: Value(now),
    ));
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
      payloadJson: Value(jsonEncode({
        'id': item.id,
        'barcode': item.barcode,
        'title': item.title,
        'media_type': item.mediaType.name,
      })),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}
