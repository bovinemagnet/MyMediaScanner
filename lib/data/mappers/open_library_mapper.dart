import 'package:mymediascanner/data/remote/api/open_library/models/open_library_search_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class OpenLibraryMapper {
  static MetadataResult fromBook(
    OpenLibraryBookDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.book,
      title: dto.title,
      coverUrl: dto.cover?.large ?? dto.cover?.medium,
      year: dto.year,
      publisher: dto.publishers?.firstOrNull?.name,
      genres:
          dto.subjects
              ?.map((s) => s.name ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      extraMetadata: {
        'authors': dto.authors?.map((a) => a.name).toList() ?? [],
        'isbn10': dto.isbn10?.firstOrNull,
        'isbn13': dto.isbn13?.firstOrNull,
        'page_count': dto.numberOfPages,
      },
      sourceApis: ['open_library'],
    );
  }

  /// Map a single [OpenLibrarySearchDocDto] from `/search.json` into a
  /// [MetadataResult]. Used when Open Library is the title-search fallback
  /// (e.g. Google Books returned 503).
  static MetadataResult fromSearchDoc(
    OpenLibrarySearchDocDto doc,
    String barcode,
    String barcodeType,
  ) {
    final isbns = doc.isbn ?? const <String>[];
    String? firstOfLength(int length) =>
        isbns.firstWhere((i) => i.length == length, orElse: () => '').isEmpty
        ? null
        : isbns.firstWhere((i) => i.length == length);

    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.book,
      title: doc.title,
      coverUrl: doc.coverUrl,
      year: doc.firstPublishYear,
      publisher: doc.publisher?.firstOrNull,
      genres: doc.subject?.take(10).toList() ?? const [],
      extraMetadata: {
        'authors': doc.authorName ?? const <String>[],
        'isbn10': firstOfLength(10),
        'isbn13': firstOfLength(13),
        'open_library_key': doc.key,
      },
      sourceApis: ['open_library'],
    );
  }

  /// Build a disambiguation candidate from a search doc.
  static MetadataCandidate toSearchCandidate(OpenLibrarySearchDocDto doc) {
    return MetadataCandidate(
      sourceApi: 'open_library',
      sourceId: doc.key ?? '',
      title: doc.title ?? '',
      subtitle: doc.authorName?.join(', '),
      coverUrl: doc.coverUrl,
      year: doc.firstPublishYear,
      mediaType: MediaType.book,
    );
  }
}
