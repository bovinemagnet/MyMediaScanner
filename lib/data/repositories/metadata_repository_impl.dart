import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/api_circuit_breaker.dart';
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
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

class MetadataRepositoryImpl implements IMetadataRepository {
  MetadataRepositoryImpl({
    required BarcodeCacheDao cacheDao,
    this.tmdbApi,
    this.discogsApi,
    this.googleBooksApi,
    this.openLibraryApi,
    this.upcitemdbApi,
    ApiCircuitBreaker? googleBooksBreaker,
  })  : _cacheDao = cacheDao,
        googleBooksBreaker = googleBooksBreaker ?? ApiCircuitBreaker();

  final BarcodeCacheDao _cacheDao;
  final TmdbApi? tmdbApi;
  final DiscogsApi? discogsApi;
  final GoogleBooksApi? googleBooksApi;
  final OpenLibraryApi? openLibraryApi;
  final UpcitemdbApi? upcitemdbApi;

  /// Circuit breaker for Google Books API — trips on 429 responses.
  final ApiCircuitBreaker googleBooksBreaker;

  /// Returns true if the exception is a 429 rate-limit response.
  static bool _isRateLimited(Object error) {
    return error is DioException &&
        error.response?.statusCode == 429;
  }

  @override
  Future<ScanResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
    bool forceIsbn = false,
  }) async {
    final barcodeType = BarcodeUtils.detectBarcodeType(barcode);
    final barcodeTypeStr = barcodeType.name;

    // 1. Check cache
    final cached = await _checkCache(barcode);
    if (cached != null) return cached;

    // 2. Route by barcode type + hint
    ScanResult? result;

    if (forceIsbn || BarcodeUtils.isIsbn(barcode)) {
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

    // 4. Return notFound if all lookups failed
    return result ??
        ScanResult.notFound(barcode: barcode, barcodeType: barcodeTypeStr);
  }

  @override
  Future<MetadataResult?> fetchCandidateDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    return switch (candidate.sourceApi) {
      'discogs' => _fetchDiscogsDetail(candidate, barcode, barcodeType),
      'tmdb' => _fetchTmdbDetail(candidate, barcode, barcodeType),
      'google_books' =>
        _fetchGoogleBooksDetail(candidate, barcode, barcodeType),
      'open_library' =>
        _fetchOpenLibraryDetail(candidate, barcode, barcodeType),
      'upcitemdb' => _fetchUpcDetail(candidate, barcode, barcodeType),
      _ => null,
    };
  }

  // -- Detail fetchers for disambiguation --

  Future<MetadataResult?> _fetchDiscogsDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (discogsApi == null) return null;
    try {
      final id = int.parse(candidate.sourceId);
      final release = await discogsApi!.getRelease(id);
      await _cacheResponse(barcode, 'music', 'discogs', release.toJson());
      return DiscogsMapper.fromRelease(release, barcode, barcodeType);
    } on Exception catch (_) {
      return null;
    }
  }

  Future<MetadataResult?> _fetchTmdbDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (tmdbApi == null) return null;
    try {
      final response = await tmdbApi!.searchMulti(candidate.title);
      final match = response.results?.firstWhere(
        (r) => r.id?.toString() == candidate.sourceId,
        orElse: () => response.results!.first,
      );
      if (match != null) {
        await _cacheResponse(barcode, 'film', 'tmdb', match.toJson());
        return TmdbMapper.fromSearchResult(match, barcode, barcodeType);
      }
    } on Exception catch (_) {}
    return null;
  }

  Future<MetadataResult?> _fetchGoogleBooksDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (googleBooksApi == null || !googleBooksBreaker.isOpen) return null;
    try {
      final response = await googleBooksApi!.searchByIsbn('isbn:$barcode');
      googleBooksBreaker.reset();
      final match = response.items?.firstWhere(
        (v) => v.id == candidate.sourceId,
        orElse: () => response.items!.first,
      );
      if (match != null) {
        await _cacheResponse(barcode, 'book', 'google_books', match.toJson());
        return GoogleBooksMapper.fromVolume(match, barcode, barcodeType);
      }
    } on Exception catch (e) {
      if (_isRateLimited(e)) {
        googleBooksBreaker.trip();
      }
    }
    return null;
  }

  Future<MetadataResult?> _fetchOpenLibraryDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (openLibraryApi == null) return null;
    try {
      final book = await openLibraryApi!.getByIsbn(barcode);
      if (book != null) {
        await _cacheResponse(barcode, 'book', 'open_library', book.toJson());
        return OpenLibraryMapper.fromBook(book, barcode, barcodeType);
      }
    } on Exception catch (_) {}
    return null;
  }

  Future<MetadataResult?> _fetchUpcDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (upcitemdbApi == null) return null;
    try {
      final response = await upcitemdbApi!.lookup(barcode);
      final match = response.items?.firstWhere(
        (i) => (i.ean ?? barcode) == candidate.sourceId,
        orElse: () => response.items!.first,
      );
      if (match != null) {
        await _cacheResponse(barcode, null, 'upcitemdb', match.toJson());
        return UpcMapper.fromItem(match, barcode, barcodeType);
      }
    } on Exception catch (_) {}
    return null;
  }

  // -- Cache --

  Future<ScanResult?> _checkCache(String barcode) async {
    final cached = await _cacheDao.getByBarcode(barcode);
    if (cached == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cached.cachedAt;
    const maxAge = ApiConstants.cacheDurationDays * 24 * 60 * 60 * 1000;
    if (age > maxAge) return null;

    // Re-map through the original mapper for full fidelity
    try {
      final json = jsonDecode(cached.responseJson) as Map<String, dynamic>;
      final barcodeType = BarcodeUtils.detectBarcodeType(barcode).name;
      final metadata = switch (cached.sourceApi) {
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
      if (metadata == null) return null;
      return ScanResult.single(metadata: metadata, isDuplicate: false);
    } catch (_) {
      return null;
    }
  }

  // -- Lookup methods --

  Future<ScanResult?> _lookupBook(
      String barcode, String barcodeType) async {
    // Try Google Books first (skip if circuit breaker is tripped)
    if (googleBooksApi != null && googleBooksBreaker.isOpen) {
      try {
        final response =
            await googleBooksApi!.searchByIsbn('isbn:$barcode');
        googleBooksBreaker.reset();
        final items = response.items;
        if (items != null && items.isNotEmpty) {
          if (items.length == 1) {
            await _cacheResponse(
                barcode, 'book', 'google_books', items.first.toJson());
            return ScanResult.single(
              metadata: GoogleBooksMapper.fromVolume(
                  items.first, barcode, barcodeType),
              isDuplicate: false,
            );
          }
          final candidates = items
              .take(AppConstants.maxCandidates)
              .map(GoogleBooksMapper.toCandidate)
              .toList();
          return ScanResult.multiMatch(
            candidates: candidates,
            barcode: barcode,
            barcodeType: barcodeType,
          );
        }
      } on Exception catch (e) {
        if (_isRateLimited(e)) {
          googleBooksBreaker.trip();
          debugPrint('Google Books API rate-limited (429) — '
              'circuit breaker tripped, falling back to Open Library');
        }
        // Fall through to Open Library
      }
    }

    // Fallback to Open Library
    if (openLibraryApi != null) {
      try {
        final book = await openLibraryApi!.getByIsbn(barcode);
        if (book != null) {
          await _cacheResponse(
              barcode, 'book', 'open_library', book.toJson());
          return ScanResult.single(
            metadata:
                OpenLibraryMapper.fromBook(book, barcode, barcodeType),
            isDuplicate: false,
          );
        }
      } on Exception catch (_) {
        // Fall through
      }
    }

    return null;
  }

  Future<ScanResult?> _lookupFilm(
      String barcode, String barcodeType,
      {MetadataResult? upcHint}) async {
    if (tmdbApi == null) return null;
    try {
      // TMDB doesn't support barcode search directly — use UPCitemdb
      // to get a title, then search TMDB by title.
      // Accept a pre-fetched UPC result to avoid double lookups.
      final titleSource =
          upcHint ?? await _lookupUpcMetadata(barcode, barcodeType);
      if (titleSource?.title == null) return null;

      final response = await tmdbApi!.searchMulti(titleSource!.title!);
      final results = response.results;
      if (results == null || results.isEmpty) return null;

      if (results.length == 1) {
        await _cacheResponse(
            barcode, 'film', 'tmdb', results.first.toJson());
        return ScanResult.single(
          metadata: TmdbMapper.fromSearchResult(
              results.first, barcode, barcodeType),
          isDuplicate: false,
        );
      }

      final candidates = results
          .take(AppConstants.maxCandidates)
          .map(TmdbMapper.toCandidate)
          .toList();
      return ScanResult.multiMatch(
        candidates: candidates,
        barcode: barcode,
        barcodeType: barcodeType,
      );
    } on Exception catch (_) {}
    return null;
  }

  Future<ScanResult?> _lookupMusic(
      String barcode, String barcodeType) async {
    if (discogsApi == null) return null;
    try {
      final response = await discogsApi!.searchByBarcode(barcode);
      final results = response.results;
      if (results == null || results.isEmpty) return null;

      if (results.length == 1) {
        final searchResult = results.first;
        if (searchResult.id != null) {
          final release = await discogsApi!.getRelease(searchResult.id!);
          await _cacheResponse(
              barcode, 'music', 'discogs', release.toJson());
          return ScanResult.single(
            metadata: DiscogsMapper.fromRelease(
                release, barcode, barcodeType),
            isDuplicate: false,
          );
        }
        return null;
      }

      final candidates = results
          .take(AppConstants.maxCandidates)
          .map(DiscogsMapper.toCandidate)
          .toList();
      return ScanResult.multiMatch(
        candidates: candidates,
        barcode: barcode,
        barcodeType: barcodeType,
      );
    } on Exception catch (_) {}
    return null;
  }

  Future<ScanResult?> _lookupGeneral(
      String barcode, String barcodeType) async {
    final upcResult = await _lookupUpcMetadata(barcode, barcodeType);
    if (upcResult == null) return null;

    // If UPC gave us a type hint, try the specialist API
    if (upcResult.mediaType == MediaType.book) {
      return await _lookupBook(barcode, barcodeType) ??
          ScanResult.single(metadata: upcResult, isDuplicate: false);
    }
    if (upcResult.mediaType == MediaType.film ||
        upcResult.mediaType == MediaType.tv) {
      final filmResult =
          await _lookupFilm(barcode, barcodeType, upcHint: upcResult);
      return filmResult ??
          ScanResult.single(metadata: upcResult, isDuplicate: false);
    }
    if (upcResult.mediaType == MediaType.music) {
      final musicResult = await _lookupMusic(barcode, barcodeType);
      return musicResult ??
          ScanResult.single(metadata: upcResult, isDuplicate: false);
    }

    return ScanResult.single(metadata: upcResult, isDuplicate: false);
  }

  Future<ScanResult?> _lookupUpc(
      String barcode, String barcodeType) async {
    final metadata = await _lookupUpcMetadata(barcode, barcodeType);
    if (metadata == null) return null;
    return ScanResult.single(metadata: metadata, isDuplicate: false);
  }

  /// Raw UPC lookup returning MetadataResult (for use as title hint in
  /// _lookupFilm).
  Future<MetadataResult?> _lookupUpcMetadata(
    String barcode,
    String barcodeType,
  ) async {
    if (upcitemdbApi == null) return null;
    try {
      final response = await upcitemdbApi!.lookup(barcode);
      final item = response.items?.firstOrNull;
      if (item != null) {
        await _cacheResponse(barcode, null, 'upcitemdb', item.toJson());
        return UpcMapper.fromItem(item, barcode, barcodeType);
      }
    } on Exception catch (_) {}
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
