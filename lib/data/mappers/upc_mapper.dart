import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class UpcMapper {
  static MetadataResult fromItem(
    UpcItemDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: _guessMediaType(dto.category),
      title: dto.title,
      description: dto.description,
      coverUrl: dto.primaryImageUrl,
      publisher: dto.brand,
      sourceApis: ['upcitemdb'],
    );
  }

  static MetadataCandidate toCandidate(UpcItemDto dto, String barcode) {
    return MetadataCandidate(
      sourceApi: 'upcitemdb',
      sourceId: dto.ean ?? barcode,
      title: dto.title ?? '',
      coverUrl: dto.primaryImageUrl,
      mediaType: _guessMediaType(dto.category),
    );
  }

  static MediaType _guessMediaType(String? category) {
    if (category == null) return MediaType.unknown;
    final lower = category.toLowerCase();
    if (lower.contains('book')) return MediaType.book;
    if (lower.contains('music') || lower.contains('cd') || lower.contains('vinyl')) {
      return MediaType.music;
    }
    if (lower.contains('game')) return MediaType.game;
    if (lower.contains('movie') || lower.contains('dvd') ||
        lower.contains('blu-ray') || lower.contains('video')) {
      return MediaType.film;
    }
    return MediaType.unknown;
  }
}
