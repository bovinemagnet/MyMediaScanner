import 'package:freezed_annotation/freezed_annotation.dart';

part 'rip_track.freezed.dart';

@freezed
sealed class RipTrack with _$RipTrack {
  const factory RipTrack({
    required String id,
    required String ripAlbumId,
    @Default(1) int discNumber,
    required int trackNumber,
    String? title,
    required String filePath,
    int? durationMs,
    required int fileSizeBytes,
    required int updatedAt,
    // Audio quality analysis fields (Phase B)
    String? accurateRipStatus,
    int? accurateRipConfidence,
    String? accurateRipCrcV1,
    String? accurateRipCrcV2,
    double? peakLevel,
    double? trackQuality,
    String? copyCrc,
    int? clickCount,
    String? ripLogSource,
    int? qualityCheckedAt,
  }) = _RipTrack;
}
