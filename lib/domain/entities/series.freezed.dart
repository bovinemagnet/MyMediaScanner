// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Series {

 String get id;/// Qualified provider id, e.g. `tmdb:131635`, `mb:abc`, `gbooks:HP`.
 String get externalId; String get name; MediaType get mediaType;/// Originating provider, e.g. `tmdb`, `musicbrainz`, `google_books`.
 String get source;/// Known number of entries from the upstream provider, or `null` if
/// the provider did not report a total.
 int? get totalCount; int get updatedAt; bool get deleted;
/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesCopyWith<Series> get copyWith => _$SeriesCopyWithImpl<Series>(this as Series, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Series&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.name, name) || other.name == name)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.source, source) || other.source == source)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,externalId,name,mediaType,source,totalCount,updatedAt,deleted);

@override
String toString() {
  return 'Series(id: $id, externalId: $externalId, name: $name, mediaType: $mediaType, source: $source, totalCount: $totalCount, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $SeriesCopyWith<$Res>  {
  factory $SeriesCopyWith(Series value, $Res Function(Series) _then) = _$SeriesCopyWithImpl;
@useResult
$Res call({
 String id, String externalId, String name, MediaType mediaType, String source, int? totalCount, int updatedAt, bool deleted
});




}
/// @nodoc
class _$SeriesCopyWithImpl<$Res>
    implements $SeriesCopyWith<$Res> {
  _$SeriesCopyWithImpl(this._self, this._then);

  final Series _self;
  final $Res Function(Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? externalId = null,Object? name = null,Object? mediaType = null,Object? source = null,Object? totalCount = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Series].
extension SeriesPatterns on Series {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Series value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Series value)  $default,){
final _that = this;
switch (_that) {
case _Series():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Series value)?  $default,){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String externalId,  String name,  MediaType mediaType,  String source,  int? totalCount,  int updatedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.id,_that.externalId,_that.name,_that.mediaType,_that.source,_that.totalCount,_that.updatedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String externalId,  String name,  MediaType mediaType,  String source,  int? totalCount,  int updatedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _Series():
return $default(_that.id,_that.externalId,_that.name,_that.mediaType,_that.source,_that.totalCount,_that.updatedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String externalId,  String name,  MediaType mediaType,  String source,  int? totalCount,  int updatedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.id,_that.externalId,_that.name,_that.mediaType,_that.source,_that.totalCount,_that.updatedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _Series implements Series {
  const _Series({required this.id, required this.externalId, required this.name, required this.mediaType, required this.source, this.totalCount, required this.updatedAt, this.deleted = false});
  

@override final  String id;
/// Qualified provider id, e.g. `tmdb:131635`, `mb:abc`, `gbooks:HP`.
@override final  String externalId;
@override final  String name;
@override final  MediaType mediaType;
/// Originating provider, e.g. `tmdb`, `musicbrainz`, `google_books`.
@override final  String source;
/// Known number of entries from the upstream provider, or `null` if
/// the provider did not report a total.
@override final  int? totalCount;
@override final  int updatedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesCopyWith<_Series> get copyWith => __$SeriesCopyWithImpl<_Series>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Series&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.name, name) || other.name == name)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.source, source) || other.source == source)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,externalId,name,mediaType,source,totalCount,updatedAt,deleted);

@override
String toString() {
  return 'Series(id: $id, externalId: $externalId, name: $name, mediaType: $mediaType, source: $source, totalCount: $totalCount, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$SeriesCopyWith<$Res> implements $SeriesCopyWith<$Res> {
  factory _$SeriesCopyWith(_Series value, $Res Function(_Series) _then) = __$SeriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String externalId, String name, MediaType mediaType, String source, int? totalCount, int updatedAt, bool deleted
});




}
/// @nodoc
class __$SeriesCopyWithImpl<$Res>
    implements _$SeriesCopyWith<$Res> {
  __$SeriesCopyWithImpl(this._self, this._then);

  final _Series _self;
  final $Res Function(_Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? externalId = null,Object? name = null,Object? mediaType = null,Object? source = null,Object? totalCount = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_Series(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
