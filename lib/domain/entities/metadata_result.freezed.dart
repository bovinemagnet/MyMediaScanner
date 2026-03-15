// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetadataResult {

 String get barcode; String get barcodeType; MediaType? get mediaType; String? get title; String? get subtitle; String? get description; String? get coverUrl; int? get year; String? get publisher; String? get format; List<String> get genres; Map<String, dynamic> get extraMetadata; List<String> get sourceApis; double? get criticScore; String? get criticSource;
/// Create a copy of MetadataResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataResultCopyWith<MetadataResult> get copyWith => _$MetadataResultCopyWithImpl<MetadataResult>(this as MetadataResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetadataResult&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.format, format) || other.format == format)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.extraMetadata, extraMetadata)&&const DeepCollectionEquality().equals(other.sourceApis, sourceApis)&&(identical(other.criticScore, criticScore) || other.criticScore == criticScore)&&(identical(other.criticSource, criticSource) || other.criticSource == criticSource));
}


@override
int get hashCode => Object.hash(runtimeType,barcode,barcodeType,mediaType,title,subtitle,description,coverUrl,year,publisher,format,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(extraMetadata),const DeepCollectionEquality().hash(sourceApis),criticScore,criticSource);

@override
String toString() {
  return 'MetadataResult(barcode: $barcode, barcodeType: $barcodeType, mediaType: $mediaType, title: $title, subtitle: $subtitle, description: $description, coverUrl: $coverUrl, year: $year, publisher: $publisher, format: $format, genres: $genres, extraMetadata: $extraMetadata, sourceApis: $sourceApis, criticScore: $criticScore, criticSource: $criticSource)';
}


}

/// @nodoc
abstract mixin class $MetadataResultCopyWith<$Res>  {
  factory $MetadataResultCopyWith(MetadataResult value, $Res Function(MetadataResult) _then) = _$MetadataResultCopyWithImpl;
@useResult
$Res call({
 String barcode, String barcodeType, MediaType? mediaType, String? title, String? subtitle, String? description, String? coverUrl, int? year, String? publisher, String? format, List<String> genres, Map<String, dynamic> extraMetadata, List<String> sourceApis, double? criticScore, String? criticSource
});




}
/// @nodoc
class _$MetadataResultCopyWithImpl<$Res>
    implements $MetadataResultCopyWith<$Res> {
  _$MetadataResultCopyWithImpl(this._self, this._then);

  final MetadataResult _self;
  final $Res Function(MetadataResult) _then;

/// Create a copy of MetadataResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? barcodeType = null,Object? mediaType = freezed,Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? publisher = freezed,Object? format = freezed,Object? genres = null,Object? extraMetadata = null,Object? sourceApis = null,Object? criticScore = freezed,Object? criticSource = freezed,}) {
  return _then(_self.copyWith(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,extraMetadata: null == extraMetadata ? _self.extraMetadata : extraMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceApis: null == sourceApis ? _self.sourceApis : sourceApis // ignore: cast_nullable_to_non_nullable
as List<String>,criticScore: freezed == criticScore ? _self.criticScore : criticScore // ignore: cast_nullable_to_non_nullable
as double?,criticSource: freezed == criticSource ? _self.criticSource : criticSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetadataResult].
extension MetadataResultPatterns on MetadataResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetadataResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetadataResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetadataResult value)  $default,){
final _that = this;
switch (_that) {
case _MetadataResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetadataResult value)?  $default,){
final _that = this;
switch (_that) {
case _MetadataResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  String barcodeType,  MediaType? mediaType,  String? title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? criticScore,  String? criticSource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetadataResult() when $default != null:
return $default(_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.criticScore,_that.criticSource);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  String barcodeType,  MediaType? mediaType,  String? title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? criticScore,  String? criticSource)  $default,) {final _that = this;
switch (_that) {
case _MetadataResult():
return $default(_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.criticScore,_that.criticSource);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  String barcodeType,  MediaType? mediaType,  String? title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? criticScore,  String? criticSource)?  $default,) {final _that = this;
switch (_that) {
case _MetadataResult() when $default != null:
return $default(_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.criticScore,_that.criticSource);case _:
  return null;

}
}

}

