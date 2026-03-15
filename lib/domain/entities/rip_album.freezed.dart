// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rip_album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RipAlbum {

 String get id; String get libraryPath; String? get artist; String? get albumTitle; String? get barcode; int get trackCount; int get discCount; int get totalSizeBytes; String? get mediaItemId; int get lastScannedAt; int get updatedAt; bool get deleted;
/// Create a copy of RipAlbum
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RipAlbumCopyWith<RipAlbum> get copyWith => _$RipAlbumCopyWithImpl<RipAlbum>(this as RipAlbum, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RipAlbum&&(identical(other.id, id) || other.id == id)&&(identical(other.libraryPath, libraryPath) || other.libraryPath == libraryPath)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.albumTitle, albumTitle) || other.albumTitle == albumTitle)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&(identical(other.discCount, discCount) || other.discCount == discCount)&&(identical(other.totalSizeBytes, totalSizeBytes) || other.totalSizeBytes == totalSizeBytes)&&(identical(other.mediaItemId, mediaItemId) || other.mediaItemId == mediaItemId)&&(identical(other.lastScannedAt, lastScannedAt) || other.lastScannedAt == lastScannedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,libraryPath,artist,albumTitle,barcode,trackCount,discCount,totalSizeBytes,mediaItemId,lastScannedAt,updatedAt,deleted);

