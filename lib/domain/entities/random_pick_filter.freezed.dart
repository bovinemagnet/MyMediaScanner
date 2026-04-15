// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'random_pick_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RandomPickFilter {

 String? get shelfId; MediaType? get mediaType; String? get genre; int? get maxRuntimeMinutes; int? get maxPageCount; bool get unratedOnly;
/// Create a copy of RandomPickFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RandomPickFilterCopyWith<RandomPickFilter> get copyWith => _$RandomPickFilterCopyWithImpl<RandomPickFilter>(this as RandomPickFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RandomPickFilter&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.maxRuntimeMinutes, maxRuntimeMinutes) || other.maxRuntimeMinutes == maxRuntimeMinutes)&&(identical(other.maxPageCount, maxPageCount) || other.maxPageCount == maxPageCount)&&(identical(other.unratedOnly, unratedOnly) || other.unratedOnly == unratedOnly));
}


@override
int get hashCode => Object.hash(runtimeType,shelfId,mediaType,genre,maxRuntimeMinutes,maxPageCount,unratedOnly);

@override
String toString() {
  return 'RandomPickFilter(shelfId: $shelfId, mediaType: $mediaType, genre: $genre, maxRuntimeMinutes: $maxRuntimeMinutes, maxPageCount: $maxPageCount, unratedOnly: $unratedOnly)';
}


}

/// @nodoc
abstract mixin class $RandomPickFilterCopyWith<$Res>  {
  factory $RandomPickFilterCopyWith(RandomPickFilter value, $Res Function(RandomPickFilter) _then) = _$RandomPickFilterCopyWithImpl;
@useResult
$Res call({
 String? shelfId, MediaType? mediaType, String? genre, int? maxRuntimeMinutes, int? maxPageCount, bool unratedOnly
});




}
/// @nodoc
class _$RandomPickFilterCopyWithImpl<$Res>
    implements $RandomPickFilterCopyWith<$Res> {
  _$RandomPickFilterCopyWithImpl(this._self, this._then);

  final RandomPickFilter _self;
  final $Res Function(RandomPickFilter) _then;

/// Create a copy of RandomPickFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shelfId = freezed,Object? mediaType = freezed,Object? genre = freezed,Object? maxRuntimeMinutes = freezed,Object? maxPageCount = freezed,Object? unratedOnly = null,}) {
  return _then(_self.copyWith(
shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,maxRuntimeMinutes: freezed == maxRuntimeMinutes ? _self.maxRuntimeMinutes : maxRuntimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,maxPageCount: freezed == maxPageCount ? _self.maxPageCount : maxPageCount // ignore: cast_nullable_to_non_nullable
as int?,unratedOnly: null == unratedOnly ? _self.unratedOnly : unratedOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RandomPickFilter].
extension RandomPickFilterPatterns on RandomPickFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RandomPickFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RandomPickFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RandomPickFilter value)  $default,){
final _that = this;
switch (_that) {
case _RandomPickFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RandomPickFilter value)?  $default,){
final _that = this;
switch (_that) {
case _RandomPickFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? shelfId,  MediaType? mediaType,  String? genre,  int? maxRuntimeMinutes,  int? maxPageCount,  bool unratedOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RandomPickFilter() when $default != null:
return $default(_that.shelfId,_that.mediaType,_that.genre,_that.maxRuntimeMinutes,_that.maxPageCount,_that.unratedOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? shelfId,  MediaType? mediaType,  String? genre,  int? maxRuntimeMinutes,  int? maxPageCount,  bool unratedOnly)  $default,) {final _that = this;
switch (_that) {
case _RandomPickFilter():
return $default(_that.shelfId,_that.mediaType,_that.genre,_that.maxRuntimeMinutes,_that.maxPageCount,_that.unratedOnly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? shelfId,  MediaType? mediaType,  String? genre,  int? maxRuntimeMinutes,  int? maxPageCount,  bool unratedOnly)?  $default,) {final _that = this;
switch (_that) {
case _RandomPickFilter() when $default != null:
return $default(_that.shelfId,_that.mediaType,_that.genre,_that.maxRuntimeMinutes,_that.maxPageCount,_that.unratedOnly);case _:
  return null;

}
}

}

/// @nodoc


class _RandomPickFilter implements RandomPickFilter {
  const _RandomPickFilter({this.shelfId, this.mediaType, this.genre, this.maxRuntimeMinutes, this.maxPageCount, this.unratedOnly = false});
  

@override final  String? shelfId;
@override final  MediaType? mediaType;
@override final  String? genre;
@override final  int? maxRuntimeMinutes;
@override final  int? maxPageCount;
@override@JsonKey() final  bool unratedOnly;

/// Create a copy of RandomPickFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RandomPickFilterCopyWith<_RandomPickFilter> get copyWith => __$RandomPickFilterCopyWithImpl<_RandomPickFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RandomPickFilter&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.maxRuntimeMinutes, maxRuntimeMinutes) || other.maxRuntimeMinutes == maxRuntimeMinutes)&&(identical(other.maxPageCount, maxPageCount) || other.maxPageCount == maxPageCount)&&(identical(other.unratedOnly, unratedOnly) || other.unratedOnly == unratedOnly));
}


@override
int get hashCode => Object.hash(runtimeType,shelfId,mediaType,genre,maxRuntimeMinutes,maxPageCount,unratedOnly);

@override
String toString() {
  return 'RandomPickFilter(shelfId: $shelfId, mediaType: $mediaType, genre: $genre, maxRuntimeMinutes: $maxRuntimeMinutes, maxPageCount: $maxPageCount, unratedOnly: $unratedOnly)';
}


}

/// @nodoc
abstract mixin class _$RandomPickFilterCopyWith<$Res> implements $RandomPickFilterCopyWith<$Res> {
  factory _$RandomPickFilterCopyWith(_RandomPickFilter value, $Res Function(_RandomPickFilter) _then) = __$RandomPickFilterCopyWithImpl;
@override @useResult
$Res call({
 String? shelfId, MediaType? mediaType, String? genre, int? maxRuntimeMinutes, int? maxPageCount, bool unratedOnly
});




}
/// @nodoc
class __$RandomPickFilterCopyWithImpl<$Res>
    implements _$RandomPickFilterCopyWith<$Res> {
  __$RandomPickFilterCopyWithImpl(this._self, this._then);

  final _RandomPickFilter _self;
  final $Res Function(_RandomPickFilter) _then;

/// Create a copy of RandomPickFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shelfId = freezed,Object? mediaType = freezed,Object? genre = freezed,Object? maxRuntimeMinutes = freezed,Object? maxPageCount = freezed,Object? unratedOnly = null,}) {
  return _then(_RandomPickFilter(
shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,maxRuntimeMinutes: freezed == maxRuntimeMinutes ? _self.maxRuntimeMinutes : maxRuntimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,maxPageCount: freezed == maxPageCount ? _self.maxPageCount : maxPageCount // ignore: cast_nullable_to_non_nullable
as int?,unratedOnly: null == unratedOnly ? _self.unratedOnly : unratedOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
