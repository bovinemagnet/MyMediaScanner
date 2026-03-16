// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetadataCandidate {

 String get sourceApi; String get sourceId; String get title; String? get subtitle; String? get coverUrl; int? get year; String? get format; MediaType? get mediaType;
/// Create a copy of MetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataCandidateCopyWith<MetadataCandidate> get copyWith => _$MetadataCandidateCopyWithImpl<MetadataCandidate>(this as MetadataCandidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetadataCandidate&&(identical(other.sourceApi, sourceApi) || other.sourceApi == sourceApi)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.format, format) || other.format == format)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,sourceApi,sourceId,title,subtitle,coverUrl,year,format,mediaType);

@override
String toString() {
  return 'MetadataCandidate(sourceApi: $sourceApi, sourceId: $sourceId, title: $title, subtitle: $subtitle, coverUrl: $coverUrl, year: $year, format: $format, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class $MetadataCandidateCopyWith<$Res>  {
  factory $MetadataCandidateCopyWith(MetadataCandidate value, $Res Function(MetadataCandidate) _then) = _$MetadataCandidateCopyWithImpl;
@useResult
$Res call({
 String sourceApi, String sourceId, String title, String? subtitle, String? coverUrl, int? year, String? format, MediaType? mediaType
});




}
/// @nodoc
class _$MetadataCandidateCopyWithImpl<$Res>
    implements $MetadataCandidateCopyWith<$Res> {
  _$MetadataCandidateCopyWithImpl(this._self, this._then);

  final MetadataCandidate _self;
  final $Res Function(MetadataCandidate) _then;

/// Create a copy of MetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceApi = null,Object? sourceId = null,Object? title = null,Object? subtitle = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? format = freezed,Object? mediaType = freezed,}) {
  return _then(_self.copyWith(
sourceApi: null == sourceApi ? _self.sourceApi : sourceApi // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetadataCandidate].
extension MetadataCandidatePatterns on MetadataCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetadataCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetadataCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetadataCandidate value)  $default,){
final _that = this;
switch (_that) {
case _MetadataCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetadataCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _MetadataCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceApi,  String sourceId,  String title,  String? subtitle,  String? coverUrl,  int? year,  String? format,  MediaType? mediaType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetadataCandidate() when $default != null:
return $default(_that.sourceApi,_that.sourceId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.format,_that.mediaType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceApi,  String sourceId,  String title,  String? subtitle,  String? coverUrl,  int? year,  String? format,  MediaType? mediaType)  $default,) {final _that = this;
switch (_that) {
case _MetadataCandidate():
return $default(_that.sourceApi,_that.sourceId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.format,_that.mediaType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceApi,  String sourceId,  String title,  String? subtitle,  String? coverUrl,  int? year,  String? format,  MediaType? mediaType)?  $default,) {final _that = this;
switch (_that) {
case _MetadataCandidate() when $default != null:
return $default(_that.sourceApi,_that.sourceId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.format,_that.mediaType);case _:
  return null;

}
}

}

/// @nodoc


class _MetadataCandidate implements MetadataCandidate {
  const _MetadataCandidate({required this.sourceApi, required this.sourceId, required this.title, this.subtitle, this.coverUrl, this.year, this.format, this.mediaType});
  

@override final  String sourceApi;
@override final  String sourceId;
@override final  String title;
@override final  String? subtitle;
@override final  String? coverUrl;
@override final  int? year;
@override final  String? format;
@override final  MediaType? mediaType;

/// Create a copy of MetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataCandidateCopyWith<_MetadataCandidate> get copyWith => __$MetadataCandidateCopyWithImpl<_MetadataCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetadataCandidate&&(identical(other.sourceApi, sourceApi) || other.sourceApi == sourceApi)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.format, format) || other.format == format)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,sourceApi,sourceId,title,subtitle,coverUrl,year,format,mediaType);

@override
String toString() {
  return 'MetadataCandidate(sourceApi: $sourceApi, sourceId: $sourceId, title: $title, subtitle: $subtitle, coverUrl: $coverUrl, year: $year, format: $format, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class _$MetadataCandidateCopyWith<$Res> implements $MetadataCandidateCopyWith<$Res> {
  factory _$MetadataCandidateCopyWith(_MetadataCandidate value, $Res Function(_MetadataCandidate) _then) = __$MetadataCandidateCopyWithImpl;
@override @useResult
$Res call({
 String sourceApi, String sourceId, String title, String? subtitle, String? coverUrl, int? year, String? format, MediaType? mediaType
});




}
/// @nodoc
class __$MetadataCandidateCopyWithImpl<$Res>
    implements _$MetadataCandidateCopyWith<$Res> {
  __$MetadataCandidateCopyWithImpl(this._self, this._then);

  final _MetadataCandidate _self;
  final $Res Function(_MetadataCandidate) _then;

/// Create a copy of MetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceApi = null,Object? sourceId = null,Object? title = null,Object? subtitle = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? format = freezed,Object? mediaType = freezed,}) {
  return _then(_MetadataCandidate(
sourceApi: null == sourceApi ? _self.sourceApi : sourceApi // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,
  ));
}


}

// dart format on
