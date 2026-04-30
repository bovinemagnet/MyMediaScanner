// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rip_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RipTrack {

 String get id; String get ripAlbumId; int get discNumber; int get trackNumber; String? get title; String get filePath; int? get durationMs; int get fileSizeBytes; int get updatedAt;// Audio quality analysis fields (Phase B)
 String? get accurateRipStatus; int? get accurateRipConfidence; String? get accurateRipCrcV1; String? get accurateRipCrcV2; double? get peakLevel; double? get trackQuality; String? get copyCrc; int? get clickCount; int? get popCount; int? get clippingCount; int? get dropoutCount; double? get defectConfidence; String? get ripLogSource; int? get qualityCheckedAt;
/// Create a copy of RipTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RipTrackCopyWith<RipTrack> get copyWith => _$RipTrackCopyWithImpl<RipTrack>(this as RipTrack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RipTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.ripAlbumId, ripAlbumId) || other.ripAlbumId == ripAlbumId)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.accurateRipStatus, accurateRipStatus) || other.accurateRipStatus == accurateRipStatus)&&(identical(other.accurateRipConfidence, accurateRipConfidence) || other.accurateRipConfidence == accurateRipConfidence)&&(identical(other.accurateRipCrcV1, accurateRipCrcV1) || other.accurateRipCrcV1 == accurateRipCrcV1)&&(identical(other.accurateRipCrcV2, accurateRipCrcV2) || other.accurateRipCrcV2 == accurateRipCrcV2)&&(identical(other.peakLevel, peakLevel) || other.peakLevel == peakLevel)&&(identical(other.trackQuality, trackQuality) || other.trackQuality == trackQuality)&&(identical(other.copyCrc, copyCrc) || other.copyCrc == copyCrc)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.popCount, popCount) || other.popCount == popCount)&&(identical(other.clippingCount, clippingCount) || other.clippingCount == clippingCount)&&(identical(other.dropoutCount, dropoutCount) || other.dropoutCount == dropoutCount)&&(identical(other.defectConfidence, defectConfidence) || other.defectConfidence == defectConfidence)&&(identical(other.ripLogSource, ripLogSource) || other.ripLogSource == ripLogSource)&&(identical(other.qualityCheckedAt, qualityCheckedAt) || other.qualityCheckedAt == qualityCheckedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,ripAlbumId,discNumber,trackNumber,title,filePath,durationMs,fileSizeBytes,updatedAt,accurateRipStatus,accurateRipConfidence,accurateRipCrcV1,accurateRipCrcV2,peakLevel,trackQuality,copyCrc,clickCount,popCount,clippingCount,dropoutCount,defectConfidence,ripLogSource,qualityCheckedAt]);

@override
String toString() {
  return 'RipTrack(id: $id, ripAlbumId: $ripAlbumId, discNumber: $discNumber, trackNumber: $trackNumber, title: $title, filePath: $filePath, durationMs: $durationMs, fileSizeBytes: $fileSizeBytes, updatedAt: $updatedAt, accurateRipStatus: $accurateRipStatus, accurateRipConfidence: $accurateRipConfidence, accurateRipCrcV1: $accurateRipCrcV1, accurateRipCrcV2: $accurateRipCrcV2, peakLevel: $peakLevel, trackQuality: $trackQuality, copyCrc: $copyCrc, clickCount: $clickCount, popCount: $popCount, clippingCount: $clippingCount, dropoutCount: $dropoutCount, defectConfidence: $defectConfidence, ripLogSource: $ripLogSource, qualityCheckedAt: $qualityCheckedAt)';
}


}

