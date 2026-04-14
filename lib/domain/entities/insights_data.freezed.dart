// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insights_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InsightsData {

// ── Collection overview ──────────────────────
 int get totalItems; Map<MediaType, int> get byMediaType; Map<int, int> get byYear; Map<String, int> get byGenre; double? get averageRating; int get ratedCount;// ── Growth timeline ──────────────────────────
/// Items added per calendar month: {2026-01: 5, 2026-02: 12, ...}
 Map<String, int> get monthlyGrowth;// ── Lending statistics ───────────────────────
 int get activeLoansCount; int get overdueCount; int get totalLoansAllTime;/// Borrower name → active loan count
 Map<String, int> get topBorrowers;/// Media item title → total times lent
 Map<String, int> get mostBorrowedItems;// ── Rip coverage ────────────────────────────
 int get totalRipAlbums; int get matchedRipAlbums; int get unmatchedRipAlbums; int get totalRipSizeBytes;/// Music items in collection that have a matching rip
 int get musicItemsWithRips;/// Total music items in collection
 int get totalMusicItems;// ── Collection value ────────────────────────
/// Sum of `pricePaid` over owned items, ignoring nulls. `null` when
/// no owned item has a recorded price.
 double? get totalValue;
/// Create a copy of InsightsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsightsDataCopyWith<InsightsData> get copyWith => _$InsightsDataCopyWithImpl<InsightsData>(this as InsightsData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsightsData&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&const DeepCollectionEquality().equals(other.byMediaType, byMediaType)&&const DeepCollectionEquality().equals(other.byYear, byYear)&&const DeepCollectionEquality().equals(other.byGenre, byGenre)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.ratedCount, ratedCount) || other.ratedCount == ratedCount)&&const DeepCollectionEquality().equals(other.monthlyGrowth, monthlyGrowth)&&(identical(other.activeLoansCount, activeLoansCount) || other.activeLoansCount == activeLoansCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.totalLoansAllTime, totalLoansAllTime) || other.totalLoansAllTime == totalLoansAllTime)&&const DeepCollectionEquality().equals(other.topBorrowers, topBorrowers)&&const DeepCollectionEquality().equals(other.mostBorrowedItems, mostBorrowedItems)&&(identical(other.totalRipAlbums, totalRipAlbums) || other.totalRipAlbums == totalRipAlbums)&&(identical(other.matchedRipAlbums, matchedRipAlbums) || other.matchedRipAlbums == matchedRipAlbums)&&(identical(other.unmatchedRipAlbums, unmatchedRipAlbums) || other.unmatchedRipAlbums == unmatchedRipAlbums)&&(identical(other.totalRipSizeBytes, totalRipSizeBytes) || other.totalRipSizeBytes == totalRipSizeBytes)&&(identical(other.musicItemsWithRips, musicItemsWithRips) || other.musicItemsWithRips == musicItemsWithRips)&&(identical(other.totalMusicItems, totalMusicItems) || other.totalMusicItems == totalMusicItems)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}


@override
int get hashCode => Object.hashAll([runtimeType,totalItems,const DeepCollectionEquality().hash(byMediaType),const DeepCollectionEquality().hash(byYear),const DeepCollectionEquality().hash(byGenre),averageRating,ratedCount,const DeepCollectionEquality().hash(monthlyGrowth),activeLoansCount,overdueCount,totalLoansAllTime,const DeepCollectionEquality().hash(topBorrowers),const DeepCollectionEquality().hash(mostBorrowedItems),totalRipAlbums,matchedRipAlbums,unmatchedRipAlbums,totalRipSizeBytes,musicItemsWithRips,totalMusicItems,totalValue]);

