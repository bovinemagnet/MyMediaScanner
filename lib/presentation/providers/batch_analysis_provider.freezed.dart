// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_analysis_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BatchAnalysisState {

 BatchStatus get status; Map<String, AlbumAnalysisStatus> get albumStatuses; bool get usingNativeDecoder;
/// Create a copy of BatchAnalysisState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchAnalysisStateCopyWith<BatchAnalysisState> get copyWith => _$BatchAnalysisStateCopyWithImpl<BatchAnalysisState>(this as BatchAnalysisState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchAnalysisState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.albumStatuses, albumStatuses)&&(identical(other.usingNativeDecoder, usingNativeDecoder) || other.usingNativeDecoder == usingNativeDecoder));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(albumStatuses),usingNativeDecoder);

@override
String toString() {
  return 'BatchAnalysisState(status: $status, albumStatuses: $albumStatuses, usingNativeDecoder: $usingNativeDecoder)';
}


}

/// @nodoc
abstract mixin class $BatchAnalysisStateCopyWith<$Res>  {
  factory $BatchAnalysisStateCopyWith(BatchAnalysisState value, $Res Function(BatchAnalysisState) _then) = _$BatchAnalysisStateCopyWithImpl;
@useResult
$Res call({
 BatchStatus status, Map<String, AlbumAnalysisStatus> albumStatuses, bool usingNativeDecoder
});




}
/// @nodoc
class _$BatchAnalysisStateCopyWithImpl<$Res>
    implements $BatchAnalysisStateCopyWith<$Res> {
  _$BatchAnalysisStateCopyWithImpl(this._self, this._then);

  final BatchAnalysisState _self;
  final $Res Function(BatchAnalysisState) _then;

/// Create a copy of BatchAnalysisState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? albumStatuses = null,Object? usingNativeDecoder = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,albumStatuses: null == albumStatuses ? _self.albumStatuses : albumStatuses // ignore: cast_nullable_to_non_nullable
as Map<String, AlbumAnalysisStatus>,usingNativeDecoder: null == usingNativeDecoder ? _self.usingNativeDecoder : usingNativeDecoder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchAnalysisState].
extension BatchAnalysisStatePatterns on BatchAnalysisState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchAnalysisState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchAnalysisState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchAnalysisState value)  $default,){
final _that = this;
switch (_that) {
case _BatchAnalysisState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchAnalysisState value)?  $default,){
final _that = this;
switch (_that) {
case _BatchAnalysisState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BatchStatus status,  Map<String, AlbumAnalysisStatus> albumStatuses,  bool usingNativeDecoder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchAnalysisState() when $default != null:
return $default(_that.status,_that.albumStatuses,_that.usingNativeDecoder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BatchStatus status,  Map<String, AlbumAnalysisStatus> albumStatuses,  bool usingNativeDecoder)  $default,) {final _that = this;
switch (_that) {
case _BatchAnalysisState():
return $default(_that.status,_that.albumStatuses,_that.usingNativeDecoder);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BatchStatus status,  Map<String, AlbumAnalysisStatus> albumStatuses,  bool usingNativeDecoder)?  $default,) {final _that = this;
switch (_that) {
case _BatchAnalysisState() when $default != null:
return $default(_that.status,_that.albumStatuses,_that.usingNativeDecoder);case _:
  return null;

}
}

}

/// @nodoc


class _BatchAnalysisState implements BatchAnalysisState {
  const _BatchAnalysisState({this.status = BatchStatus.idle, final  Map<String, AlbumAnalysisStatus> albumStatuses = const {}, this.usingNativeDecoder = false}): _albumStatuses = albumStatuses;
  

@override@JsonKey() final  BatchStatus status;
 final  Map<String, AlbumAnalysisStatus> _albumStatuses;
@override@JsonKey() Map<String, AlbumAnalysisStatus> get albumStatuses {
  if (_albumStatuses is EqualUnmodifiableMapView) return _albumStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_albumStatuses);
}

@override@JsonKey() final  bool usingNativeDecoder;

/// Create a copy of BatchAnalysisState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchAnalysisStateCopyWith<_BatchAnalysisState> get copyWith => __$BatchAnalysisStateCopyWithImpl<_BatchAnalysisState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchAnalysisState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._albumStatuses, _albumStatuses)&&(identical(other.usingNativeDecoder, usingNativeDecoder) || other.usingNativeDecoder == usingNativeDecoder));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_albumStatuses),usingNativeDecoder);

@override
String toString() {
  return 'BatchAnalysisState(status: $status, albumStatuses: $albumStatuses, usingNativeDecoder: $usingNativeDecoder)';
}


}

/// @nodoc
abstract mixin class _$BatchAnalysisStateCopyWith<$Res> implements $BatchAnalysisStateCopyWith<$Res> {
  factory _$BatchAnalysisStateCopyWith(_BatchAnalysisState value, $Res Function(_BatchAnalysisState) _then) = __$BatchAnalysisStateCopyWithImpl;
@override @useResult
$Res call({
 BatchStatus status, Map<String, AlbumAnalysisStatus> albumStatuses, bool usingNativeDecoder
});




}
/// @nodoc
class __$BatchAnalysisStateCopyWithImpl<$Res>
    implements _$BatchAnalysisStateCopyWith<$Res> {
  __$BatchAnalysisStateCopyWithImpl(this._self, this._then);

  final _BatchAnalysisState _self;
  final $Res Function(_BatchAnalysisState) _then;

/// Create a copy of BatchAnalysisState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? albumStatuses = null,Object? usingNativeDecoder = null,}) {
  return _then(_BatchAnalysisState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,albumStatuses: null == albumStatuses ? _self._albumStatuses : albumStatuses // ignore: cast_nullable_to_non_nullable
as Map<String, AlbumAnalysisStatus>,usingNativeDecoder: null == usingNativeDecoder ? _self.usingNativeDecoder : usingNativeDecoder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
