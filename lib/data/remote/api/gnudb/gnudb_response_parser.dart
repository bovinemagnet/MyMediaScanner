/// Parses CDDB text responses returned by a GnuDB server.
///
/// The CDDB wire format is plain text: a status line (three-digit code
/// plus free-form message) optionally followed by a body terminated by a
/// line containing only `.`. Query responses emit a single line (200) or a
/// list of matches (210/211); read responses emit `KEY=VALUE` pairs.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_query_match.dart';

/// Sealed result type for `parseQuery`.
sealed class GnudbQueryResult {
  const GnudbQueryResult();
}

/// Response code 200 — a single exact match.
class GnudbQuerySingle extends GnudbQueryResult {
  const GnudbQuerySingle(this.match);
  final GnudbQueryMatch match;
}

/// Response code 210 or 211 — multiple matches to disambiguate between.
class GnudbQueryMulti extends GnudbQueryResult {
  const GnudbQueryMulti(this.matches);
  final List<GnudbQueryMatch> matches;
}

/// Response code 202 — no match for the supplied Disc ID.
class GnudbQueryNoMatch extends GnudbQueryResult {
  const GnudbQueryNoMatch();
}

/// Any other response code (401, 403, 5xx…) or malformed body.
class GnudbQueryError extends GnudbQueryResult {
  const GnudbQueryError({required this.code, required this.message});
  final int code;
  final String message;
}

/// Parser for CDDB/GnuDB text responses.
class GnudbResponseParser {
  const GnudbResponseParser._();

  static final RegExp _statusLine = RegExp(r'^(\d{3})\s*(.*)$');
  static final RegExp _matchLine =
      RegExp(r'^(\S+)\s+([0-9a-fA-F]{8})\s+(.*)$');

  /// Parses the body of a `cddb query` response.
  static GnudbQueryResult parseQuery(String body) {
    if (body.trim().isEmpty) {
      return const GnudbQueryError(
          code: 0, message: 'Empty response body');
    }

    final lines = body.split(RegExp(r'\r?\n'));
    final statusMatch = _statusLine.firstMatch(lines.first);
    if (statusMatch == null) {
      return GnudbQueryError(code: 0, message: 'Malformed status: ${lines.first}');
    }
    final code = int.parse(statusMatch.group(1)!);
    final message = statusMatch.group(2) ?? '';

    switch (code) {
      case 200:
        // The match is encoded on the status line itself: `200 cat disc title`.
        final rest = message;
        final m = _matchLine.firstMatch(rest);
        if (m == null) {
          return GnudbQueryError(
              code: 200,
              message: 'Could not parse 200 payload: $rest');
        }
        return GnudbQuerySingle(GnudbQueryMatch(
          category: m.group(1)!,
          discId: m.group(2)!.toLowerCase(),
          title: m.group(3)!.trim(),
        ));

      case 210:
      case 211:
        final matches = <GnudbQueryMatch>[];
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i];
          if (line.trim() == '.') break;
          if (line.trim().isEmpty) continue;
          final m = _matchLine.firstMatch(line);
          if (m != null) {
            matches.add(GnudbQueryMatch(
              category: m.group(1)!,
              discId: m.group(2)!.toLowerCase(),
              title: m.group(3)!.trim(),
            ));
          }
        }
        return GnudbQueryMulti(matches);

      case 202:
        return const GnudbQueryNoMatch();

      default:
        return GnudbQueryError(code: code, message: message);
    }
  }

  /// Parses the body of a `cddb read` response. Returns `null` when the
  /// status code is not a success (2xx).
  static GnudbDiscDto? parseDisc(String body) {
    final lines = body.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return null;

    final statusMatch = _statusLine.firstMatch(lines.first);
    if (statusMatch == null) return null;
    final code = int.parse(statusMatch.group(1)!);
    if (code ~/ 100 != 2) return null;

    // Pull discId from the status line where present: `210 cat discid ...`.
    String? discIdFromStatus;
    final statusParts = (statusMatch.group(2) ?? '').split(RegExp(r'\s+'));
    if (statusParts.length >= 2 &&
        RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(statusParts[1])) {
      discIdFromStatus = statusParts[1].toLowerCase();
    }

    final kv = <String, List<String>>{};
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim() == '.') break;
      if (line.startsWith('#') || line.trim().isEmpty) continue;

      final eq = line.indexOf('=');
      if (eq <= 0) continue;
      final key = line.substring(0, eq);
      final value = line.substring(eq + 1);
      (kv[key] ??= []).add(value);
    }

    String? joined(String key) {
      final parts = kv[key];
      if (parts == null || parts.isEmpty) return null;
      return parts.join('');
    }

    final discId = joined('DISCID')?.toLowerCase() ?? discIdFromStatus;
    if (discId == null) return null;

    final dtitle = joined('DTITLE') ?? '';
    String artist;
    String albumTitle;
    final slash = dtitle.indexOf(' / ');
    if (slash >= 0) {
      artist = dtitle.substring(0, slash).trim();
      albumTitle = dtitle.substring(slash + 3).trim();
    } else {
      artist = dtitle.trim();
      albumTitle = dtitle.trim();
    }

    final yearStr = joined('DYEAR')?.trim();
    int? year;
    if (yearStr != null && yearStr.isNotEmpty) {
      year = int.tryParse(yearStr);
    }

    final genre = joined('DGENRE')?.trim();

    final trackTitles = <String>[];
    for (var i = 0;; i++) {
      final title = joined('TTITLE$i');
      if (title == null) break;
      trackTitles.add(title);
    }

    final extTracks = <String>[];
    for (var i = 0; i < trackTitles.length; i++) {
      extTracks.add(joined('EXTT$i') ?? '');
    }

    return GnudbDiscDto(
      discId: discId,
      artist: artist,
      albumTitle: albumTitle,
      year: year,
      genre: (genre == null || genre.isEmpty) ? null : genre,
      trackTitles: trackTitles,
      extendedAlbum: joined('EXTD'),
      extendedTracks: extTracks,
    );
  }
}
