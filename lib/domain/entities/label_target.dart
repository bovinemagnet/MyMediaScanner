import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_target.freezed.dart';

/// A single label to be printed. The [qrPayload] is the stable identifier
/// encoded in the QR code (e.g. `item:abc-123` or `location:xyz-456`) and
/// is distinct from the human-readable [title] / [subtitle].
@freezed
sealed class LabelTarget with _$LabelTarget {
  const factory LabelTarget({
    required String qrPayload,
    required String title,
    String? subtitle,
  }) = _LabelTarget;

  /// Canonical QR payload for a media item: `item:<uuid>`.
  static String itemPayload(String id) => 'item:$id';

  /// Canonical QR payload for a location: `location:<uuid>`.
  static String locationPayload(String id) => 'location:$id';
}
