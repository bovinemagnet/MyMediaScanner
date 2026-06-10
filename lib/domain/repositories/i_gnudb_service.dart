import 'package:mymediascanner/domain/entities/gnudb_disc.dart';
import 'package:mymediascanner/domain/entities/gnudb_query_result.dart';

/// GnuDB (CDDB) lookup operations needed by the rip-library use cases.
/// Implemented in the data layer over the gnudb.org CGI endpoint.
///
/// Author: Paul Snow
/// Since: 0.0.0
abstract interface class IGnudbService {
  /// Executes `cddb query` for the given Disc ID and TOC.
  ///
  /// [frameOffsets] must be LBA frame offsets (including the 150-frame
  /// pregap) in declared track order. [totalSeconds] is the total disc
  /// length in seconds.
  Future<GnudbQueryResult> query({
    required String discId,
    required List<int> frameOffsets,
    required int totalSeconds,
  });

  /// Executes `cddb read` for the given category and Disc ID.
  ///
  /// Returns `null` when the server replies with a non-success status.
  Future<GnudbDisc?> read({
    required String category,
    required String discId,
  });
}
