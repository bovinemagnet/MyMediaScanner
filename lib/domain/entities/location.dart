import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

/// A node in the physical-location hierarchy (Room → Shelf → Box → Slot).
///
/// `parentId` is nullable: top-level nodes (typically Rooms) have no parent.
@freezed
sealed class Location with _$Location {
  const factory Location({
    required String id,
    String? parentId,
    required String name,
    @Default(0) int sortOrder,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Location;
}