@override
String toString() {
  return 'RipAlbum(id: $id, libraryPath: $libraryPath, artist: $artist, albumTitle: $albumTitle, barcode: $barcode, trackCount: $trackCount, discCount: $discCount, totalSizeBytes: $totalSizeBytes, mediaItemId: $mediaItemId, lastScannedAt: $lastScannedAt, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $RipAlbumCopyWith<$Res>  {
  factory $RipAlbumCopyWith(RipAlbum value, $Res Function(RipAlbum) _then) = _$RipAlbumCopyWithImpl;
@useResult
$Res call({
 String id, String libraryPath, String? artist, String? albumTitle, String? barcode, int trackCount, int discCount, int totalSizeBytes, String? mediaItemId, int lastScannedAt, int updatedAt, bool deleted
});




}
/// @nodoc
class _$RipAlbumCopyWithImpl<$Res>
    implements $RipAlbumCopyWith<$Res> {
  _$RipAlbumCopyWithImpl(this._self, this._then);

  final RipAlbum _self;
  final $Res Function(RipAlbum) _then;

/// Create a copy of RipAlbum
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? libraryPath = null,Object? artist = freezed,Object? albumTitle = freezed,Object? barcode = freezed,Object? trackCount = null,Object? discCount = null,Object? totalSizeBytes = null,Object? mediaItemId = freezed,Object? lastScannedAt = null,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,libraryPath: null == libraryPath ? _self.libraryPath : libraryPath // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,albumTitle: freezed == albumTitle ? _self.albumTitle : albumTitle // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,discCount: null == discCount ? _self.discCount : discCount // ignore: cast_nullable_to_non_nullable
as int,totalSizeBytes: null == totalSizeBytes ? _self.totalSizeBytes : totalSizeBytes // ignore: cast_nullable_to_non_nullable
as int,mediaItemId: freezed == mediaItemId ? _self.mediaItemId : mediaItemId // ignore: cast_nullable_to_non_nullable
as String?,lastScannedAt: null == lastScannedAt ? _self.lastScannedAt : lastScannedAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RipAlbum].
extension RipAlbumPatterns on RipAlbum {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RipAlbum value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RipAlbum() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RipAlbum value)  $default,){
final _that = this;
switch (_that) {
case _RipAlbum():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RipAlbum value)?  $default,){
final _that = this;
switch (_that) {
case _RipAlbum() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String libraryPath,  String? artist,  String? albumTitle,  String? barcode,  int trackCount,  int discCount,  int totalSizeBytes,  String? mediaItemId,  int lastScannedAt,  int updatedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RipAlbum() when $default != null:
return $default(_that.id,_that.libraryPath,_that.artist,_that.albumTitle,_that.barcode,_that.trackCount,_that.discCount,_that.totalSizeBytes,_that.mediaItemId,_that.lastScannedAt,_that.updatedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String libraryPath,  String? artist,  String? albumTitle,  String? barcode,  int trackCount,  int discCount,  int totalSizeBytes,  String? mediaItemId,  int lastScannedAt,  int updatedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _RipAlbum():
return $default(_that.id,_that.libraryPath,_that.artist,_that.albumTitle,_that.barcode,_that.trackCount,_that.discCount,_that.totalSizeBytes,_that.mediaItemId,_that.lastScannedAt,_that.updatedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String libraryPath,  String? artist,  String? albumTitle,  String? barcode,  int trackCount,  int discCount,  int totalSizeBytes,  String? mediaItemId,  int lastScannedAt,  int updatedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _RipAlbum() when $default != null:
return $default(_that.id,_that.libraryPath,_that.artist,_that.albumTitle,_that.barcode,_that.trackCount,_that.discCount,_that.totalSizeBytes,_that.mediaItemId,_that.lastScannedAt,_that.updatedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _RipAlbum implements RipAlbum {
  const _RipAlbum({required this.id, required this.libraryPath, this.artist, this.albumTitle, this.barcode, required this.trackCount, this.discCount = 1, required this.totalSizeBytes, this.mediaItemId, required this.lastScannedAt, required this.updatedAt, this.deleted = false});
  

@override final  String id;
@override final  String libraryPath;
@override final  String? artist;
@override final  String? albumTitle;
@override final  String? barcode;
@override final  int trackCount;
@override@JsonKey() final  int discCount;
@override final  int totalSizeBytes;
@override final  String? mediaItemId;
@override final  int lastScannedAt;
@override final  int updatedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of RipAlbum
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RipAlbumCopyWith<_RipAlbum> get copyWith => __$RipAlbumCopyWithImpl<_RipAlbum>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RipAlbum&&(identical(other.id, id) || other.id == id)&&(identical(other.libraryPath, libraryPath) || other.libraryPath == libraryPath)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.albumTitle, albumTitle) || other.albumTitle == albumTitle)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&(identical(other.discCount, discCount) || other.discCount == discCount)&&(identical(other.totalSizeBytes, totalSizeBytes) || other.totalSizeBytes == totalSizeBytes)&&(identical(other.mediaItemId, mediaItemId) || other.mediaItemId == mediaItemId)&&(identical(other.lastScannedAt, lastScannedAt) || other.lastScannedAt == lastScannedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,libraryPath,artist,albumTitle,barcode,trackCount,discCount,totalSizeBytes,mediaItemId,lastScannedAt,updatedAt,deleted);

@override
String toString() {
  return 'RipAlbum(id: $id, libraryPath: $libraryPath, artist: $artist, albumTitle: $albumTitle, barcode: $barcode, trackCount: $trackCount, discCount: $discCount, totalSizeBytes: $totalSizeBytes, mediaItemId: $mediaItemId, lastScannedAt: $lastScannedAt, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$RipAlbumCopyWith<$Res> implements $RipAlbumCopyWith<$Res> {
  factory _$RipAlbumCopyWith(_RipAlbum value, $Res Function(_RipAlbum) _then) = __$RipAlbumCopyWithImpl;
@override @useResult
$Res call({
 String id, String libraryPath, String? artist, String? albumTitle, String? barcode, int trackCount, int discCount, int totalSizeBytes, String? mediaItemId, int lastScannedAt, int updatedAt, bool deleted
});




}
/// @nodoc
class __$RipAlbumCopyWithImpl<$Res>
    implements _$RipAlbumCopyWith<$Res> {
  __$RipAlbumCopyWithImpl(this._self, this._then);

  final _RipAlbum _self;
  final $Res Function(_RipAlbum) _then;

/// Create a copy of RipAlbum
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? libraryPath = null,Object? artist = freezed,Object? albumTitle = freezed,Object? barcode = freezed,Object? trackCount = null,Object? discCount = null,Object? totalSizeBytes = null,Object? mediaItemId = freezed,Object? lastScannedAt = null,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_RipAlbum(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,libraryPath: null == libraryPath ? _self.libraryPath : libraryPath // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,albumTitle: freezed == albumTitle ? _self.albumTitle : albumTitle // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,discCount: null == discCount ? _self.discCount : discCount // ignore: cast_nullable_to_non_nullable
as int,totalSizeBytes: null == totalSizeBytes ? _self.totalSizeBytes : totalSizeBytes // ignore: cast_nullable_to_non_nullable
as int,mediaItemId: freezed == mediaItemId ? _self.mediaItemId : mediaItemId // ignore: cast_nullable_to_non_nullable
as String?,lastScannedAt: null == lastScannedAt ? _self.lastScannedAt : lastScannedAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
