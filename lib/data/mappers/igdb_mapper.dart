import 'package:mymediascanner/data/remote/api/igdb/models/igdb_game_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

/// Maps IGDB game DTOs onto the app's domain metadata types.
abstract final class IgdbMapper {
  /// Build a [MetadataResult] from a single IGDB game.
  ///
  /// - `title` ← `name`
  /// - `subtitle` ← first platform name (chip UI lets the user change it)
  /// - `description` ← `summary`
  /// - `coverUrl` ← `cover.url` upgraded from `t_thumb` to `t_cover_big`
  ///   and scheme-fixed to `https:`
  /// - `year` ← derived from `first_release_date` (UTC)
  /// - `publisher` ← first involved company flagged as publisher
  /// - `genres` ← `genres[].name`
  /// - `criticScore` ← `aggregated_rating`, falling back to `rating`
  /// - `criticSource` ← `'IGDB'` when a score exists
  /// - `extraMetadata['developer']` ← first involved company flagged as developer
  /// - `extraMetadata['platforms']` ← full platform-name list
  /// - `extraMetadata['igdb_id']` ← numeric IGDB id
  static MetadataResult fromGame(
    IgdbGameDto dto,
    String barcode,
    String barcodeType,
  ) {
    final platformNames = dto.platforms
            ?.map((p) => p.name)
            .whereType<String>()
            .toList() ??
        const <String>[];

    final developer = _findCompany(dto.involvedCompanies, developer: true);
    final publisher = _findCompany(dto.involvedCompanies, publisher: true);
    final score = dto.aggregatedRating ?? dto.rating;

    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.game,
      title: dto.name,
      subtitle: platformNames.isNotEmpty ? platformNames.first : null,
      description: dto.summary,
      coverUrl: _coverUrl(dto.cover?.url),
      year: _releaseYear(dto.firstReleaseDate),
      publisher: publisher,
      genres: dto.genres?.map((g) => g.name).whereType<String>().toList() ??
          const <String>[],
      extraMetadata: {
        'igdb_id': ?dto.id,
        'developer': ?developer,
        if (platformNames.isNotEmpty) 'platforms': platformNames,
      },
      sourceApis: const ['igdb'],
      criticScore: score,
      criticSource: score != null ? 'IGDB' : null,
    );
  }

  /// Build a [MetadataCandidate] from an IGDB search-result game for the
  /// multi-match disambiguation sheet.
  static MetadataCandidate toCandidate(IgdbGameDto dto) {
    final platform = dto.platforms
        ?.map((p) => p.name)
        .whereType<String>()
        .firstOrNull;
    return MetadataCandidate(
      sourceApi: 'igdb',
      sourceId: dto.id?.toString() ?? '',
      title: dto.name ?? '',
      subtitle: platform,
      coverUrl: _coverUrl(dto.cover?.url),
      year: _releaseYear(dto.firstReleaseDate),
      mediaType: MediaType.game,
    );
  }

  static String? _findCompany(
    List<IgdbInvolvedCompanyDto>? companies, {
    bool developer = false,
    bool publisher = false,
  }) {
    if (companies == null || companies.isEmpty) return null;
    for (final entry in companies) {
      if (developer && entry.developer == true) {
        return entry.company?.name;
      }
      if (publisher && entry.publisher == true) {
        return entry.company?.name;
      }
    }
    return null;
  }

  /// IGDB cover URLs come back as scheme-less `//images.igdb.com/.../t_thumb/<hash>.jpg`.
  /// Swap to the bigger `t_cover_big` size and add an `https:` scheme.
  static String? _coverUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final upgraded = raw.replaceFirst('t_thumb', 't_cover_big');
    if (upgraded.startsWith('//')) return 'https:$upgraded';
    return upgraded;
  }

  static int? _releaseYear(int? unixSeconds) {
    if (unixSeconds == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    );
    return dt.year;
  }
}
