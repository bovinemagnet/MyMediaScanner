// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaylistTrack {

 String get id; String get playlistId; String get ripTrackId; int get sortOrder; int get addedAt;
/// Create a copy of PlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistTrackCopyWith<PlaylistTrack> get copyWith => _$PlaylistTrackCopyWithImpl<PlaylistTrack>(this as PlaylistTrack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylistTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.playlistId, playlistId) || other.playlistId == playlistId)&&(identical(other.ripTrackId, ripTrackId) || other.ripTrackId == ripTrackId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,playlistId,ripTrackId,sortOrder,addedAt);

@override
String toString() {
  return 'PlaylistTrack(id: $id, playlistId: $playlistId, ripTrackId: $ripTrackId, sortOrder: $sortOrder, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $PlaylistTrackCopyWith<$Res>  {
  factory $PlaylistTrackCopyWith(PlaylistTrack value, $Res Function(PlaylistTrack) _then) = _$PlaylistTrackCopyWithImpl;
@useResult
$Res call({
 String id, String playlistId, String ripTrackId, int sortOrder, int addedAt
});




}
/// @nodoc
class _$PlaylistTrackCopyWithImpl<$Res>
    implements $PlaylistTrackCopyWith<$Res> {
  _$PlaylistTrackCopyWithImpl(this._self, this._then);

  final PlaylistTrack _self;
  final $Res Function(PlaylistTrack) _then;

/// Create a copy of PlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playlistId = null,Object? ripTrackId = null,Object? sortOrder = null,Object? addedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playlistId: null == playlistId ? _self.playlistId : playlistId // ignore: cast_nullable_to_non_nullable
as String,ripTrackId: null == ripTrackId ? _self.ripTrackId : ripTrackId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylistTrack].
extension PlaylistTrackPatterns on PlaylistTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylistTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylistTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylistTrack value)  $default,){
final _that = this;
switch (_that) {
case _PlaylistTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylistTrack value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylistTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playlistId,  String ripTrackId,  int sortOrder,  int addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylistTrack() when $default != null:
return $default(_that.id,_that.playlistId,_that.ripTrackId,_that.sortOrder,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playlistId,  String ripTrackId,  int sortOrder,  int addedAt)  $default,) {final _that = this;
switch (_that) {
case _PlaylistTrack():
return $default(_that.id,_that.playlistId,_that.ripTrackId,_that.sortOrder,_that.addedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playlistId,  String ripTrackId,  int sortOrder,  int addedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlaylistTrack() when $default != null:
return $default(_that.id,_that.playlistId,_that.ripTrackId,_that.sortOrder,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PlaylistTrack implements PlaylistTrack {
  const _PlaylistTrack({required this.id, required this.playlistId, required this.ripTrackId, required this.sortOrder, required this.addedAt});
  

@override final  String id;
@override final  String playlistId;
@override final  String ripTrackId;
@override final  int sortOrder;
@override final  int addedAt;

/// Create a copy of PlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistTrackCopyWith<_PlaylistTrack> get copyWith => __$PlaylistTrackCopyWithImpl<_PlaylistTrack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylistTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.playlistId, playlistId) || other.playlistId == playlistId)&&(identical(other.ripTrackId, ripTrackId) || other.ripTrackId == ripTrackId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,playlistId,ripTrackId,sortOrder,addedAt);

@override
String toString() {
  return 'PlaylistTrack(id: $id, playlistId: $playlistId, ripTrackId: $ripTrackId, sortOrder: $sortOrder, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$PlaylistTrackCopyWith<$Res> implements $PlaylistTrackCopyWith<$Res> {
  factory _$PlaylistTrackCopyWith(_PlaylistTrack value, $Res Function(_PlaylistTrack) _then) = __$PlaylistTrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String playlistId, String ripTrackId, int sortOrder, int addedAt
});




}
/// @nodoc
class __$PlaylistTrackCopyWithImpl<$Res>
    implements _$PlaylistTrackCopyWith<$Res> {
  __$PlaylistTrackCopyWithImpl(this._self, this._then);

  final _PlaylistTrack _self;
  final $Res Function(_PlaylistTrack) _then;

/// Create a copy of PlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playlistId = null,Object? ripTrackId = null,Object? sortOrder = null,Object? addedAt = null,}) {
  return _then(_PlaylistTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playlistId: null == playlistId ? _self.playlistId : playlistId // ignore: cast_nullable_to_non_nullable
as String,ripTrackId: null == ripTrackId ? _self.ripTrackId : ripTrackId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
