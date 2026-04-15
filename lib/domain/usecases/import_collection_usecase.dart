import 'package:mymediascanner/data/importers/discogs_csv_parser.dart';
import 'package:mymediascanner/data/importers/goodreads_csv_parser.dart';
import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/data/importers/letterboxd_csv_parser.dart';
import 'package:mymediascanner/data/importers/trakt_json_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

/// Orchestrates the import pipeline: parse → dedup check → enrich → save.
///
/// Enrichment uses the existing [IMetadataRepository]. Source-specific
/// identifiers drive routing:
///   - ISBN (Goodreads)        → [IMetadataRepository.lookupBarcode] (auto-detects ISBN)
///   - IMDb ID (Trakt)         → [IMetadataRepository.lookupBarcode] (auto-detects imdbId)
///   - Title + year (Letterboxd, Discogs, fallback) → [IMetadataRepository.searchByTitle]
///
/// Rate-limited with a configurable delay between lookups to respect
/// third-party API quotas.
class ImportCollectionUseCase {
  ImportCollectionUseCase({
    required IMetadataRepository metadataRepository,
    required IMediaItemRepository mediaItemRepository,
    required SaveMediaItemUseCase saveMediaItem,
    Duration lookupDelay = const Duration(milliseconds: 250),
  })  : _metadata = metadataRepository,
        _media = mediaItemRepository,
        _save = saveMediaItem,
        _delay = lookupDelay;

  final IMetadataRepository _metadata;
  final IMediaItemRepository _media;
  final SaveMediaItemUseCase _save;
  final Duration _delay;

  /// Pick the parser that matches [source]. Exposed for testability.
  static ImportParser parserFor(ImportSource source) => switch (source) {
        ImportSource.goodreads => const GoodreadsCsvParser(),
        ImportSource.discogs => const DiscogsCsvParser(),
        ImportSource.letterboxd => const LetterboxdCsvParser(),
        ImportSource.trakt => const TraktJsonParser(),
      };

  /// Parse raw file [content] using the parser for [source].
  List<ImportRow> parse(ImportSource source, String content) {
    return parserFor(source).parse(content);
  }

  /// Enrich each row by calling the metadata pipeline. Emits rows one at a
  /// time so the UI can show incremental progress.
  Stream<ImportRow> enrich(List<ImportRow> rows) async* {
    for (final original in rows) {
      var row = original;
      try {
        // Dedup: ISBN / IMDb ID rows can be checked directly against
        // media_items.barcode.
        final dedupKey = row.isbn ?? row.imdbId;
        if (dedupKey != null &&
            await _media.barcodeExists(dedupKey)) {
          yield row.copyWith(status: ImportRowStatus.duplicate);
          continue;
        }

        final metadata = await _lookup(row);
        if (metadata == null) {
          yield row.copyWith(status: ImportRowStatus.notFound);
        } else {
          yield row.copyWith(
            status: ImportRowStatus.enriched,
            enriched: metadata,
          );
        }
      } on Exception catch (e) {
        yield row.copyWith(
          status: ImportRowStatus.error,
          errorMessage: e.toString(),
        );
      }
      if (_delay > Duration.zero) {
        await Future<void>.delayed(_delay);
      }
    }
  }

  Future<MetadataResult?> _lookup(ImportRow row) async {
    // 1. ISBN or IMDb ID: barcode-style lookup
    final directKey = row.isbn ?? row.imdbId;
    if (directKey != null) {
      final result = await _metadata.lookupBarcode(
        directKey,
        typeHint: row.mediaType,
      );
      final direct = _firstMetadata(result);
      if (direct != null) return direct;
    }

    // 2. Title + year search fallback
    final title = row.rawTitle;
    if (title == null || title.isEmpty) return null;

    // Use a synthetic barcode so the cache does not collide with real scans.
    final syntheticBarcode =
        'import:${row.source.name}:${row.sourceRowId}';
    final searchResult = await _metadata.searchByTitle(
      title,
      syntheticBarcode,
      'IMPORT',
      typeHint: row.mediaType,
    );
    return _firstMetadata(searchResult);
  }

  MetadataResult? _firstMetadata(ScanResult r) => switch (r) {
        SingleScanResult(:final metadata) => metadata,
        // For a multi-match we currently take no metadata — the user will
        // have to disambiguate manually after save. Future: surface
        // candidates in the import preview.
        MultiMatchScanResult() => null,
        NotFoundScanResult() => null,
      };

  /// Save every [rows] entry where `accepted` is true and `enriched` is
  /// non-null. Returns the count of items actually saved.
  Future<int> saveAccepted(List<ImportRow> rows) async {
    var count = 0;
    for (final row in rows) {
      if (!row.accepted) continue;
      final metadata = row.enriched;
      if (metadata == null) continue;
      final MediaItem _ = await _save.execute(metadata);
      count++;
    }
    return count;
  }
}