@override
String toString() {
  return 'InsightsData(totalItems: $totalItems, byMediaType: $byMediaType, byYear: $byYear, byGenre: $byGenre, averageRating: $averageRating, ratedCount: $ratedCount, monthlyGrowth: $monthlyGrowth, activeLoansCount: $activeLoansCount, overdueCount: $overdueCount, totalLoansAllTime: $totalLoansAllTime, topBorrowers: $topBorrowers, mostBorrowedItems: $mostBorrowedItems, totalRipAlbums: $totalRipAlbums, matchedRipAlbums: $matchedRipAlbums, unmatchedRipAlbums: $unmatchedRipAlbums, totalRipSizeBytes: $totalRipSizeBytes, musicItemsWithRips: $musicItemsWithRips, totalMusicItems: $totalMusicItems, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class $InsightsDataCopyWith<$Res>  {
  factory $InsightsDataCopyWith(InsightsData value, $Res Function(InsightsData) _then) = _$InsightsDataCopyWithImpl;
@useResult
$Res call({
 int totalItems, Map<MediaType, int> byMediaType, Map<int, int> byYear, Map<String, int> byGenre, double? averageRating, int ratedCount, Map<String, int> monthlyGrowth, int activeLoansCount, int overdueCount, int totalLoansAllTime, Map<String, int> topBorrowers, Map<String, int> mostBorrowedItems, int totalRipAlbums, int matchedRipAlbums, int unmatchedRipAlbums, int totalRipSizeBytes, int musicItemsWithRips, int totalMusicItems, double? totalValue
});




}
/// @nodoc
class _$InsightsDataCopyWithImpl<$Res>
    implements $InsightsDataCopyWith<$Res> {
  _$InsightsDataCopyWithImpl(this._self, this._then);

  final InsightsData _self;
  final $Res Function(InsightsData) _then;

/// Create a copy of InsightsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalItems = null,Object? byMediaType = null,Object? byYear = null,Object? byGenre = null,Object? averageRating = freezed,Object? ratedCount = null,Object? monthlyGrowth = null,Object? activeLoansCount = null,Object? overdueCount = null,Object? totalLoansAllTime = null,Object? topBorrowers = null,Object? mostBorrowedItems = null,Object? totalRipAlbums = null,Object? matchedRipAlbums = null,Object? unmatchedRipAlbums = null,Object? totalRipSizeBytes = null,Object? musicItemsWithRips = null,Object? totalMusicItems = null,Object? totalValue = freezed,}) {
  return _then(_self.copyWith(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,byMediaType: null == byMediaType ? _self.byMediaType : byMediaType // ignore: cast_nullable_to_non_nullable
as Map<MediaType, int>,byYear: null == byYear ? _self.byYear : byYear // ignore: cast_nullable_to_non_nullable
as Map<int, int>,byGenre: null == byGenre ? _self.byGenre : byGenre // ignore: cast_nullable_to_non_nullable
as Map<String, int>,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,ratedCount: null == ratedCount ? _self.ratedCount : ratedCount // ignore: cast_nullable_to_non_nullable
as int,monthlyGrowth: null == monthlyGrowth ? _self.monthlyGrowth : monthlyGrowth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,activeLoansCount: null == activeLoansCount ? _self.activeLoansCount : activeLoansCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,totalLoansAllTime: null == totalLoansAllTime ? _self.totalLoansAllTime : totalLoansAllTime // ignore: cast_nullable_to_non_nullable
as int,topBorrowers: null == topBorrowers ? _self.topBorrowers : topBorrowers // ignore: cast_nullable_to_non_nullable
as Map<String, int>,mostBorrowedItems: null == mostBorrowedItems ? _self.mostBorrowedItems : mostBorrowedItems // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalRipAlbums: null == totalRipAlbums ? _self.totalRipAlbums : totalRipAlbums // ignore: cast_nullable_to_non_nullable
as int,matchedRipAlbums: null == matchedRipAlbums ? _self.matchedRipAlbums : matchedRipAlbums // ignore: cast_nullable_to_non_nullable
as int,unmatchedRipAlbums: null == unmatchedRipAlbums ? _self.unmatchedRipAlbums : unmatchedRipAlbums // ignore: cast_nullable_to_non_nullable
as int,totalRipSizeBytes: null == totalRipSizeBytes ? _self.totalRipSizeBytes : totalRipSizeBytes // ignore: cast_nullable_to_non_nullable
as int,musicItemsWithRips: null == musicItemsWithRips ? _self.musicItemsWithRips : musicItemsWithRips // ignore: cast_nullable_to_non_nullable
as int,totalMusicItems: null == totalMusicItems ? _self.totalMusicItems : totalMusicItems // ignore: cast_nullable_to_non_nullable
as int,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [InsightsData].
extension InsightsDataPatterns on InsightsData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InsightsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InsightsData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InsightsData value)  $default,){
final _that = this;
switch (_that) {
case _InsightsData():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InsightsData value)?  $default,){
final _that = this;
switch (_that) {
case _InsightsData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalItems,  Map<MediaType, int> byMediaType,  Map<int, int> byYear,  Map<String, int> byGenre,  double? averageRating,  int ratedCount,  Map<String, int> monthlyGrowth,  int activeLoansCount,  int overdueCount,  int totalLoansAllTime,  Map<String, int> topBorrowers,  Map<String, int> mostBorrowedItems,  int totalRipAlbums,  int matchedRipAlbums,  int unmatchedRipAlbums,  int totalRipSizeBytes,  int musicItemsWithRips,  int totalMusicItems,  double? totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InsightsData() when $default != null:
return $default(_that.totalItems,_that.byMediaType,_that.byYear,_that.byGenre,_that.averageRating,_that.ratedCount,_that.monthlyGrowth,_that.activeLoansCount,_that.overdueCount,_that.totalLoansAllTime,_that.topBorrowers,_that.mostBorrowedItems,_that.totalRipAlbums,_that.matchedRipAlbums,_that.unmatchedRipAlbums,_that.totalRipSizeBytes,_that.musicItemsWithRips,_that.totalMusicItems,_that.totalValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalItems,  Map<MediaType, int> byMediaType,  Map<int, int> byYear,  Map<String, int> byGenre,  double? averageRating,  int ratedCount,  Map<String, int> monthlyGrowth,  int activeLoansCount,  int overdueCount,  int totalLoansAllTime,  Map<String, int> topBorrowers,  Map<String, int> mostBorrowedItems,  int totalRipAlbums,  int matchedRipAlbums,  int unmatchedRipAlbums,  int totalRipSizeBytes,  int musicItemsWithRips,  int totalMusicItems,  double? totalValue)  $default,) {final _that = this;
switch (_that) {
case _InsightsData():
return $default(_that.totalItems,_that.byMediaType,_that.byYear,_that.byGenre,_that.averageRating,_that.ratedCount,_that.monthlyGrowth,_that.activeLoansCount,_that.overdueCount,_that.totalLoansAllTime,_that.topBorrowers,_that.mostBorrowedItems,_that.totalRipAlbums,_that.matchedRipAlbums,_that.unmatchedRipAlbums,_that.totalRipSizeBytes,_that.musicItemsWithRips,_that.totalMusicItems,_that.totalValue);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalItems,  Map<MediaType, int> byMediaType,  Map<int, int> byYear,  Map<String, int> byGenre,  double? averageRating,  int ratedCount,  Map<String, int> monthlyGrowth,  int activeLoansCount,  int overdueCount,  int totalLoansAllTime,  Map<String, int> topBorrowers,  Map<String, int> mostBorrowedItems,  int totalRipAlbums,  int matchedRipAlbums,  int unmatchedRipAlbums,  int totalRipSizeBytes,  int musicItemsWithRips,  int totalMusicItems,  double? totalValue)?  $default,) {final _that = this;
switch (_that) {
case _InsightsData() when $default != null:
return $default(_that.totalItems,_that.byMediaType,_that.byYear,_that.byGenre,_that.averageRating,_that.ratedCount,_that.monthlyGrowth,_that.activeLoansCount,_that.overdueCount,_that.totalLoansAllTime,_that.topBorrowers,_that.mostBorrowedItems,_that.totalRipAlbums,_that.matchedRipAlbums,_that.unmatchedRipAlbums,_that.totalRipSizeBytes,_that.musicItemsWithRips,_that.totalMusicItems,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc


class _InsightsData implements InsightsData {
  const _InsightsData({required this.totalItems, required final  Map<MediaType, int> byMediaType, required final  Map<int, int> byYear, required final  Map<String, int> byGenre, required this.averageRating, required this.ratedCount, required final  Map<String, int> monthlyGrowth, required this.activeLoansCount, required this.overdueCount, required this.totalLoansAllTime, required final  Map<String, int> topBorrowers, required final  Map<String, int> mostBorrowedItems, required this.totalRipAlbums, required this.matchedRipAlbums, required this.unmatchedRipAlbums, required this.totalRipSizeBytes, required this.musicItemsWithRips, required this.totalMusicItems, this.totalValue}): _byMediaType = byMediaType,_byYear = byYear,_byGenre = byGenre,_monthlyGrowth = monthlyGrowth,_topBorrowers = topBorrowers,_mostBorrowedItems = mostBorrowedItems;
  

// ── Collection overview ──────────────────────
@override final  int totalItems;
 final  Map<MediaType, int> _byMediaType;
@override Map<MediaType, int> get byMediaType {
  if (_byMediaType is EqualUnmodifiableMapView) return _byMediaType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byMediaType);
}

 final  Map<int, int> _byYear;
@override Map<int, int> get byYear {
  if (_byYear is EqualUnmodifiableMapView) return _byYear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byYear);
}

 final  Map<String, int> _byGenre;
@override Map<String, int> get byGenre {
  if (_byGenre is EqualUnmodifiableMapView) return _byGenre;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byGenre);
}

@override final  double? averageRating;
@override final  int ratedCount;
// ── Growth timeline ──────────────────────────
/// Items added per calendar month: {2026-01: 5, 2026-02: 12, ...}
 final  Map<String, int> _monthlyGrowth;
// ── Growth timeline ──────────────────────────
/// Items added per calendar month: {2026-01: 5, 2026-02: 12, ...}
@override Map<String, int> get monthlyGrowth {
  if (_monthlyGrowth is EqualUnmodifiableMapView) return _monthlyGrowth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monthlyGrowth);
}

// ── Lending statistics ───────────────────────
@override final  int activeLoansCount;
@override final  int overdueCount;
@override final  int totalLoansAllTime;
/// Borrower name → active loan count
 final  Map<String, int> _topBorrowers;
/// Borrower name → active loan count
@override Map<String, int> get topBorrowers {
  if (_topBorrowers is EqualUnmodifiableMapView) return _topBorrowers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_topBorrowers);
}

/// Media item title → total times lent
 final  Map<String, int> _mostBorrowedItems;
/// Media item title → total times lent
@override Map<String, int> get mostBorrowedItems {
  if (_mostBorrowedItems is EqualUnmodifiableMapView) return _mostBorrowedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mostBorrowedItems);
}

