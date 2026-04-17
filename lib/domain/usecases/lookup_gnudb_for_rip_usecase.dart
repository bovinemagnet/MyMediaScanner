/// Orchestrates the GnuDB lookup flow for a single rip album.
///
/// The use case:
///
/// 1. Parses the album's CUE sheet to obtain per-track INDEX 01 offsets.
/// 2. Combines those with track durations to compute the LBA frame offsets
///    and leadout, from which the CDDB Disc ID is derived.
/// 3. Persists the Disc ID on the rip album.
/// 4. Checks the shared barcode cache (keyed `gnudb:<discid>`) for a recent
///    response before hitting the network.
/// 5. Queries GnuDB. On single match, reads full metadata and returns it.
///    On multi match, reads each candidate (capped) and returns them.
///    On no-match or error, returns the corresponding sealed result.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/gnudb/cddb_disc_id_calculator.dart';
import 'package:mymediascanner/core/gnudb/cue_frame_offsets_parser.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_api.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_response_parser.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

/// Pairs a `MetadataResult`-ready payload with its GnuDB disc id.
class GnudbCandidate {
  const GnudbCandidate({
    required this.discId,
    required this.category,
    required this.dto,
  });
  final String discId;
  final String category;
  final GnudbDiscDto dto;
}

/// Sealed result of [LookupGnudbForRipUseCase.execute].
sealed class GnudbLookupResult {
  const GnudbLookupResult();
}

class GnudbLookupSingle extends GnudbLookupResult {
  const GnudbLookupSingle(this.candidate);
  final GnudbCandidate candidate;
}

class GnudbLookupMulti extends GnudbLookupResult {
  const GnudbLookupMulti(this.candidates);
  final List<GnudbCandidate> candidates;
}

class GnudbLookupNoMatch extends GnudbLookupResult {
  const GnudbLookupNoMatch();
}

class GnudbLookupError extends GnudbLookupResult {
  const GnudbLookupError(this.message);
  final String message;
}

/// Maximum number of candidates we'll read from GnuDB on a multi-match.
const int _maxMultiCandidates = 5;

/// Pregap, in frames, conventionally added to track offsets to yield LBA.
const int _pregapFrames = 150;

/// Orchestrator for GnuDB metadata lookups keyed off a rip album's CUE.
class LookupGnudbForRipUseCase {
  LookupGnudbForRipUseCase({
    required GnudbApi api,
    required BarcodeCacheDao cacheDao,
    required IRipLibraryRepository repository,
    required String rootPath,
    CueFrameOffsetsLoader? loader,
  })  : _api = api,
        _cacheDao = cacheDao,
        _repository = repository,
        _rootPath = rootPath,
        _loader = loader ?? _defaultLoader;

  final GnudbApi _api;
  final BarcodeCacheDao _cacheDao;
  final IRipLibraryRepository _repository;
  final String _rootPath;
  final CueFrameOffsetsLoader _loader;

  static Future<List<CueTrackOffset>> _defaultLoader(String path) {
    return CueFrameOffsetsParser.parseFile(path);
  }

  /// Runs a GnuDB lookup for [album] using its CUE and [tracks] durations.
  Future<GnudbLookupResult> execute({
    required RipAlbum album,
    required List<RipTrack> tracks,
  }) async {
    if (album.cueFilePath == null) {
      return const GnudbLookupError('Album has no CUE sheet');
    }
    if (album.discCount != 1) {
      return const GnudbLookupError(
          'Multi-disc albums are not supported by GnuDB in this version');
    }
    if (tracks.isEmpty) {
      return const GnudbLookupError('Album has no tracks');
    }

    // Tracks must be ordered by track number for correct offset assembly.
    final ordered = [...tracks]..sort(
        (a, b) => a.trackNumber.compareTo(b.trackNumber));

    final List<CueTrackOffset> cueOffsets;
    try {
      final resolvedCuePath = _resolveCuePath(album.cueFilePath!);
      cueOffsets = await _loader(resolvedCuePath);
    } catch (e) {
      return GnudbLookupError('Failed to parse CUE sheet: $e');
    }

    if (cueOffsets.isEmpty) {
      return const GnudbLookupError('CUE sheet contains no audio tracks');
    }
    if (cueOffsets.length != ordered.length) {
      return GnudbLookupError(
          'CUE has ${cueOffsets.length} tracks but album has ${ordered.length}');
    }
    for (final t in ordered) {
      if (t.durationMs == null || t.durationMs! <= 0) {
        return GnudbLookupError(
            'Track ${t.trackNumber} is missing a valid duration');
      }
    }

    final layout = _buildLayout(cueOffsets, ordered);
    final discId = CddbDiscIdCalculator.calculate(
      frameOffsets: layout.lbaOffsets,
      leadoutFrame: layout.leadoutFrame,
    );

    await _repository.updateGnudbDiscId(album.id, discId);

    // Cache fast path.
    final cached = await _readCached(discId);
    if (cached != null) return cached;

    final query = await _api.query(
      discId: discId,
      frameOffsets: layout.lbaOffsets,
      totalSeconds: layout.totalSeconds,
    );

    switch (query) {
      case GnudbQueryNoMatch():
        return const GnudbLookupNoMatch();
      case GnudbQueryError(:final code, :final message):
        return GnudbLookupError(
            'GnuDB server returned $code: $message');
      case GnudbQuerySingle(:final match):
        final dto = await _api.read(
            category: match.category, discId: match.discId);
        if (dto == null) {
          return const GnudbLookupError('GnuDB read returned no data');
        }
        final candidate = GnudbCandidate(
          discId: match.discId,
          category: match.category,
          dto: dto,
        );
        await _writeCached(discId, [candidate]);
        return GnudbLookupSingle(candidate);
      case GnudbQueryMulti(:final matches):
        if (matches.isEmpty) return const GnudbLookupNoMatch();
        final candidates = <GnudbCandidate>[];
        for (final m in matches.take(_maxMultiCandidates)) {
          final dto = await _api.read(
              category: m.category, discId: m.discId);
          if (dto != null) {
            candidates.add(GnudbCandidate(
              discId: m.discId,
              category: m.category,
              dto: dto,
            ));
          }
        }
        if (candidates.isEmpty) {
          return const GnudbLookupNoMatch();
        }
        await _writeCached(discId, candidates);
        return GnudbLookupMulti(candidates);
    }
  }

