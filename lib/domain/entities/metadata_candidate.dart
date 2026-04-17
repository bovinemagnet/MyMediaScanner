import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'metadata_candidate.freezed.dart';

@freezed
sealed class MetadataCandidate with _$MetadataCandidate {
  const factory MetadataCandidate({
    required String sourceApi,
    required String sourceId,
    required String title,
    String? subtitle,
    String? coverUrl,
    int? year,
    String? format,
    MediaType? mediaType,
    // Music-specific disambiguation helpers (optional).
    String? country,
    String? label,
    String? catalogueNumber,
    int? trackCount,
    String? status,
    String? packaging,
  }) = _MetadataCandidate;
}
