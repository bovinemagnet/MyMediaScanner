/// HTTP client for the GnuDB CDDB server (gnudb.org).
///
/// Uses manual Dio calls because the wire format is plain text rather than
/// JSON. Enforces CDDB protocol conventions on every request:
///
/// * `hello=<user> <host> <client-name> <client-version>` identifies the
///   client to the server.
/// * `proto=6` requests UTF-8 responses; lower protocol levels return
///   legacy 8-bit encodings.
///
/// A 1.1-second rate limiter guards the public endpoint to keep within the
/// community service's courtesy limits.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limiter.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_response_parser.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';

/// Thin wrapper over the GnuDB CDDB CGI endpoint.
class GnudbApi {
  GnudbApi({
    Dio? dio,
    RateLimiter? rateLimiter,
    String user = ApiConstants.gnudbDefaultUser,
    String host = 'localhost',
  })  : _dio = dio ??
            DioFactory.createForPlainText(
              baseUrl: ApiConstants.gnudbBaseUrl,
              userAgent: ApiConstants.gnudbUserAgent,
            ),
        _rateLimiter = rateLimiter ??
            RateLimiter(minInterval: const Duration(milliseconds: 1100)),
        _user = user,
        _host = host;

  final Dio _dio;
  final RateLimiter _rateLimiter;
  final String _user;
  final String _host;

  String get _hello =>
      '$_user $_host ${ApiConstants.gnudbClientName} ${ApiConstants.gnudbClientVersion}';

  /// Executes `cddb query` for the given Disc ID and TOC.
  ///
  /// [frameOffsets] must be LBA frame offsets (including the 150-frame
  /// pregap) in declared track order. [totalSeconds] is the total disc
  /// length in seconds.
  Future<GnudbQueryResult> query({
    required String discId,
    required List<int> frameOffsets,
    required int totalSeconds,
  }) async {
    await _rateLimiter.throttle();
    final cmd = <String>[
      'cddb query',
      discId,
      frameOffsets.length.toString(),
      ...frameOffsets.map((f) => f.toString()),
      totalSeconds.toString(),
    ].join(' ');
    final response = await _dio.get<String>(
      ApiConstants.gnudbCgiPath,
      queryParameters: {
        'cmd': cmd,
        'hello': _hello,
        'proto': '6',
      },
    );
    return GnudbResponseParser.parseQuery(response.data ?? '');
  }

  /// Executes `cddb read` for the given category and Disc ID.
  ///
  /// Returns `null` when the server replies with a non-success status.
  Future<GnudbDiscDto?> read({
    required String category,
    required String discId,
  }) async {
    await _rateLimiter.throttle();
    final cmd = 'cddb read $category $discId';
    final response = await _dio.get<String>(
      ApiConstants.gnudbCgiPath,
      queryParameters: {
        'cmd': cmd,
        'hello': _hello,
        'proto': '6',
      },
    );
    return GnudbResponseParser.parseDisc(response.data ?? '');
  }
}