  String _resolveCuePath(String cueRelativePath) {
    // Match the rip scanner's semantics: paths are stored relative to the
    // library root, with forward slashes for stable on-disk records.
    if (cueRelativePath.startsWith('/') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(cueRelativePath)) {
      return cueRelativePath;
    }
    final sep = _rootPath.endsWith('/') || _rootPath.endsWith(r'\') ? '' : '/';
    return '$_rootPath$sep$cueRelativePath';
  }

  _DiscLayout _buildLayout(
      List<CueTrackOffset> cueOffsets, List<RipTrack> ordered) {
    // LBA offsets grow through every FILE boundary: when the FILE changes,
    // the cumulative frame count jumps by the total frames of the tracks in
    // the file we are leaving.
    final lbaOffsets = <int>[];
    int cumulativeFileFrames = 0;
    String? currentFile;
    int firstTrackInFileIndex = 0;

    for (int i = 0; i < cueOffsets.length; i++) {
      final o = cueOffsets[i];
      if (o.filePath != currentFile) {
        if (currentFile != null) {
          for (int j = firstTrackInFileIndex; j < i; j++) {
            cumulativeFileFrames +=
                (((ordered[j].durationMs ?? 0) * 75) ~/ 1000);
          }
        }
        currentFile = o.filePath;
        firstTrackInFileIndex = i;
      }
      lbaOffsets.add(_pregapFrames + cumulativeFileFrames + o.inFileFrameOffset);
    }

    final totalTrackFrames = ordered
        .map((t) => ((t.durationMs ?? 0) * 75) ~/ 1000)
        .fold<int>(0, (a, b) => a + b);
    final leadoutFrame = _pregapFrames + totalTrackFrames;
    final totalSeconds = leadoutFrame ~/ 75;

    return _DiscLayout(
      lbaOffsets: lbaOffsets,
      leadoutFrame: leadoutFrame,
      totalSeconds: totalSeconds,
    );
  }

  Future<GnudbLookupResult?> _readCached(String discId) async {
    final hit = await _cacheDao.getByBarcode(_cacheKey(discId));
    if (hit == null) return null;
    final age =
        DateTime.now().millisecondsSinceEpoch - hit.cachedAt;
    const maxAgeMs = ApiConstants.cacheDurationDays * 86_400_000;
    if (age > maxAgeMs) return null;
    try {
      final payload = jsonDecode(hit.responseJson) as Map<String, dynamic>;
      final candidates = (payload['candidates'] as List)
          .map((c) => GnudbCandidate(
                discId: c['disc_id'] as String,
                category: c['category'] as String,
                dto: GnudbDiscDto(
                  discId: c['disc_id'] as String,
                  artist: c['artist'] as String,
                  albumTitle: c['album_title'] as String,
                  year: c['year'] as int?,
                  genre: c['genre'] as String?,
                  trackTitles: (c['track_titles'] as List).cast<String>(),
                  extendedAlbum: c['extended_album'] as String?,
                ),
              ))
          .toList();
      if (candidates.isEmpty) return const GnudbLookupNoMatch();
      if (candidates.length == 1) return GnudbLookupSingle(candidates.first);
      return GnudbLookupMulti(candidates);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCached(
      String discId, List<GnudbCandidate> candidates) async {
    final payload = jsonEncode({
      'candidates': [
        for (final c in candidates)
          {
            'disc_id': c.discId,
            'category': c.category,
            'artist': c.dto.artist,
            'album_title': c.dto.albumTitle,
            'year': c.dto.year,
            'genre': c.dto.genre,
            'track_titles': c.dto.trackTitles,
            'extended_album': c.dto.extendedAlbum,
          }
      ],
    });
    await _cacheDao.upsert(BarcodeCacheTableCompanion(
      barcode: Value(_cacheKey(discId)),
      mediaTypeHint: const Value('music'),
      responseJson: Value(payload),
      sourceApi: const Value('gnudb'),
      cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  String _cacheKey(String discId) => 'gnudb:$discId';
}

/// Allows tests to inject an in-memory CUE offsets source.
typedef CueFrameOffsetsLoader = Future<List<CueTrackOffset>> Function(
    String resolvedPath);

class _DiscLayout {
  const _DiscLayout({
    required this.lbaOffsets,
    required this.leadoutFrame,
    required this.totalSeconds,
  });
  final List<int> lbaOffsets;
  final int leadoutFrame;
  final int totalSeconds;
}