// ── Rip coverage ────────────────────────────
@override final  int totalRipAlbums;
@override final  int matchedRipAlbums;
@override final  int unmatchedRipAlbums;
@override final  int totalRipSizeBytes;
/// Music items in collection that have a matching rip
@override final  int musicItemsWithRips;
/// Total music items in collection
@override final  int totalMusicItems;
// ── Collection value ────────────────────────
/// Sum of `pricePaid` over owned items, ignoring nulls. `null` when
/// no owned item has a recorded price.
@override final  double? totalValue;

/// Create a copy of InsightsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsightsDataCopyWith<_InsightsData> get copyWith => __$InsightsDataCopyWithImpl<_InsightsData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsightsData&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&const DeepCollectionEquality().equals(other._byMediaType, _byMediaType)&&const DeepCollectionEquality().equals(other._byYear, _byYear)&&const DeepCollectionEquality().equals(other._byGenre, _byGenre)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.ratedCount, ratedCount) || other.ratedCount == ratedCount)&&const DeepCollectionEquality().equals(other._monthlyGrowth, _monthlyGrowth)&&(identical(other.activeLoansCount, activeLoansCount) || other.activeLoansCount == activeLoansCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.totalLoansAllTime, totalLoansAllTime) || other.totalLoansAllTime == totalLoansAllTime)&&const DeepCollectionEquality().equals(other._topBorrowers, _topBorrowers)&&const DeepCollectionEquality().equals(other._mostBorrowedItems, _mostBorrowedItems)&&(identical(other.totalRipAlbums, totalRipAlbums) || other.totalRipAlbums == totalRipAlbums)&&(identical(other.matchedRipAlbums, matchedRipAlbums) || other.matchedRipAlbums == matchedRipAlbums)&&(identical(other.unmatchedRipAlbums, unmatchedRipAlbums) || other.unmatchedRipAlbums == unmatchedRipAlbums)&&(identical(other.totalRipSizeBytes, totalRipSizeBytes) || other.totalRipSizeBytes == totalRipSizeBytes)&&(identical(other.musicItemsWithRips, musicItemsWithRips) || other.musicItemsWithRips == musicItemsWithRips)&&(identical(other.totalMusicItems, totalMusicItems) || other.totalMusicItems == totalMusicItems)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}


