// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaItem {

 String get id; String get barcode; String get barcodeType; MediaType get mediaType; String get title; String? get subtitle; String? get description; String? get coverUrl; int? get year; String? get publisher; String? get format; List<String> get genres; Map<String, dynamic> get extraMetadata; List<String> get sourceApis; double? get userRating; String? get userReview; double? get criticScore; String? get criticSource; int get dateAdded; int get dateScanned; int get updatedAt; int? get syncedAt; bool get deleted;
/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaItemCopyWith<MediaItem> get copyWith => _$MediaItemCopyWithImpl<MediaItem>(this as MediaItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.format, format) || other.format == format)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.extraMetadata, extraMetadata)&&const DeepCollectionEquality().equals(other.sourceApis, sourceApis)&&(identical(other.userRating, userRating) || other.userRating == userRating)&&(identical(other.userReview, userReview) || other.userReview == userReview)&&(identical(other.criticScore, criticScore) || other.criticScore == criticScore)&&(identical(other.criticSource, criticSource) || other.criticSource == criticSource)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded)&&(identical(other.dateScanned, dateScanned) || other.dateScanned == dateScanned)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,barcode,barcodeType,mediaType,title,subtitle,description,coverUrl,year,publisher,format,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(extraMetadata),const DeepCollectionEquality().hash(sourceApis),userRating,userReview,criticScore,criticSource,dateAdded,dateScanned,updatedAt,syncedAt,deleted]);

@override
String toString() {
  return 'MediaItem(id: $id, barcode: $barcode, barcodeType: $barcodeType, mediaType: $mediaType, title: $title, subtitle: $subtitle, description: $description, coverUrl: $coverUrl, year: $year, publisher: $publisher, format: $format, genres: $genres, extraMetadata: $extraMetadata, sourceApis: $sourceApis, userRating: $userRating, userReview: $userReview, criticScore: $criticScore, criticSource: $criticSource, dateAdded: $dateAdded, dateScanned: $dateScanned, updatedAt: $updatedAt, syncedAt: $syncedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $MediaItemCopyWith<$Res>  {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) _then) = _$MediaItemCopyWithImpl;
@useResult
$Res call({
 String id, String barcode, String barcodeType, MediaType mediaType, String title, String? subtitle, String? description, String? coverUrl, int? year, String? publisher, String? format, List<String> genres, Map<String, dynamic> extraMetadata, List<String> sourceApis, double? userRating, String? userReview, double? criticScore, String? criticSource, int dateAdded, int dateScanned, int updatedAt, int? syncedAt, bool deleted
});




}
/// @nodoc
class _$MediaItemCopyWithImpl<$Res>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._self, this._then);

  final MediaItem _self;
  final $Res Function(MediaItem) _then;

/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? barcode = null,Object? barcodeType = null,Object? mediaType = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? publisher = freezed,Object? format = freezed,Object? genres = null,Object? extraMetadata = null,Object? sourceApis = null,Object? userRating = freezed,Object? userReview = freezed,Object? criticScore = freezed,Object? criticSource = freezed,Object? dateAdded = null,Object? dateScanned = null,Object? updatedAt = null,Object? syncedAt = freezed,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,extraMetadata: null == extraMetadata ? _self.extraMetadata : extraMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceApis: null == sourceApis ? _self.sourceApis : sourceApis // ignore: cast_nullable_to_non_nullable
as List<String>,userRating: freezed == userRating ? _self.userRating : userRating // ignore: cast_nullable_to_non_nullable
as double?,userReview: freezed == userReview ? _self.userReview : userReview // ignore: cast_nullable_to_non_nullable
as String?,criticScore: freezed == criticScore ? _self.criticScore : criticScore // ignore: cast_nullable_to_non_nullable
as double?,criticSource: freezed == criticSource ? _self.criticSource : criticSource // ignore: cast_nullable_to_non_nullable
as String?,dateAdded: null == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as int,dateScanned: null == dateScanned ? _self.dateScanned : dateScanned // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as int?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaItem].
extension MediaItemPatterns on MediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaItem value)  $default,){
final _that = this;
switch (_that) {
case _MediaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaItem value)?  $default,){
final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String barcode,  String barcodeType,  MediaType mediaType,  String title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? userRating,  String? userReview,  double? criticScore,  String? criticSource,  int dateAdded,  int dateScanned,  int updatedAt,  int? syncedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
return $default(_that.id,_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.userRating,_that.userReview,_that.criticScore,_that.criticSource,_that.dateAdded,_that.dateScanned,_that.updatedAt,_that.syncedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String barcode,  String barcodeType,  MediaType mediaType,  String title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? userRating,  String? userReview,  double? criticScore,  String? criticSource,  int dateAdded,  int dateScanned,  int updatedAt,  int? syncedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _MediaItem():
return $default(_that.id,_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.userRating,_that.userReview,_that.criticScore,_that.criticSource,_that.dateAdded,_that.dateScanned,_that.updatedAt,_that.syncedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String barcode,  String barcodeType,  MediaType mediaType,  String title,  String? subtitle,  String? description,  String? coverUrl,  int? year,  String? publisher,  String? format,  List<String> genres,  Map<String, dynamic> extraMetadata,  List<String> sourceApis,  double? userRating,  String? userReview,  double? criticScore,  String? criticSource,  int dateAdded,  int dateScanned,  int updatedAt,  int? syncedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
return $default(_that.id,_that.barcode,_that.barcodeType,_that.mediaType,_that.title,_that.subtitle,_that.description,_that.coverUrl,_that.year,_that.publisher,_that.format,_that.genres,_that.extraMetadata,_that.sourceApis,_that.userRating,_that.userReview,_that.criticScore,_that.criticSource,_that.dateAdded,_that.dateScanned,_that.updatedAt,_that.syncedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _MediaItem implements MediaItem {
  const _MediaItem({required this.id, required this.barcode, required this.barcodeType, required this.mediaType, required this.title, this.subtitle, this.description, this.coverUrl, this.year, this.publisher, this.format, final  List<String> genres = const [], final  Map<String, dynamic> extraMetadata = const {}, final  List<String> sourceApis = const [], this.userRating, this.userReview, this.criticScore, this.criticSource, required this.dateAdded, required this.dateScanned, required this.updatedAt, this.syncedAt, this.deleted = false}): _genres = genres,_extraMetadata = extraMetadata,_sourceApis = sourceApis;
  

@override final  String id;
@override final  String barcode;
@override final  String barcodeType;
@override final  MediaType mediaType;
@override final  String title;
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

@override final  double? userRating;
@override final  String? userReview;
@override final  double? criticScore;
@override final  String? criticSource;
@override final  int dateAdded;
@override final  int dateScanned;
@override final  int updatedAt;
@override final  int? syncedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaItemCopyWith<_MediaItem> get copyWith => __$MediaItemCopyWithImpl<_MediaItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.format, format) || other.format == format)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._extraMetadata, _extraMetadata)&&const DeepCollectionEquality().equals(other._sourceApis, _sourceApis)&&(identical(other.userRating, userRating) || other.userRating == userRating)&&(identical(other.userReview, userReview) || other.userReview == userReview)&&(identical(other.criticScore, criticScore) || other.criticScore == criticScore)&&(identical(other.criticSource, criticSource) || other.criticSource == criticSource)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded)&&(identical(other.dateScanned, dateScanned) || other.dateScanned == dateScanned)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,barcode,barcodeType,mediaType,title,subtitle,description,coverUrl,year,publisher,format,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_extraMetadata),const DeepCollectionEquality().hash(_sourceApis),userRating,userReview,criticScore,criticSource,dateAdded,dateScanned,updatedAt,syncedAt,deleted]);

