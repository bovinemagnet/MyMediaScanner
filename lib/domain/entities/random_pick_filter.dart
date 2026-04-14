// Filter describing constraints for the random pick usecase.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'random_pick_filter.freezed.dart';

@freezed
sealed class RandomPickFilter with _$RandomPickFilter {
  const factory RandomPickFilter({
    String? shelfId,
    MediaType? mediaType,
    String? genre,
    int? maxRuntimeMinutes,
    int? maxPageCount,
    @Default(false) bool unratedOnly,
  }) = _RandomPickFilter;
}
