import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';

part 'media_item.freezed.dart';

@freezed
sealed class MediaItem with _$MediaItem {
  const factory MediaItem({
    required String id,
    required String barcode,
    required String barcodeType,
    required MediaType mediaType,
    required String title,
    String? subtitle,
    String? description,
    String? coverUrl,
    int? year,
    String? publisher,
    String? format,
    @Default([]) List<String> genres,
    @Default({}) Map<String, dynamic> extraMetadata,
    @Default([]) List<String> sourceApis,
    double? userRating,
    String? userReview,
    double? criticScore,
    String? criticSource,
    @Default(OwnershipStatus.owned) OwnershipStatus ownershipStatus,
    ItemCondition? condition,
    double? pricePaid,
    int? acquiredAt,
    String? retailer,
    required int dateAdded,
    required int dateScanned,
    required int updatedAt,
    int? syncedAt,
    @Default(false) bool deleted,
    String? locationId,
    String? seriesId,
    int? seriesPosition,
  }) = _MediaItem;
}
