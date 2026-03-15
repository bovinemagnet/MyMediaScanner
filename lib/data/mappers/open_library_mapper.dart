import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
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
      genres: dto.subjects?.map((s) => s.name ?? '').where((s) => s.isNotEmpty).toList() ?? [],
      extraMetadata: {
        'authors': dto.authors?.map((a) => a.name).toList() ?? [],
        'isbn10': dto.isbn10?.firstOrNull,
        'isbn13': dto.isbn13?.firstOrNull,
        'page_count': dto.numberOfPages,
      },
      sourceApis: ['open_library'],
    );
  }
}