@override
int get hashCode => Object.hashAll([runtimeType,totalItems,const DeepCollectionEquality().hash(_byMediaType),const DeepCollectionEquality().hash(_byYear),const DeepCollectionEquality().hash(_byGenre),averageRating,ratedCount,const DeepCollectionEquality().hash(_monthlyGrowth),activeLoansCount,overdueCount,totalLoansAllTime,const DeepCollectionEquality().hash(_topBorrowers),const DeepCollectionEquality().hash(_mostBorrowedItems),totalRipAlbums,matchedRipAlbums,unmatchedRipAlbums,totalRipSizeBytes,musicItemsWithRips,totalMusicItems,totalValue]);

@override
String toString() {
  return 'InsightsData(totalItems: $totalItems, byMediaType: $byMediaType, byYear: $byYear, byGenre: $byGenre, averageRating: $averageRating, ratedCount: $ratedCount, monthlyGrowth: $monthlyGrowth, activeLoansCount: $activeLoansCount, overdueCount: $overdueCount, totalLoansAllTime: $totalLoansAllTime, topBorrowers: $topBorrowers, mostBorrowedItems: $mostBorrowedItems, totalRipAlbums: $totalRipAlbums, matchedRipAlbums: $matchedRipAlbums, unmatchedRipAlbums: $unmatchedRipAlbums, totalRipSizeBytes: $totalRipSizeBytes, musicItemsWithRips: $musicItemsWithRips, totalMusicItems: $totalMusicItems, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$InsightsDataCopyWith<$Res> implements $InsightsDataCopyWith<$Res> {
  factory _$InsightsDataCopyWith(_InsightsData value, $Res Function(_InsightsData) _then) = __$InsightsDataCopyWithImpl;
@override @useResult
$Res call({
 int totalItems, Map<MediaType, int> byMediaType, Map<int, int> byYear, Map<String, int> byGenre, double? averageRating, int ratedCount, Map<String, int> monthlyGrowth, int activeLoansCount, int overdueCount, int totalLoansAllTime, Map<String, int> topBorrowers, Map<String, int> mostBorrowedItems, int totalRipAlbums, int matchedRipAlbums, int unmatchedRipAlbums, int totalRipSizeBytes, int musicItemsWithRips, int totalMusicItems, double? totalValue
});




}
/// @nodoc
class __$InsightsDataCopyWithImpl<$Res>
    implements _$InsightsDataCopyWith<$Res> {
  __$InsightsDataCopyWithImpl(this._self, this._then);

  final _InsightsData _self;
  final $Res Function(_InsightsData) _then;

/// Create a copy of InsightsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = null,Object? byMediaType = null,Object? byYear = null,Object? byGenre = null,Object? averageRating = freezed,Object? ratedCount = null,Object? monthlyGrowth = null,Object? activeLoansCount = null,Object? overdueCount = null,Object? totalLoansAllTime = null,Object? topBorrowers = null,Object? mostBorrowedItems = null,Object? totalRipAlbums = null,Object? matchedRipAlbums = null,Object? unmatchedRipAlbums = null,Object? totalRipSizeBytes = null,Object? musicItemsWithRips = null,Object? totalMusicItems = null,Object? totalValue = freezed,}) {
  return _then(_InsightsData(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,byMediaType: null == byMediaType ? _self._byMediaType : byMediaType // ignore: cast_nullable_to_non_nullable
as Map<MediaType, int>,byYear: null == byYear ? _self._byYear : byYear // ignore: cast_nullable_to_non_nullable
as Map<int, int>,byGenre: null == byGenre ? _self._byGenre : byGenre // ignore: cast_nullable_to_non_nullable
as Map<String, int>,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,ratedCount: null == ratedCount ? _self.ratedCount : ratedCount // ignore: cast_nullable_to_non_nullable
as int,monthlyGrowth: null == monthlyGrowth ? _self._monthlyGrowth : monthlyGrowth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,activeLoansCount: null == activeLoansCount ? _self.activeLoansCount : activeLoansCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,totalLoansAllTime: null == totalLoansAllTime ? _self.totalLoansAllTime : totalLoansAllTime // ignore: cast_nullable_to_non_nullable
as int,topBorrowers: null == topBorrowers ? _self._topBorrowers : topBorrowers // ignore: cast_nullable_to_non_nullable
as Map<String, int>,mostBorrowedItems: null == mostBorrowedItems ? _self._mostBorrowedItems : mostBorrowedItems // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalRipAlbums: null == totalRipAlbums ? _self.totalRipAlbums : totalRipAlbums // ignore: cast_nullable_to_non_nullable
as int,matchedRipAlbums: null == matchedRipAlbums ? _self.matchedRipAlbums : matchedRipAlbums // ignore: cast_nullable_to_non_nullable
as int,unmatchedRipAlbums: null == unmatchedRipAlbums ? _self.unmatchedRipAlbums : unmatchedRipAlbums // ignore: cast_nullable_to_non_nullable
as int,totalRipSizeBytes: null == totalRipSizeBytes ? _self.totalRipSizeBytes : totalRipSizeBytes // ignore: cast_nullable_to_non_nullable
as int,musicItemsWithRips: null == musicItemsWithRips ? _self.musicItemsWithRips : musicItemsWithRips // ignore: cast_nullable_to_non_nullable
as int,totalMusicItems: null == totalMusicItems ? _self.totalMusicItems : totalMusicItems // ignore: cast_nullable_to_non_nullable
as int,totalValue: freezed == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
