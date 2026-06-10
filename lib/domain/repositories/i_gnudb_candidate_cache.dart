import 'package:mymediascanner/domain/entities/gnudb_disc.dart';

/// Cache of resolved GnuDB lookup candidates keyed by CDDB Disc ID.
/// Implemented in the data layer over the shared barcode cache.
///
/// Author: Paul Snow
/// Since: 0.0.0
abstract interface class IGnudbCandidateCache {
  /// Returns the cached candidates for [discId], or `null` when there is
  /// no entry, the entry is stale, or it cannot be decoded.
  Future<List<GnudbCandidate>?> read(String discId);

  /// Stores [candidates] for [discId], replacing any previous entry.
  Future<void> write(String discId, List<GnudbCandidate> candidates);
}