/// @nodoc
abstract mixin class $RipTrackCopyWith<$Res>  {
  factory $RipTrackCopyWith(RipTrack value, $Res Function(RipTrack) _then) = _$RipTrackCopyWithImpl;
@useResult
$Res call({
 String id, String ripAlbumId, int discNumber, int trackNumber, String? title, String filePath, int? durationMs, int fileSizeBytes, int updatedAt, String? accurateRipStatus, int? accurateRipConfidence, String? accurateRipCrcV1, String? accurateRipCrcV2, double? peakLevel, double? trackQuality, String? copyCrc, int? clickCount, int? popCount, int? clippingCount, int? dropoutCount, double? defectConfidence, String? ripLogSource, int? qualityCheckedAt
});




}
/// @nodoc
class _$RipTrackCopyWithImpl<$Res>
    implements $RipTrackCopyWith<$Res> {
  _$RipTrackCopyWithImpl(this._self, this._then);

  final RipTrack _self;
  final $Res Function(RipTrack) _then;

/// Create a copy of RipTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ripAlbumId = null,Object? discNumber = null,Object? trackNumber = null,Object? title = freezed,Object? filePath = null,Object? durationMs = freezed,Object? fileSizeBytes = null,Object? updatedAt = null,Object? accurateRipStatus = freezed,Object? accurateRipConfidence = freezed,Object? accurateRipCrcV1 = freezed,Object? accurateRipCrcV2 = freezed,Object? peakLevel = freezed,Object? trackQuality = freezed,Object? copyCrc = freezed,Object? clickCount = freezed,Object? popCount = freezed,Object? clippingCount = freezed,Object? dropoutCount = freezed,Object? defectConfidence = freezed,Object? ripLogSource = freezed,Object? qualityCheckedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ripAlbumId: null == ripAlbumId ? _self.ripAlbumId : ripAlbumId // ignore: cast_nullable_to_non_nullable
as String,discNumber: null == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int,trackNumber: null == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,accurateRipStatus: freezed == accurateRipStatus ? _self.accurateRipStatus : accurateRipStatus // ignore: cast_nullable_to_non_nullable
as String?,accurateRipConfidence: freezed == accurateRipConfidence ? _self.accurateRipConfidence : accurateRipConfidence // ignore: cast_nullable_to_non_nullable
as int?,accurateRipCrcV1: freezed == accurateRipCrcV1 ? _self.accurateRipCrcV1 : accurateRipCrcV1 // ignore: cast_nullable_to_non_nullable
as String?,accurateRipCrcV2: freezed == accurateRipCrcV2 ? _self.accurateRipCrcV2 : accurateRipCrcV2 // ignore: cast_nullable_to_non_nullable
as String?,peakLevel: freezed == peakLevel ? _self.peakLevel : peakLevel // ignore: cast_nullable_to_non_nullable
as double?,trackQuality: freezed == trackQuality ? _self.trackQuality : trackQuality // ignore: cast_nullable_to_non_nullable
as double?,copyCrc: freezed == copyCrc ? _self.copyCrc : copyCrc // ignore: cast_nullable_to_non_nullable
as String?,clickCount: freezed == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int?,popCount: freezed == popCount ? _self.popCount : popCount // ignore: cast_nullable_to_non_nullable
as int?,clippingCount: freezed == clippingCount ? _self.clippingCount : clippingCount // ignore: cast_nullable_to_non_nullable
as int?,dropoutCount: freezed == dropoutCount ? _self.dropoutCount : dropoutCount // ignore: cast_nullable_to_non_nullable
as int?,defectConfidence: freezed == defectConfidence ? _self.defectConfidence : defectConfidence // ignore: cast_nullable_to_non_nullable
as double?,ripLogSource: freezed == ripLogSource ? _self.ripLogSource : ripLogSource // ignore: cast_nullable_to_non_nullable
as String?,qualityCheckedAt: freezed == qualityCheckedAt ? _self.qualityCheckedAt : qualityCheckedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RipTrack].
extension RipTrackPatterns on RipTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RipTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RipTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RipTrack value)  $default,){
final _that = this;
switch (_that) {
case _RipTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RipTrack value)?  $default,){
final _that = this;
switch (_that) {
case _RipTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ripAlbumId,  int discNumber,  int trackNumber,  String? title,  String filePath,  int? durationMs,  int fileSizeBytes,  int updatedAt,  String? accurateRipStatus,  int? accurateRipConfidence,  String? accurateRipCrcV1,  String? accurateRipCrcV2,  double? peakLevel,  double? trackQuality,  String? copyCrc,  int? clickCount,  int? popCount,  int? clippingCount,  int? dropoutCount,  double? defectConfidence,  String? ripLogSource,  int? qualityCheckedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RipTrack() when $default != null:
return $default(_that.id,_that.ripAlbumId,_that.discNumber,_that.trackNumber,_that.title,_that.filePath,_that.durationMs,_that.fileSizeBytes,_that.updatedAt,_that.accurateRipStatus,_that.accurateRipConfidence,_that.accurateRipCrcV1,_that.accurateRipCrcV2,_that.peakLevel,_that.trackQuality,_that.copyCrc,_that.clickCount,_that.popCount,_that.clippingCount,_that.dropoutCount,_that.defectConfidence,_that.ripLogSource,_that.qualityCheckedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ripAlbumId,  int discNumber,  int trackNumber,  String? title,  String filePath,  int? durationMs,  int fileSizeBytes,  int updatedAt,  String? accurateRipStatus,  int? accurateRipConfidence,  String? accurateRipCrcV1,  String? accurateRipCrcV2,  double? peakLevel,  double? trackQuality,  String? copyCrc,  int? clickCount,  int? popCount,  int? clippingCount,  int? dropoutCount,  double? defectConfidence,  String? ripLogSource,  int? qualityCheckedAt)  $default,) {final _that = this;
switch (_that) {
case _RipTrack():
return $default(_that.id,_that.ripAlbumId,_that.discNumber,_that.trackNumber,_that.title,_that.filePath,_that.durationMs,_that.fileSizeBytes,_that.updatedAt,_that.accurateRipStatus,_that.accurateRipConfidence,_that.accurateRipCrcV1,_that.accurateRipCrcV2,_that.peakLevel,_that.trackQuality,_that.copyCrc,_that.clickCount,_that.popCount,_that.clippingCount,_that.dropoutCount,_that.defectConfidence,_that.ripLogSource,_that.qualityCheckedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ripAlbumId,  int discNumber,  int trackNumber,  String? title,  String filePath,  int? durationMs,  int fileSizeBytes,  int updatedAt,  String? accurateRipStatus,  int? accurateRipConfidence,  String? accurateRipCrcV1,  String? accurateRipCrcV2,  double? peakLevel,  double? trackQuality,  String? copyCrc,  int? clickCount,  int? popCount,  int? clippingCount,  int? dropoutCount,  double? defectConfidence,  String? ripLogSource,  int? qualityCheckedAt)?  $default,) {final _that = this;
switch (_that) {
case _RipTrack() when $default != null:
return $default(_that.id,_that.ripAlbumId,_that.discNumber,_that.trackNumber,_that.title,_that.filePath,_that.durationMs,_that.fileSizeBytes,_that.updatedAt,_that.accurateRipStatus,_that.accurateRipConfidence,_that.accurateRipCrcV1,_that.accurateRipCrcV2,_that.peakLevel,_that.trackQuality,_that.copyCrc,_that.clickCount,_that.popCount,_that.clippingCount,_that.dropoutCount,_that.defectConfidence,_that.ripLogSource,_that.qualityCheckedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RipTrack implements RipTrack {
  const _RipTrack({required this.id, required this.ripAlbumId, this.discNumber = 1, required this.trackNumber, this.title, required this.filePath, this.durationMs, required this.fileSizeBytes, required this.updatedAt, this.accurateRipStatus, this.accurateRipConfidence, this.accurateRipCrcV1, this.accurateRipCrcV2, this.peakLevel, this.trackQuality, this.copyCrc, this.clickCount, this.popCount, this.clippingCount, this.dropoutCount, this.defectConfidence, this.ripLogSource, this.qualityCheckedAt});
  

@override final  String id;
@override final  String ripAlbumId;
@override@JsonKey() final  int discNumber;
@override final  int trackNumber;
@override final  String? title;
@override final  String filePath;
@override final  int? durationMs;
@override final  int fileSizeBytes;
@override final  int updatedAt;
// Audio quality analysis fields (Phase B)
@override final  String? accurateRipStatus;
@override final  int? accurateRipConfidence;
@override final  String? accurateRipCrcV1;
@override final  String? accurateRipCrcV2;
@override final  double? peakLevel;
@override final  double? trackQuality;
@override final  String? copyCrc;
@override final  int? clickCount;
@override final  int? popCount;
@override final  int? clippingCount;
@override final  int? dropoutCount;
@override final  double? defectConfidence;
@override final  String? ripLogSource;
@override final  int? qualityCheckedAt;

/// Create a copy of RipTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RipTrackCopyWith<_RipTrack> get copyWith => __$RipTrackCopyWithImpl<_RipTrack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RipTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.ripAlbumId, ripAlbumId) || other.ripAlbumId == ripAlbumId)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.accurateRipStatus, accurateRipStatus) || other.accurateRipStatus == accurateRipStatus)&&(identical(other.accurateRipConfidence, accurateRipConfidence) || other.accurateRipConfidence == accurateRipConfidence)&&(identical(other.accurateRipCrcV1, accurateRipCrcV1) || other.accurateRipCrcV1 == accurateRipCrcV1)&&(identical(other.accurateRipCrcV2, accurateRipCrcV2) || other.accurateRipCrcV2 == accurateRipCrcV2)&&(identical(other.peakLevel, peakLevel) || other.peakLevel == peakLevel)&&(identical(other.trackQuality, trackQuality) || other.trackQuality == trackQuality)&&(identical(other.copyCrc, copyCrc) || other.copyCrc == copyCrc)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.popCount, popCount) || other.popCount == popCount)&&(identical(other.clippingCount, clippingCount) || other.clippingCount == clippingCount)&&(identical(other.dropoutCount, dropoutCount) || other.dropoutCount == dropoutCount)&&(identical(other.defectConfidence, defectConfidence) || other.defectConfidence == defectConfidence)&&(identical(other.ripLogSource, ripLogSource) || other.ripLogSource == ripLogSource)&&(identical(other.qualityCheckedAt, qualityCheckedAt) || other.qualityCheckedAt == qualityCheckedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,ripAlbumId,discNumber,trackNumber,title,filePath,durationMs,fileSizeBytes,updatedAt,accurateRipStatus,accurateRipConfidence,accurateRipCrcV1,accurateRipCrcV2,peakLevel,trackQuality,copyCrc,clickCount,popCount,clippingCount,dropoutCount,defectConfidence,ripLogSource,qualityCheckedAt]);

@override
String toString() {
  return 'RipTrack(id: $id, ripAlbumId: $ripAlbumId, discNumber: $discNumber, trackNumber: $trackNumber, title: $title, filePath: $filePath, durationMs: $durationMs, fileSizeBytes: $fileSizeBytes, updatedAt: $updatedAt, accurateRipStatus: $accurateRipStatus, accurateRipConfidence: $accurateRipConfidence, accurateRipCrcV1: $accurateRipCrcV1, accurateRipCrcV2: $accurateRipCrcV2, peakLevel: $peakLevel, trackQuality: $trackQuality, copyCrc: $copyCrc, clickCount: $clickCount, popCount: $popCount, clippingCount: $clippingCount, dropoutCount: $dropoutCount, defectConfidence: $defectConfidence, ripLogSource: $ripLogSource, qualityCheckedAt: $qualityCheckedAt)';
}


}

/// @nodoc
abstract mixin class _$RipTrackCopyWith<$Res> implements $RipTrackCopyWith<$Res> {
  factory _$RipTrackCopyWith(_RipTrack value, $Res Function(_RipTrack) _then) = __$RipTrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String ripAlbumId, int discNumber, int trackNumber, String? title, String filePath, int? durationMs, int fileSizeBytes, int updatedAt, String? accurateRipStatus, int? accurateRipConfidence, String? accurateRipCrcV1, String? accurateRipCrcV2, double? peakLevel, double? trackQuality, String? copyCrc, int? clickCount, int? popCount, int? clippingCount, int? dropoutCount, double? defectConfidence, String? ripLogSource, int? qualityCheckedAt
});




}
/// @nodoc
class __$RipTrackCopyWithImpl<$Res>
    implements _$RipTrackCopyWith<$Res> {
  __$RipTrackCopyWithImpl(this._self, this._then);

  final _RipTrack _self;
  final $Res Function(_RipTrack) _then;

/// Create a copy of RipTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ripAlbumId = null,Object? discNumber = null,Object? trackNumber = null,Object? title = freezed,Object? filePath = null,Object? durationMs = freezed,Object? fileSizeBytes = null,Object? updatedAt = null,Object? accurateRipStatus = freezed,Object? accurateRipConfidence = freezed,Object? accurateRipCrcV1 = freezed,Object? accurateRipCrcV2 = freezed,Object? peakLevel = freezed,Object? trackQuality = freezed,Object? copyCrc = freezed,Object? clickCount = freezed,Object? popCount = freezed,Object? clippingCount = freezed,Object? dropoutCount = freezed,Object? defectConfidence = freezed,Object? ripLogSource = freezed,Object? qualityCheckedAt = freezed,}) {
  return _then(_RipTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ripAlbumId: null == ripAlbumId ? _self.ripAlbumId : ripAlbumId // ignore: cast_nullable_to_non_nullable
as String,discNumber: null == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int,trackNumber: null == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,accurateRipStatus: freezed == accurateRipStatus ? _self.accurateRipStatus : accurateRipStatus // ignore: cast_nullable_to_non_nullable
as String?,accurateRipConfidence: freezed == accurateRipConfidence ? _self.accurateRipConfidence : accurateRipConfidence // ignore: cast_nullable_to_non_nullable
as int?,accurateRipCrcV1: freezed == accurateRipCrcV1 ? _self.accurateRipCrcV1 : accurateRipCrcV1 // ignore: cast_nullable_to_non_nullable
as String?,accurateRipCrcV2: freezed == accurateRipCrcV2 ? _self.accurateRipCrcV2 : accurateRipCrcV2 // ignore: cast_nullable_to_non_nullable
as String?,peakLevel: freezed == peakLevel ? _self.peakLevel : peakLevel // ignore: cast_nullable_to_non_nullable
as double?,trackQuality: freezed == trackQuality ? _self.trackQuality : trackQuality // ignore: cast_nullable_to_non_nullable
as double?,copyCrc: freezed == copyCrc ? _self.copyCrc : copyCrc // ignore: cast_nullable_to_non_nullable
as String?,clickCount: freezed == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int?,popCount: freezed == popCount ? _self.popCount : popCount // ignore: cast_nullable_to_non_nullable
as int?,clippingCount: freezed == clippingCount ? _self.clippingCount : clippingCount // ignore: cast_nullable_to_non_nullable
as int?,dropoutCount: freezed == dropoutCount ? _self.dropoutCount : dropoutCount // ignore: cast_nullable_to_non_nullable
as int?,defectConfidence: freezed == defectConfidence ? _self.defectConfidence : defectConfidence // ignore: cast_nullable_to_non_nullable
as double?,ripLogSource: freezed == ripLogSource ? _self.ripLogSource : ripLogSource // ignore: cast_nullable_to_non_nullable
as String?,qualityCheckedAt: freezed == qualityCheckedAt ? _self.qualityCheckedAt : qualityCheckedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
