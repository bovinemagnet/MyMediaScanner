import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/mappers/discogs_mapper.dart';
import 'package:mymediascanner/data/mappers/google_books_mapper.dart';
import 'package:mymediascanner/data/mappers/open_library_mapper.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/mappers/upc_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

class MetadataRepositoryImpl implements IMetadataRepository {
  MetadataRepositoryImpl({
    required BarcodeCacheDao cacheDao,
    this.tmdbApi,
    this.discogsApi,
    this.googleBooksApi,
    this.openLibraryApi,
    this.upcitemdbApi,
  }) : _cacheDao = cacheDao;

  final BarcodeCacheDao _cacheDao;
  final TmdbApi? tmdbApi;
  final DiscogsApi? discogsApi;
  final GoogleBooksApi? googleBooksApi;
  final OpenLibraryApi? openLibraryApi;
  final UpcitemdbApi? upcitemdbApi;

  @override
  Future<MetadataResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
  }) async {
    final barcodeType = BarcodeUtils.detectBarcodeType(barcode);
    final barcodeTypeStr = barcodeType.name;

    // 1. Check cache
    final cached = await _checkCache(barcode);
    if (cached != null) return cached;

    // 2. Route by barcode type + hint
    MetadataResult? result;

    if (BarcodeUtils.isIsbn(barcode)) {
      result = await _lookupBook(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.film || typeHint == MediaType.tv) {
      result = await _lookupFilm(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.music) {
      result = await _lookupMusic(barcode, barcodeTypeStr);
    } else {
      // Unknown type — try UPCitemdb first to classify
      result = await _lookupGeneral(barcode, barcodeTypeStr);
    }

    // 3. Fallback to UPCitemdb if specialist returned nothing
    if (result == null && typeHint != null) {
      result = await _lookupUpc(barcode, barcodeTypeStr);
    }

    // 4. Return barcode-only result if all lookups failed
    return result ??
        MetadataResult(
          barcode: barcode,
          barcodeType: barcodeTypeStr,
        );
  }

  Future<MetadataResult?> _checkCache(String barcode) async {
    final cached = await _cacheDao.getByBarcode(barcode);
    if (cached == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cached.cachedAt;
    const maxAge = ApiConstants.cacheDurationDays * 24 * 60 * 60 * 1000;
    if (age > maxAge) return null;

    // Re-map through the original mapper for full fidelity
    try {
      final json = jsonDecode(cached.responseJson) as Map<String, dynamic>;
      final barcodeType = BarcodeUtils.detectBarcodeType(barcode).name;
      return switch (cached.sourceApi) {
        'tmdb' => TmdbMapper.fromSearchResult(
            TmdbSearchResultDto.fromJson(json), barcode, barcodeType),
        'discogs' => DiscogsMapper.fromRelease(
            DiscogsReleaseDto.fromJson(json), barcode, barcodeType),
        'google_books' => GoogleBooksMapper.fromVolume(
            GoogleBooksVolumeDto.fromJson(json), barcode, barcodeType),
        'open_library' => OpenLibraryMapper.fromBook(
            OpenLibraryBookDto.fromJson(json), barcode, barcodeType),
        'upcitemdb' => UpcMapper.fromItem(
            UpcItemDto.fromJson(json), barcode, barcodeType),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  Future<MetadataResult?> _lookupBook(
      String barcode, String barcodeType) async {
    // Try Google Books first
    if (googleBooksApi != null) {
      try {
        final response =
            await googleBooksApi!.searchByIsbn('isbn:$barcode');
        final volume = response.items?.firstOrNull;
        if (volume != null) {
          await _cacheResponse(barcode, 'book', 'google_books', volume.toJson());
          return GoogleBooksMapper.fromVolume(volume, barcode, barcodeType);
        }
      } on Exception catch (_) {
        // Fall through to Open Library
      }
    }

    // Fallback to Open Library
    if (openLibraryApi != null) {
      try {
        final book = await openLibraryApi!.getByIsbn(barcode);
        if (book != null) {
          await _cacheResponse(barcode, 'book', 'open_library', book.toJson());
          return OpenLibraryMapper.fromBook(book, barcode, barcodeType);
        }
      } on Exception catch (_) {
        // Fall through
      }
    }

    return null;
  }

  Future<MetadataResult?> _lookupFilm(
      String barcode, String barcodeType, {MetadataResult? upcHint}) async {
    if (tmdbApi == null) return null;
    try {
      // TMDB doesn't support barcode search directly — use UPCitemdb
      // to get a title, then search TMDB by title.
      // Accept a pre-fetched UPC result to avoid double lookups.
      final titleSource = upcHint ?? await _lookupUpc(barcode, barcodeType);
      if (titleSource?.title == null) return null;

      final response = await tmdbApi!.searchMulti(titleSource!.title!);
      final result = response.results?.firstOrNull;
      if (result != null) {
        await _cacheResponse(barcode, 'film', 'tmdb', result.toJson());
        return TmdbMapper.fromSearchResult(result, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<MetadataResult?> _lookupMusic(
      String barcode, String barcodeType) async {
    if (discogsApi == null) return null;
    try {
      final response = await discogsApi!.searchByBarcode(barcode);
      final searchResult = response.results?.firstOrNull;
      if (searchResult?.id != null) {
        final release = await discogsApi!.getRelease(searchResult!.id!);
        await _cacheResponse(barcode, 'music', 'discogs', release.toJson());
        return DiscogsMapper.fromRelease(release, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<MetadataResult?> _lookupGeneral(
      String barcode, String barcodeType) async {
    final upcResult = await _lookupUpc(barcode, barcodeType);
    if (upcResult == null) return null;

    // If UPC gave us a type hint, try the specialist API
    if (upcResult.mediaType == MediaType.book) {
      return await _lookupBook(barcode, barcodeType) ?? upcResult;
    }
    if (upcResult.mediaType == MediaType.film ||
        upcResult.mediaType == MediaType.tv) {
      final filmResult = await _lookupFilm(barcode, barcodeType, upcHint: upcResult);
      return filmResult ?? upcResult;
    }
    if (upcResult.mediaType == MediaType.music) {
      final musicResult = await _lookupMusic(barcode, barcodeType);
      return musicResult ?? upcResult;
    }

    return upcResult;
  }

  Future<MetadataResult?> _lookupUpc(
      String barcode, String barcodeType) async {
    if (upcitemdbApi == null) return null;
    try {
      final response = await upcitemdbApi!.lookup(barcode);
      final item = response.items?.firstOrNull;
      if (item != null) {
        await _cacheResponse(barcode, null, 'upcitemdb', item.toJson());
        return UpcMapper.fromItem(item, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<void> _cacheResponse(
    String barcode,
    String? mediaTypeHint,
    String sourceApi,
    Map<String, dynamic> responseJson,
  ) async {
    try {
      await _cacheDao.upsert(BarcodeCacheTableCompanion(
        barcode: Value(barcode),
        mediaTypeHint: Value(mediaTypeHint),
        responseJson: Value(jsonEncode(responseJson)),
        sourceApi: Value(sourceApi),
        cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    } on Exception catch (_) {
      // Cache failures are non-critical
    }
  }
}
