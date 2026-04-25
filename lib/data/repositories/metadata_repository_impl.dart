import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/api_circuit_breaker.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/mappers/discogs_mapper.dart';
import 'package:mymediascanner/data/mappers/enrichment_merger.dart';
import 'package:mymediascanner/data/mappers/igdb_mapper.dart';
import 'package:mymediascanner/data/mappers/musicbrainz_mapper.dart';
import 'package:mymediascanner/data/mappers/google_books_mapper.dart';
import 'package:mymediascanner/data/mappers/open_library_mapper.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/mappers/tvdb_mapper.dart';
import 'package:mymediascanner/data/mappers/upc_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/models/igdb_game_dto.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/theaudiodb_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/musicbrainz_api.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';
import 'package:mymediascanner/data/remote/api/tvdb/tvdb_api.dart';
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
    this.musicBrainzApi,
    this.coverArtArchiveApi,
    this.tvdbApi,
    this.googleBooksApi,
    this.openLibraryApi,
    this.upcitemdbApi,
    this.theAudioDbApi,
    this.fanartApi,
    this.igdbApi,
    ApiCircuitBreaker? googleBooksBreaker,
  }) : _cacheDao = cacheDao,
       googleBooksBreaker = googleBooksBreaker ?? ApiCircuitBreaker();

  final BarcodeCacheDao _cacheDao;
  final TmdbApi? tmdbApi;
  final DiscogsApi? discogsApi;
  final MusicBrainzApi? musicBrainzApi;
  final CoverArtArchiveApi? coverArtArchiveApi;
  final TvdbApi? tvdbApi;
  final GoogleBooksApi? googleBooksApi;
  final OpenLibraryApi? openLibraryApi;
  final UpcitemdbApi? upcitemdbApi;
  final TheAudioDbApi? theAudioDbApi;
  final FanartApi? fanartApi;
  final IgdbApi? igdbApi;

  /// Circuit breaker for Google Books API — trips on 429 responses.
  final ApiCircuitBreaker googleBooksBreaker;

  /// Returns true if the exception is a 429 rate-limit response.
  static bool _isRateLimited(Object error) {
    return error is DioException && error.response?.statusCode == 429;
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

    if (barcodeType == BarcodeType.imdbId) {
      result = await _lookupImdbId(barcode, barcodeTypeStr);
    } else if (forceIsbn || BarcodeUtils.isIsbn(barcode)) {
      result = await _lookupBook(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.film || typeHint == MediaType.tv) {
      result = await _lookupFilm(barcode, barcodeTypeStr, typeHint: typeHint);
    } else if (typeHint == MediaType.music) {
      result = await _lookupMusic(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.game) {
      result = await _lookupGame(barcode, barcodeTypeStr);
    } else {
      // Unknown type — try UPCitemdb first to classify
      result = await _lookupGeneral(barcode, barcodeTypeStr);
    }

    // 3. Fallback to UPCitemdb if specialist returned nothing.
    // The `_lookupGeneral` branch already tries UPC itself, so only fall
    // through for the specialist paths (IMDb, ISBN, or a specific typeHint)
    // to avoid double-querying UPCitemdb.
    if (result == null &&
        (barcodeType == BarcodeType.imdbId ||
            forceIsbn ||
            BarcodeUtils.isIsbn(barcode) ||
            typeHint != null)) {
      result = await _lookupUpc(barcode, barcodeTypeStr);
    }

    // 4. Enrich single results with TheAudioDB/fanart.tv data
    if (result is SingleScanResult) {
      final enriched = await _enrichMetadata(result.metadata);
      return ScanResult.single(
        metadata: enriched,
        isDuplicate: result.isDuplicate,
      );
    }

    // 5. Return notFound if all lookups failed
    return result ??
        ScanResult.notFound(barcode: barcode, barcodeType: barcodeTypeStr);
  }

  @override
  Future<ScanResult> searchByTitle(
    String title,
    String barcode,
    String barcodeType, {
    MediaType? typeHint,
  }) async {
    ScanResult? result;

    if (typeHint == MediaType.film || typeHint == MediaType.tv) {
      result = await _searchTmdbByTitle(title, barcode, barcodeType);
    } else if (typeHint == MediaType.music) {
      result = await _searchMusicByTitle(title, barcode, barcodeType);
    } else if (typeHint == MediaType.book) {
      result = await _searchBookByTitle(title, barcode, barcodeType);
    } else if (typeHint == MediaType.game) {
      result = await _searchIgdbByTitle(title, barcode, barcodeType);
    } else {
      // No type hint — try TMDB first, then MusicBrainz, then Google Books
      result =
          await _searchTmdbByTitle(title, barcode, barcodeType) ??
          await _searchMusicByTitle(title, barcode, barcodeType) ??
          await _searchBookByTitle(title, barcode, barcodeType);
    }

    return result ??
        ScanResult.notFound(barcode: barcode, barcodeType: barcodeType);
  }

  Future<ScanResult?> _searchTmdbByTitle(
    String title,
    String barcode,
    String barcodeType,
  ) async {
    if (tmdbApi == null) return null;
    try {
      final response = await tmdbApi!.searchMulti(title);
      final results = response.results
          ?.where((r) => r.mediaType != 'person')
          .toList();
      if (results == null || results.isEmpty) return null;

      if (results.length == 1) {
        await _cacheResponse(barcode, 'film', 'tmdb', results.first.toJson());
        return ScanResult.single(
          metadata: TmdbMapper.fromSearchResult(
            results.first,
            barcode,
            barcodeType,
          ),
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
    } on Exception catch (e) {
      debugPrint('TMDB title search failed: $e');
    }
    return null;
  }

  /// Look up a movie or TV show by IMDb ID (e.g. tt1234567) using TMDB's
  /// find-by-external-ID endpoint.
  Future<ScanResult?> _lookupImdbId(String imdbId, String barcodeType) async {
    if (tmdbApi == null) return null;
    try {
      final response = await tmdbApi!.findByExternalId(imdbId);
      final results = response.allResults;
      if (results.isEmpty) return null;

      final first = results.first;
      await _cacheResponse(imdbId, 'film', 'tmdb', first.toJson());
      return ScanResult.single(
        metadata: TmdbMapper.fromSearchResult(first, imdbId, barcodeType),
        isDuplicate: false,
      );
    } on Exception catch (e) {
      debugPrint('TMDB IMDb ID lookup failed: $e');
    }
    return null;
  }

  Future<ScanResult?> _searchMusicByTitle(
    String title,
    String barcode,
    String barcodeType,
  ) async {
    // Try MusicBrainz first
    if (musicBrainzApi != null) {
      try {
        final response = await musicBrainzApi!.searchByTitle(title);
        final releases = response.releases;
        if (releases != null && releases.isNotEmpty) {
          if (releases.length == 1) {
            await _cacheResponse(
              barcode,
              'music',
              'musicbrainz',
              releases.first.toJson(),
            );
            return ScanResult.single(
              metadata: MusicBrainzMapper.fromRelease(
                releases.first,
                barcode,
                barcodeType,
              ),
              isDuplicate: false,
            );
          }
          final candidates = releases
              .take(AppConstants.maxCandidates)
              .map(MusicBrainzMapper.toCandidate)
              .toList();
          return ScanResult.multiMatch(
            candidates: candidates,
            barcode: barcode,
            barcodeType: barcodeType,
          );
        }
      } on Exception catch (e) {
        debugPrint('MusicBrainz title search failed: $e');
      }
    }

    // Fall back to Discogs title search
    if (discogsApi != null) {
      try {
        final response = await discogsApi!.searchByTitle(title);
        final results = response.results;
        if (results != null && results.isNotEmpty) {
          if (results.length == 1) {
            final searchResult = results.first;
            if (searchResult.id != null) {
              final release = await discogsApi!.getRelease(searchResult.id!);
              await _cacheResponse(
                barcode,
                'music',
                'discogs',
                release.toJson(),
              );
              return ScanResult.single(
                metadata: DiscogsMapper.fromRelease(
                  release,
                  barcode,
                  barcodeType,
                ),
                isDuplicate: false,
              );
            }
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
        }
      } on Exception catch (e) {
        debugPrint('Discogs title search failed: $e');
      }
    }
    return null;
  }

  Future<ScanResult?> _searchBookByTitle(
    String title,
    String barcode,
    String barcodeType,
  ) async {
    if (googleBooksApi != null && googleBooksBreaker.isOpen) {
      try {
        final response = await googleBooksApi!.searchByIsbn(title);
        googleBooksBreaker.reset();
        final items = response.items;
        if (items != null && items.isNotEmpty) {
          if (items.length == 1) {
            await _cacheResponse(
              barcode,
              'book',
              'google_books',
              items.first.toJson(),
            );
            return ScanResult.single(
              metadata: GoogleBooksMapper.fromVolume(
                items.first,
                barcode,
                barcodeType,
              ),
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
        }
        debugPrint(
          'Google Books title search failed: $e — '
          'falling back to Open Library',
        );
      }
    }

    // Fallback to Open Library `/search.json` when Google Books is
    // unavailable (rate-limited, 5xx, network error) or returned no items.
    if (openLibraryApi != null) {
      try {
        final response = await openLibraryApi!.searchByTitle(title);
        final docs = response?.docs;
        if (docs != null && docs.isNotEmpty) {
          if (docs.length == 1) {
            return ScanResult.single(
              metadata: OpenLibraryMapper.fromSearchDoc(
                docs.first,
                barcode,
                barcodeType,
              ),
              isDuplicate: false,
            );
          }
          final candidates = docs
              .take(AppConstants.maxCandidates)
              .map(OpenLibraryMapper.toSearchCandidate)
              .toList();
          return ScanResult.multiMatch(
            candidates: candidates,
            barcode: barcode,
            barcodeType: barcodeType,
          );
        }
      } on Exception catch (e) {
        debugPrint('Open Library title search failed: $e');
      }
    }
    return null;
  }

  Future<ScanResult?> _searchIgdbByTitle(
    String title,
    String barcode,
    String barcodeType,
  ) async {
    if (igdbApi == null) return null;
    try {
      final games = await igdbApi!.searchByTitle(title);
      if (games.isEmpty) return null;

      if (games.length == 1) {
        await _cacheResponse(barcode, 'game', 'igdb', games.first.toJson());
        return ScanResult.single(
          metadata: IgdbMapper.fromGame(games.first, barcode, barcodeType),
          isDuplicate: false,
        );
      }

      final candidates = games
          .take(AppConstants.maxCandidates)
          .map(IgdbMapper.toCandidate)
          .toList();
      return ScanResult.multiMatch(
        candidates: candidates,
        barcode: barcode,
        barcodeType: barcodeType,
      );
    } on Exception catch (e) {
      debugPrint('IGDB title search failed: $e');
    }
    return null;
  }

  /// Look up a game by barcode. IGDB has no barcode endpoint, so we fetch
  /// the title from UPCitemdb first and then enrich via IGDB title search.
  /// If IGDB finds nothing, the UPC result stands on its own.
  Future<ScanResult?> _lookupGame(String barcode, String barcodeType) async {
    final upcResult = await _lookupUpcMetadata(barcode, barcodeType);
    if (upcResult?.title == null) return null;

    if (igdbApi == null) {
      return ScanResult.single(metadata: upcResult!, isDuplicate: false);
    }

    try {
      final games = await igdbApi!.searchByTitle(upcResult!.title!);
      if (games.isEmpty) {
        return ScanResult.single(metadata: upcResult, isDuplicate: false);
      }

      if (games.length == 1) {
        await _cacheResponse(barcode, 'game', 'igdb', games.first.toJson());
        return ScanResult.single(
          metadata: IgdbMapper.fromGame(games.first, barcode, barcodeType),
          isDuplicate: false,
        );
      }

      final candidates = games
          .take(AppConstants.maxCandidates)
          .map(IgdbMapper.toCandidate)
          .toList();
      return ScanResult.multiMatch(
        candidates: candidates,
        barcode: barcode,
        barcodeType: barcodeType,
      );
    } on Exception catch (e) {
      debugPrint('IGDB enrichment for game barcode failed: $e');
      return ScanResult.single(metadata: upcResult!, isDuplicate: false);
    }
  }

  @override
  Future<MetadataResult?> fetchCandidateDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    return switch (candidate.sourceApi) {
      'musicbrainz' => _fetchMusicBrainzDetail(candidate, barcode, barcodeType),
      'discogs' => _fetchDiscogsDetail(candidate, barcode, barcodeType),
      'tmdb' => _fetchTmdbDetail(candidate, barcode, barcodeType),
      'tvdb' => _fetchTvdbDetail(candidate, barcode, barcodeType),
      'google_books' => _fetchGoogleBooksDetail(
        candidate,
        barcode,
        barcodeType,
      ),
      'open_library' => _fetchOpenLibraryDetail(
        candidate,
        barcode,
        barcodeType,
      ),
      'upcitemdb' => _fetchUpcDetail(candidate, barcode, barcodeType),
      'igdb' => _fetchIgdbDetail(candidate, barcode, barcodeType),
      _ => null,
    };
  }

  Future<MetadataResult?> _fetchIgdbDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (igdbApi == null) return null;
    try {
      final id = int.parse(candidate.sourceId);
      final game = await igdbApi!.getById(id);
      if (game == null) return null;
      await _cacheResponse(barcode, 'game', 'igdb', game.toJson());
      return IgdbMapper.fromGame(game, barcode, barcodeType);
    } on Exception catch (e) {
      debugPrint('IGDB detail fetch failed: $e');
    }
    return null;
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
      final results = response.results;
      if (results == null || results.isEmpty) return null;
      final match = results.firstWhere(
        (r) => r.id?.toString() == candidate.sourceId,
        orElse: () => results.first,
      );
      await _cacheResponse(barcode, 'film', 'tmdb', match.toJson());
      return TmdbMapper.fromSearchResult(match, barcode, barcodeType);
    } on Exception catch (e) {
      debugPrint('TMDB detail fetch failed: $e');
    }
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
      final items = response.items;
      if (items != null && items.isNotEmpty) {
        final match = items.firstWhere(
          (v) => v.id == candidate.sourceId,
          orElse: () => items.first,
        );
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

    // Title-search candidates carry a work key like `/works/OL27479W` in
    // `sourceId`. Resolve by re-running the search and matching the key —
    // the by-ISBN endpoint can't find works picked from an OCR flow where
    // the scanned `barcode` isn't the book's ISBN.
    if (candidate.sourceId.startsWith('/works/')) {
      try {
        final response = await openLibraryApi!.searchByTitle(candidate.title);
        final docs = response?.docs;
        if (docs != null && docs.isNotEmpty) {
          final match = docs.firstWhere(
            (d) => d.key == candidate.sourceId,
            orElse: () => docs.first,
          );
          return OpenLibraryMapper.fromSearchDoc(match, barcode, barcodeType);
        }
      } on Exception catch (e) {
        debugPrint('Open Library work-key detail fetch failed: $e');
      }
      return null;
    }

    try {
      final book = await openLibraryApi!.getByIsbn(barcode);
      if (book != null) {
        await _cacheResponse(barcode, 'book', 'open_library', book.toJson());
        return OpenLibraryMapper.fromBook(book, barcode, barcodeType);
      }
    } on Exception catch (e) {
      debugPrint('Open Library detail fetch failed: $e');
    }
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
      final items = response.items;
      if (items != null && items.isNotEmpty) {
        final match = items.firstWhere(
          (i) => (i.ean ?? barcode) == candidate.sourceId,
          orElse: () => items.first,
        );
        await _cacheResponse(barcode, null, 'upcitemdb', match.toJson());
        return UpcMapper.fromItem(match, barcode, barcodeType);
      }
    } on Exception catch (e) {
      debugPrint('UPCitemdb detail fetch failed: $e');
    }
    return null;
  }

  Future<MetadataResult?> _fetchTvdbDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (tvdbApi == null) return null;
    try {
      final id = int.parse(candidate.sourceId);
      final response = await tvdbApi!.getSeries(id);
      final series = response.data;
      if (series != null) {
        await _cacheResponse(barcode, 'tv', 'tvdb', series.toJson());
        return TvdbMapper.fromSeries(series, barcode, barcodeType);
      }
    } on Exception catch (e) {
      debugPrint('TVDB detail fetch failed: $e');
    }
    return null;
  }

  Future<MetadataResult?> _fetchMusicBrainzDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  ) async {
    if (musicBrainzApi == null) return null;
    try {
      final release = await musicBrainzApi!.getRelease(candidate.sourceId);
      if (release != null) {
        await _cacheResponse(barcode, 'music', 'musicbrainz', release.toJson());
        return _buildMusicBrainzResult(release, barcode, barcodeType);
      }
    } on RateLimitExceededException catch (e) {
      debugPrint('MusicBrainz rate-limited during detail fetch: $e');
    } on Exception catch (e) {
      debugPrint('MusicBrainz detail fetch failed: $e');
    }
    return null;
  }

  // -- Enrichment --

  /// Fetch TheAudioDB critic-score fields and merge them into [result].
  /// Best-effort: returns [result] unchanged on any failure.
  Future<MetadataResult> _enrichWithAudioDb(MetadataResult result) async {
    if (result.mediaType != MediaType.music || theAudioDbApi == null) {
      return result;
    }
    final mbRgId = _asString(
      result.extraMetadata['musicbrainz_release_group_id'],
    );
    if (mbRgId == null) return result;
    try {
      final album = await theAudioDbApi!.getByMusicBrainzId(mbRgId);
      if (album != null) return EnrichmentMerger.mergeAudioDb(result, album);
    } on Exception catch (e) {
      debugPrint('TheAudioDB enrichment failed: $e');
    }
    return result;
  }

  /// Fetch the best fanart.tv poster/cover URL for [result].
  /// Best-effort: returns `null` on any failure.
  Future<String?> _fetchFanartUrl(MetadataResult result) async {
    if (fanartApi == null) return null;
    try {
      if (result.mediaType == MediaType.film) {
        final tmdbId = _asInt(result.extraMetadata['tmdb_id']);
        if (tmdbId != null) {
          final images = await fanartApi!.getMovieImages(tmdbId);
          return images.bestPosterUrl;
        }
      } else if (result.mediaType == MediaType.tv) {
        final tvdbId = _asInt(result.extraMetadata['tvdb_id']);
        if (tvdbId != null) {
          final images = await fanartApi!.getTvImages(tvdbId);
          return images.bestPosterUrl;
        }
      } else if (result.mediaType == MediaType.music) {
        final mbRgId = _asString(
          result.extraMetadata['musicbrainz_release_group_id'],
        );
        if (mbRgId != null) {
          final images = await fanartApi!.getAlbumImages(mbRgId);
          return images.bestCoverUrl;
        }
      }
    } on Exception catch (e) {
      debugPrint('fanart.tv enrichment failed: $e');
    }
    return null;
  }

  /// Defensively coerce cached JSON numerics back to `int`. `extraMetadata`
  /// round-trips through JSON where numeric fields may be deserialised as
  /// `double` on some platforms — a bare `as int?` cast would throw.
  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(Object? value) =>
      value is String ? value : value?.toString();

  /// Enrich a metadata result with TheAudioDB scores and fanart.tv artwork.
  /// Failures are silently ignored — enrichment is best-effort.
  ///
  /// Runs the two independent enrichments in parallel — they don't depend
  /// on each other, so serialising them just adds ~200-500 ms of tail
  /// latency to the user-visible scan flow.
  Future<MetadataResult> _enrichMetadata(MetadataResult result) async {
    final audioDb = _enrichWithAudioDb(result);
    final fanartUrl = _fetchFanartUrl(result);
    final audioDbEnriched = await audioDb;
    // Re-base fanart merge on the audioDb-enriched result so both updates
    // compose cleanly.
    final url = await fanartUrl;
    var enriched = audioDbEnriched;
    if (fanartApi != null) {
      enriched = EnrichmentMerger.mergeFanartCover(enriched, url);
    }

    return enriched;
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
          TmdbSearchResultDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'discogs' => DiscogsMapper.fromRelease(
          DiscogsReleaseDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'google_books' => GoogleBooksMapper.fromVolume(
          GoogleBooksVolumeDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'open_library' => OpenLibraryMapper.fromBook(
          OpenLibraryBookDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'upcitemdb' => UpcMapper.fromItem(
          UpcItemDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'musicbrainz' => MusicBrainzMapper.fromRelease(
          MusicBrainzReleaseDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'tvdb' => TvdbMapper.fromSeries(
          TvdbSeriesDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        'igdb' => IgdbMapper.fromGame(
          IgdbGameDto.fromJson(json),
          barcode,
          barcodeType,
        ),
        _ => null,
      };
      if (metadata == null) return null;
      return ScanResult.single(metadata: metadata, isDuplicate: false);
    } catch (e) {
      debugPrint('Cache deserialization failed for $barcode: $e');
      // Evict the poisoned row so it doesn't keep throwing on every lookup.
      try {
        await _cacheDao.deleteByBarcode(barcode);
      } catch (_) {}
      return null;
    }
  }

  // -- Lookup methods --

  Future<ScanResult?> _lookupBook(String barcode, String barcodeType) async {
    // Try Google Books first (skip if circuit breaker is tripped)
    if (googleBooksApi != null && googleBooksBreaker.isOpen) {
      try {
        final response = await googleBooksApi!.searchByIsbn('isbn:$barcode');
        googleBooksBreaker.reset();
        final items = response.items;
        if (items != null && items.isNotEmpty) {
          if (items.length == 1) {
            await _cacheResponse(
              barcode,
              'book',
              'google_books',
              items.first.toJson(),
            );
            return ScanResult.single(
              metadata: GoogleBooksMapper.fromVolume(
                items.first,
                barcode,
                barcodeType,
              ),
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
          debugPrint(
            'Google Books API rate-limited (429) — '
            'circuit breaker tripped, falling back to Open Library',
          );
        }
        // Fall through to Open Library
      }
    }

    // Fallback to Open Library
    if (openLibraryApi != null) {
      try {
        final book = await openLibraryApi!.getByIsbn(barcode);
        if (book != null) {
          await _cacheResponse(barcode, 'book', 'open_library', book.toJson());
          return ScanResult.single(
            metadata: OpenLibraryMapper.fromBook(book, barcode, barcodeType),
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
    String barcode,
    String barcodeType, {
    MetadataResult? upcHint,
    MediaType? typeHint,
  }) async {
    if (tmdbApi == null) return null;
    try {
      // TMDB doesn't support barcode search directly — use UPCitemdb
      // to get a title, then search TMDB by title.
      // Accept a pre-fetched UPC result to avoid double lookups.
      final titleSource =
          upcHint ?? await _lookupUpcMetadata(barcode, barcodeType);
      if (titleSource?.title == null) return null;

      final response = await tmdbApi!.searchMulti(titleSource!.title!);
      // Filter out "person" results — only keep movie and TV.
      var results = response.results
          ?.where((r) => r.mediaType != 'person')
          .toList();
      if (results == null || results.isEmpty) return null;

      // If caller provided a type hint, prefer results whose TMDB media_type
      // matches. Fall back to the unfiltered list if the hint would leave
      // us with nothing (better to return a mismatched hit than nothing).
      if (typeHint == MediaType.tv) {
        final tvOnly = results.where((r) => r.mediaType == 'tv').toList();
        if (tvOnly.isNotEmpty) results = tvOnly;
      } else if (typeHint == MediaType.film) {
        final movieOnly =
            results.where((r) => r.mediaType == 'movie').toList();
        if (movieOnly.isNotEmpty) results = movieOnly;
      }

      if (results.length == 1) {
        await _cacheResponse(barcode, 'film', 'tmdb', results.first.toJson());
        return ScanResult.single(
          metadata: TmdbMapper.fromSearchResult(
            results.first,
            barcode,
            barcodeType,
          ),
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
    } on Exception catch (e) {
      debugPrint('Film lookup failed: $e');
    }
    return null;
  }

  Future<ScanResult?> _lookupMusic(String barcode, String barcodeType) async {
    // 1. Try MusicBrainz first (free, good international barcode coverage)
    final mbResult = await _lookupMusicBrainz(barcode, barcodeType);
    if (mbResult != null) return mbResult;

    // 2. Fall back to Discogs
    if (discogsApi == null) return null;
    try {
      final response = await discogsApi!.searchByBarcode(barcode);
      final results = response.results;
      if (results == null || results.isEmpty) return null;

      if (results.length == 1) {
        final searchResult = results.first;
        if (searchResult.id != null) {
          final release = await discogsApi!.getRelease(searchResult.id!);
          await _cacheResponse(barcode, 'music', 'discogs', release.toJson());
          return ScanResult.single(
            metadata: DiscogsMapper.fromRelease(release, barcode, barcodeType),
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
    } on Exception catch (e) {
      debugPrint('Music lookup (Discogs) failed: $e');
    }
    return null;
  }

  Future<ScanResult?> _lookupMusicBrainz(
    String barcode,
    String barcodeType,
  ) async {
    if (musicBrainzApi == null) return null;
    try {
      final response = await musicBrainzApi!.searchByBarcode(barcode);
      final releases = response.releases;
      if (releases == null || releases.isEmpty) return null;

      final ranked = _rankMusicBrainzReleases(releases);
      if (ranked.isEmpty) return null;

      final best = ranked.first;
      final runnerUp = ranked.length > 1 ? ranked[1] : null;
      final autoAccept = _shouldAutoAccept(best: best, runnerUp: runnerUp);

      if (autoAccept) {
        MusicBrainzReleaseDto detail = best;
        final id = best.id;
        if (id != null) {
          try {
            final fetched = await musicBrainzApi!.getRelease(id);
            if (fetched != null) detail = fetched;
          } on RateLimitExceededException {
            rethrow;
          } catch (e) {
            // Detail fetch is best-effort; fall through to summary data.
            debugPrint('MusicBrainz release detail fetch failed: $e');
          }
        }
        final result = await _buildMusicBrainzResult(
          detail,
          barcode,
          barcodeType,
        );
        await _cacheResponse(barcode, 'music', 'musicbrainz', detail.toJson());
        return ScanResult.single(metadata: result, isDuplicate: false);
      }

      final candidates = ranked
          .take(AppConstants.maxCandidates)
          .map(MusicBrainzMapper.toCandidate)
          .toList();
      return ScanResult.multiMatch(
        candidates: candidates,
        barcode: barcode,
        barcodeType: barcodeType,
      );
    } on RateLimitExceededException catch (e) {
      debugPrint('MusicBrainz rate-limited: $e — falling back to Discogs');
    } on Exception catch (e) {
      debugPrint('Music lookup (MusicBrainz) failed: $e');
    }
    return null;
  }

  /// Orders MusicBrainz release candidates by descending completeness score.
  ///
  /// Ranking heuristics (PRD §15): Official status > bootleg; common
  /// physical formats (CD/vinyl/cassette) preferred; presence of
  /// label/catalogue data and non-zero track counts raise the score; the
  /// MusicBrainz server-side `score` is added so an exact barcode match
  /// surfaces naturally.
  List<MusicBrainzReleaseDto> _rankMusicBrainzReleases(
    List<MusicBrainzReleaseDto> releases,
  ) {
    int scoreOf(MusicBrainzReleaseDto r) {
      var score = 0;
      if ((r.status ?? '').toLowerCase() == 'official') score += 40;
      final format = (r.effectiveFormat ?? '').toLowerCase();
      if (format.contains('cd') ||
          format.contains('vinyl') ||
          format.contains('cassette')) {
        score += 20;
      }
      if (r.labelInfo?.firstOrNull?.catalogNumber != null) score += 10;
      if (r.labelInfo?.firstOrNull?.label?.name != null) score += 10;
      final tc = r.media?.firstOrNull?.trackCount ?? r.trackCount ?? 0;
      if (tc > 0) score += 10;
      if ((r.date ?? '').isNotEmpty) score += 5;
      if ((r.country ?? '').isNotEmpty) score += 5;
      return score + (r.score ?? 0);
    }

    final scored = releases.map((r) => (release: r, score: scoreOf(r))).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.release).toList();
  }

  bool _shouldAutoAccept({
    required MusicBrainzReleaseDto best,
    MusicBrainzReleaseDto? runnerUp,
  }) {
    // Single-release results from a barcode query are treated as a strong
    // match — MusicBrainz-by-barcode rarely produces fuzzy hits when only
    // one release comes back, and `score` is frequently null even on good
    // matches. Retain the original behaviour of accepting singletons; only
    // apply the confidence gate when we have a runner-up to compare.
    if (runnerUp == null) return true;
    final bestOfficial = (best.status ?? '').toLowerCase() == 'official';
    final runnerOfficial = (runnerUp.status ?? '').toLowerCase() == 'official';
    if (bestOfficial && !runnerOfficial) return true;
    final bestScore = best.score ?? 0;
    final runnerScore = runnerUp.score ?? 0;
    // Only accept when MusicBrainz itself says the top is clearly better.
    return bestScore >= 95 && bestScore - runnerScore >= 20;
  }

  Future<MetadataResult> _buildMusicBrainzResult(
    MusicBrainzReleaseDto release,
    String barcode,
    String barcodeType,
  ) async {
    final mapped = MusicBrainzMapper.fromRelease(release, barcode, barcodeType);
    final artUrl = await _resolveCoverArt(release);
    return artUrl == null ? mapped : mapped.copyWith(coverUrl: artUrl);
  }

  Future<String?> _resolveCoverArt(MusicBrainzReleaseDto release) async {
    final api = coverArtArchiveApi;
    if (api == null || release.id == null) return release.coverUrl;
    final archiveUrl = await api.findFrontArtwork(
      releaseId: release.id!,
      releaseGroupId: release.releaseGroupId,
    );
    return archiveUrl ?? release.coverUrl;
  }

  Future<ScanResult?> _lookupGeneral(String barcode, String barcodeType) async {
    // 1. Try MusicBrainz barcode search first — if it matches, it's music.
    // MusicBrainz has better international barcode coverage than UPCitemdb.
    final mbResult = await _lookupMusicBrainz(barcode, barcodeType);
    if (mbResult != null) return mbResult;

    // 2. Try UPCitemdb to classify the barcode type
    final upcResult = await _lookupUpcMetadata(barcode, barcodeType);
    if (upcResult == null) return null;

    // If UPC gave us a type hint, try the specialist API
    if (upcResult.mediaType == MediaType.book) {
      return await _lookupBook(barcode, barcodeType) ??
          ScanResult.single(metadata: upcResult, isDuplicate: false);
    }
    if (upcResult.mediaType == MediaType.film ||
        upcResult.mediaType == MediaType.tv) {
      final filmResult = await _lookupFilm(
        barcode,
        barcodeType,
        upcHint: upcResult,
      );
      return filmResult ??
          ScanResult.single(metadata: upcResult, isDuplicate: false);
    }
    if (upcResult.mediaType == MediaType.music) {
      // MusicBrainz already tried above, go straight to Discogs
      if (discogsApi != null) {
        try {
          final response = await discogsApi!.searchByBarcode(barcode);
          final results = response.results;
          if (results != null && results.isNotEmpty) {
            if (results.length == 1 && results.first.id != null) {
              final release = await discogsApi!.getRelease(results.first.id!);
              await _cacheResponse(
                barcode,
                'music',
                'discogs',
                release.toJson(),
              );
              return ScanResult.single(
                metadata: DiscogsMapper.fromRelease(
                  release,
                  barcode,
                  barcodeType,
                ),
                isDuplicate: false,
              );
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
          }
        } on Exception catch (e) {
          debugPrint('Discogs lookup in general flow failed: $e');
        }
      }
      return ScanResult.single(metadata: upcResult, isDuplicate: false);
    }

    return ScanResult.single(metadata: upcResult, isDuplicate: false);
  }

  Future<ScanResult?> _lookupUpc(String barcode, String barcodeType) async {
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
      final items = response.items;
      if (items == null || items.isEmpty) return null;
      // UPCitemdb can legitimately return multiple entries for a shared
      // GTIN (re-used barcodes across editions). Prefer the one whose
      // own `ean`/`upc` exactly matches the scanned barcode over the
      // first item; fall back to the first only if no exact match is found.
      final exact = items.firstWhere(
        (i) => i.ean == barcode,
        orElse: () => items.first,
      );
      await _cacheResponse(barcode, null, 'upcitemdb', exact.toJson());
      return UpcMapper.fromItem(exact, barcode, barcodeType);
    } on Exception catch (e) {
      debugPrint('UPC metadata lookup failed: $e');
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
      await _cacheDao.upsert(
        BarcodeCacheTableCompanion(
          barcode: Value(barcode),
          mediaTypeHint: Value(mediaTypeHint),
          responseJson: Value(jsonEncode(responseJson)),
          sourceApi: Value(sourceApi),
          cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    } on Exception catch (_) {
      // Cache failures are non-critical
    }
  }
}
