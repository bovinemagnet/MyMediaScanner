/// Orchestrates the GnuDB lookup flow for a single rip album.
///
/// The use case:
///
/// 1. Parses the album's CUE sheet to obtain per-track INDEX 01 offsets.
/// 2. Combines those with track durations to compute the LBA frame offsets
///    and leadout, from which the CDDB Disc ID is derived.
/// 3. Persists the Disc ID on the rip album.
/// 4. Checks the candidate cache (keyed by disc id) for a recent
///    response before hitting the network.
/// 5. Queries GnuDB. On single match, reads full metadata and returns it.
///    On multi match, reads each candidate (capped) and returns them.
///    On no-match or error, returns the corresponding sealed result.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/core/gnudb/cddb_disc_id_calculator.dart';
import 'package:mymediascanner/core/gnudb/cue_frame_offsets_parser.dart';
import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/entities/gnudb_query_result.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_gnudb_candidate_cache.dart';
import 'package:mymediascanner/domain/repositories/i_gnudb_service.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';

export 'package:mymediascanner/domain/entities/gnudb_disc.dart'
    show GnudbCandidate;

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
    required IGnudbService api,
    required IGnudbCandidateCache cache,
    required IRipLibraryRepository repository,
    required String rootPath,
    CueFrameOffsetsLoader? loader,
  })  : _api = api,
        _cache = cache,
        _repository = repository,
        _rootPath = rootPath,
        _loader = loader ?? _defaultLoader;

  final IGnudbService _api;
  final IGnudbCandidateCache _cache;
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
    if (tracks.isEmpty) {
      return const GnudbLookupError('Album has no tracks');
    }
    // Multi-disc albums are looked up against whatever the resolved CUE
    // represents (typically disc 1 of the set). When the CUE genuinely
    // describes the merged set, the computed disc ID won't match any
    // GnuDB release and the caller will see a normal "no match" result.

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
        final disc = await _api.read(
            category: match.category, discId: match.discId);
        if (disc == null) {
          return const GnudbLookupError('GnuDB read returned no data');
        }
        final candidate = GnudbCandidate(
          discId: match.discId,
          category: match.category,
          disc: disc,
        );
        await _cache.write(discId, [candidate]);
        return GnudbLookupSingle(candidate);
      case GnudbQueryMulti(:final matches):
        if (matches.isEmpty) return const GnudbLookupNoMatch();
        final candidates = <GnudbCandidate>[];
        for (final m in matches.take(_maxMultiCandidates)) {
          final disc = await _api.read(
              category: m.category, discId: m.discId);
          if (disc != null) {
            candidates.add(GnudbCandidate(
              discId: m.discId,
              category: m.category,
              disc: disc,
            ));
          }
        }
        if (candidates.isEmpty) {
          return const GnudbLookupNoMatch();
        }
        await _cache.write(discId, candidates);
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
    final candidates = await _cache.read(discId);
    if (candidates == null) return null;
    if (candidates.isEmpty) return const GnudbLookupNoMatch();
    if (candidates.length == 1) return GnudbLookupSingle(candidates.first);
    return GnudbLookupMulti(candidates);
  }
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