@override
String toString() {
  return 'MediaItem(id: $id, barcode: $barcode, barcodeType: $barcodeType, mediaType: $mediaType, title: $title, subtitle: $subtitle, description: $description, coverUrl: $coverUrl, year: $year, publisher: $publisher, format: $format, genres: $genres, extraMetadata: $extraMetadata, sourceApis: $sourceApis, userRating: $userRating, userReview: $userReview, criticScore: $criticScore, criticSource: $criticSource, dateAdded: $dateAdded, dateScanned: $dateScanned, updatedAt: $updatedAt, syncedAt: $syncedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$MediaItemCopyWith<$Res> implements $MediaItemCopyWith<$Res> {
  factory _$MediaItemCopyWith(_MediaItem value, $Res Function(_MediaItem) _then) = __$MediaItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String barcode, String barcodeType, MediaType mediaType, String title, String? subtitle, String? description, String? coverUrl, int? year, String? publisher, String? format, List<String> genres, Map<String, dynamic> extraMetadata, List<String> sourceApis, double? userRating, String? userReview, double? criticScore, String? criticSource, int dateAdded, int dateScanned, int updatedAt, int? syncedAt, bool deleted
});




}
/// @nodoc
class __$MediaItemCopyWithImpl<$Res>
    implements _$MediaItemCopyWith<$Res> {
  __$MediaItemCopyWithImpl(this._self, this._then);

  final _MediaItem _self;
  final $Res Function(_MediaItem) _then;

/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? barcode = null,Object? barcodeType = null,Object? mediaType = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? publisher = freezed,Object? format = freezed,Object? genres = null,Object? extraMetadata = null,Object? sourceApis = null,Object? userRating = freezed,Object? userReview = freezed,Object? criticScore = freezed,Object? criticSource = freezed,Object? dateAdded = null,Object? dateScanned = null,Object? updatedAt = null,Object? syncedAt = freezed,Object? deleted = null,}) {
  return _then(_MediaItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,extraMetadata: null == extraMetadata ? _self._extraMetadata : extraMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceApis: null == sourceApis ? _self._sourceApis : sourceApis // ignore: cast_nullable_to_non_nullable
as List<String>,userRating: freezed == userRating ? _self.userRating : userRating // ignore: cast_nullable_to_non_nullable
as double?,userReview: freezed == userReview ? _self.userReview : userReview // ignore: cast_nullable_to_non_nullable
as String?,criticScore: freezed == criticScore ? _self.criticScore : criticScore // ignore: cast_nullable_to_non_nullable
as double?,criticSource: freezed == criticSource ? _self.criticSource : criticSource // ignore: cast_nullable_to_non_nullable
as String?,dateAdded: null == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as int,dateScanned: null == dateScanned ? _self.dateScanned : dateScanned // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as int?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
