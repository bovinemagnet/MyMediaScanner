import 'dart:convert';

import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Parser for Trakt JSON exports (watched_movies.json, watched_shows.json,
/// or history.json). Expects a JSON array where each element wraps either
/// a `movie` or `show` object with a nested `ids` block.
class TraktJsonParser implements ImportParser {
  const TraktJsonParser();

  @override
  List<ImportRow> parse(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return const [];

    final dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      rethrow;
    }

    if (decoded is! List) {
      throw const FormatException('Expected a JSON array at root');
    }

    final rows = <ImportRow>[];
    for (var i = 0; i < decoded.length; i++) {
      final entry = decoded[i];
      if (entry is! Map<String, dynamic>) continue;

      Map<String, dynamic>? wrapper;
      MediaType mediaType;
      if (entry['movie'] is Map<String, dynamic>) {
        wrapper = entry['movie'] as Map<String, dynamic>;
        mediaType = MediaType.film;
      } else if (entry['show'] is Map<String, dynamic>) {
        wrapper = entry['show'] as Map<String, dynamic>;
        mediaType = MediaType.tv;
      } else {
        continue;
      }

      final title = wrapper['title']?.toString();
      if (title == null || title.isEmpty) continue;

      final year = wrapper['year'] is int
          ? wrapper['year'] as int
          : int.tryParse('${wrapper['year']}');

      final ids = wrapper['ids'] as Map<String, dynamic>?;
      final imdb = ids?['imdb']?.toString();
      final tmdb = ids?['tmdb']?.toString();
      final traktId = ids?['trakt']?.toString();

      rows.add(ImportRow(
        sourceRowId: traktId != null ? 'trakt-$traktId' : 'trakt-$i',
        source: ImportSource.trakt,
        mediaType: mediaType,
        rawTitle: title,
        rawYear: year,
        imdbId: (imdb != null && imdb.isNotEmpty) ? imdb : null,
        rawFields: {
          if (tmdb != null && tmdb.isNotEmpty) 'tmdb_id': tmdb,
          if (entry['last_watched_at'] != null)
            'last_watched_at': entry['last_watched_at'].toString(),
        },
      ));
    }
    return rows;
  }
}
