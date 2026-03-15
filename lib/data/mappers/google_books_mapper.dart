import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class GoogleBooksMapper {
  static MetadataResult fromVolume(
    GoogleBooksVolumeDto dto,
    String barcode,
    String barcodeType,
  ) {
    final info = dto.volumeInfo;
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.book,
      title: info?.title,
      subtitle: info?.subtitle,
      description: info?.description,
      coverUrl: info?.imageLinks?.thumbnail,
      year: info?.year,
      publisher: info?.publisher,
      genres: info?.categories ?? [],
      extraMetadata: {
        'google_books_id': dto.id,
        'authors': info?.authors ?? [],
        'isbn10': info?.isbn10,
        'isbn13': info?.isbn13,
        'page_count': info?.pageCount,
      },
      sourceApis: ['google_books'],
      criticScore: info?.averageRating != null
          ? info!.averageRating! * 2
          : null,
      criticSource: info?.averageRating != null
          ? 'Google Books'
          : null,
    );
  }
}
