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
    int? popCount,
    int? clippingCount,
    int? dropoutCount,
    double? defectConfidence,
    String? ripLogSource,
    int? qualityCheckedAt,
  }) = _RipTrack;
}

extension RipTrackDefects on RipTrack {
  /// Sum of every recorded defect-type count, or 0 if no detector run has
  /// happened yet. UI predicates that previously asked `clickCount > 0`
  /// should consult this instead so pops, clipping, and dropouts also
  /// trigger the warning state.
  int get totalDefects =>
      (clickCount ?? 0) +
      (popCount ?? 0) +
      (clippingCount ?? 0) +
      (dropoutCount ?? 0);
}
