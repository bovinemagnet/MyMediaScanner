import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'metadata_result.freezed.dart';

@freezed
sealed class MetadataResult with _$MetadataResult {
  const factory MetadataResult({
    required String barcode,
    required String barcodeType,
    MediaType? mediaType,
    String? title,
    String? subtitle,
    String? description,
    String? coverUrl,
    int? year,
    String? publisher,
    String? format,
    @Default([]) List<String> genres,
    @Default({}) Map<String, dynamic> extraMetadata,
    @Default([]) List<String> sourceApis,
  }) = _MetadataResult;
}