/// @nodoc


class _MetadataResult implements MetadataResult {
  const _MetadataResult({required this.barcode, required this.barcodeType, this.mediaType, this.title, this.subtitle, this.description, this.coverUrl, this.year, this.publisher, this.format, final  List<String> genres = const [], final  Map<String, dynamic> extraMetadata = const {}, final  List<String> sourceApis = const [], this.criticScore, this.criticSource}): _genres = genres,_extraMetadata = extraMetadata,_sourceApis = sourceApis;
  

@override final  String barcode;
@override final  String barcodeType;
@override final  MediaType? mediaType;
@override final  String? title;
@override final  String? subtitle;
@override final  String? description;
@override final  String? coverUrl;
@override final  int? year;
@override final  String? publisher;
@override final  String? format;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  Map<String, dynamic> _extraMetadata;
@override@JsonKey() Map<String, dynamic> get extraMetadata {
  if (_extraMetadata is EqualUnmodifiableMapView) return _extraMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extraMetadata);
}

 final  List<String> _sourceApis;
@override@JsonKey() List<String> get sourceApis {
  if (_sourceApis is EqualUnmodifiableListView) return _sourceApis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceApis);
}

@override final  double? criticScore;
@override final  String? criticSource;

/// Create a copy of MetadataResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataResultCopyWith<_MetadataResult> get copyWith => __$MetadataResultCopyWithImpl<_MetadataResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetadataResult&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.format, format) || other.format == format)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._extraMetadata, _extraMetadata)&&const DeepCollectionEquality().equals(other._sourceApis, _sourceApis)&&(identical(other.criticScore, criticScore) || other.criticScore == criticScore)&&(identical(other.criticSource, criticSource) || other.criticSource == criticSource));
}


@override
int get hashCode => Object.hash(runtimeType,barcode,barcodeType,mediaType,title,subtitle,description,coverUrl,year,publisher,format,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_extraMetadata),const DeepCollectionEquality().hash(_sourceApis),criticScore,criticSource);

@override
String toString() {
  return 'MetadataResult(barcode: $barcode, barcodeType: $barcodeType, mediaType: $mediaType, title: $title, subtitle: $subtitle, description: $description, coverUrl: $coverUrl, year: $year, publisher: $publisher, format: $format, genres: $genres, extraMetadata: $extraMetadata, sourceApis: $sourceApis, criticScore: $criticScore, criticSource: $criticSource)';
}


}

/// @nodoc
abstract mixin class _$MetadataResultCopyWith<$Res> implements $MetadataResultCopyWith<$Res> {
  factory _$MetadataResultCopyWith(_MetadataResult value, $Res Function(_MetadataResult) _then) = __$MetadataResultCopyWithImpl;
@override @useResult
$Res call({
 String barcode, String barcodeType, MediaType? mediaType, String? title, String? subtitle, String? description, String? coverUrl, int? year, String? publisher, String? format, List<String> genres, Map<String, dynamic> extraMetadata, List<String> sourceApis, double? criticScore, String? criticSource
});




}
/// @nodoc
class __$MetadataResultCopyWithImpl<$Res>
    implements _$MetadataResultCopyWith<$Res> {
  __$MetadataResultCopyWithImpl(this._self, this._then);

  final _MetadataResult _self;
  final $Res Function(_MetadataResult) _then;

/// Create a copy of MetadataResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? barcodeType = null,Object? mediaType = freezed,Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? publisher = freezed,Object? format = freezed,Object? genres = null,Object? extraMetadata = null,Object? sourceApis = null,Object? criticScore = freezed,Object? criticSource = freezed,}) {
  return _then(_MetadataResult(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,extraMetadata: null == extraMetadata ? _self._extraMetadata : extraMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceApis: null == sourceApis ? _self._sourceApis : sourceApis // ignore: cast_nullable_to_non_nullable
as List<String>,criticScore: freezed == criticScore ? _self.criticScore : criticScore // ignore: cast_nullable_to_non_nullable
as double?,criticSource: freezed == criticSource ? _self.criticSource : criticSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
