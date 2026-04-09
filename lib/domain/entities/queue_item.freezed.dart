// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueueItem {

 RipAlbum get album; RipTrack get track; QueueItemSource get source;
/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueItemCopyWith<QueueItem> get copyWith => _$QueueItemCopyWithImpl<QueueItem>(this as QueueItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueItem&&(identical(other.album, album) || other.album == album)&&(identical(other.track, track) || other.track == track)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,album,track,source);

@override
String toString() {
  return 'QueueItem(album: $album, track: $track, source: $source)';
}


}

/// @nodoc
abstract mixin class $QueueItemCopyWith<$Res>  {
  factory $QueueItemCopyWith(QueueItem value, $Res Function(QueueItem) _then) = _$QueueItemCopyWithImpl;
@useResult
$Res call({
 RipAlbum album, RipTrack track, QueueItemSource source
});


$RipAlbumCopyWith<$Res> get album;$RipTrackCopyWith<$Res> get track;

}
/// @nodoc
class _$QueueItemCopyWithImpl<$Res>
    implements $QueueItemCopyWith<$Res> {
  _$QueueItemCopyWithImpl(this._self, this._then);

  final QueueItem _self;
  final $Res Function(QueueItem) _then;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? album = null,Object? track = null,Object? source = null,}) {
  return _then(_self.copyWith(
album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as RipAlbum,track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as RipTrack,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QueueItemSource,
  ));
}
/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RipAlbumCopyWith<$Res> get album {
  
  return $RipAlbumCopyWith<$Res>(_self.album, (value) {
    return _then(_self.copyWith(album: value));
  });
}/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RipTrackCopyWith<$Res> get track {
  
  return $RipTrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}


/// Adds pattern-matching-related methods to [QueueItem].
extension QueueItemPatterns on QueueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueItem value)  $default,){
final _that = this;
switch (_that) {
case _QueueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueItem value)?  $default,){
final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RipAlbum album,  RipTrack track,  QueueItemSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
return $default(_that.album,_that.track,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RipAlbum album,  RipTrack track,  QueueItemSource source)  $default,) {final _that = this;
switch (_that) {
case _QueueItem():
return $default(_that.album,_that.track,_that.source);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RipAlbum album,  RipTrack track,  QueueItemSource source)?  $default,) {final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
return $default(_that.album,_that.track,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _QueueItem implements QueueItem {
  const _QueueItem({required this.album, required this.track, this.source = QueueItemSource.manual});
  

@override final  RipAlbum album;
@override final  RipTrack track;
@override@JsonKey() final  QueueItemSource source;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueItemCopyWith<_QueueItem> get copyWith => __$QueueItemCopyWithImpl<_QueueItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueItem&&(identical(other.album, album) || other.album == album)&&(identical(other.track, track) || other.track == track)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,album,track,source);

@override
String toString() {
  return 'QueueItem(album: $album, track: $track, source: $source)';
}


}

/// @nodoc
abstract mixin class _$QueueItemCopyWith<$Res> implements $QueueItemCopyWith<$Res> {
  factory _$QueueItemCopyWith(_QueueItem value, $Res Function(_QueueItem) _then) = __$QueueItemCopyWithImpl;
@override @useResult
$Res call({
 RipAlbum album, RipTrack track, QueueItemSource source
});


@override $RipAlbumCopyWith<$Res> get album;@override $RipTrackCopyWith<$Res> get track;

}
/// @nodoc
class __$QueueItemCopyWithImpl<$Res>
    implements _$QueueItemCopyWith<$Res> {
  __$QueueItemCopyWithImpl(this._self, this._then);

  final _QueueItem _self;
  final $Res Function(_QueueItem) _then;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? album = null,Object? track = null,Object? source = null,}) {
  return _then(_QueueItem(
album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as RipAlbum,track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as RipTrack,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QueueItemSource,
  ));
}

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RipAlbumCopyWith<$Res> get album {
  
  return $RipAlbumCopyWith<$Res>(_self.album, (value) {
    return _then(_self.copyWith(album: value));
  });
}/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RipTrackCopyWith<$Res> get track {
  
  return $RipTrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}

// dart format on
