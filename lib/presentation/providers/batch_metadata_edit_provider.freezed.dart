// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_metadata_edit_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BatchMetadataEditState {

/// Current lifecycle status.
 BatchEditStatus get status;/// Map of trackId → (tagKey → newValue) for changes to be applied.
 Map<String, Map<String, String>> get pendingChanges;/// Map of trackId → (tagKey → oldValue) for undo support.
 Map<String, Map<String, String>> get originalValues;/// Number of individual tracks affected.
 int get affectedTrackCount;/// Number of albums affected.
 int get affectedAlbumCount;/// Error message if status is [BatchEditStatus.error].
 String? get error;
/// Create a copy of BatchMetadataEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchMetadataEditStateCopyWith<BatchMetadataEditState> get copyWith => _$BatchMetadataEditStateCopyWithImpl<BatchMetadataEditState>(this as BatchMetadataEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchMetadataEditState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.pendingChanges, pendingChanges)&&const DeepCollectionEquality().equals(other.originalValues, originalValues)&&(identical(other.affectedTrackCount, affectedTrackCount) || other.affectedTrackCount == affectedTrackCount)&&(identical(other.affectedAlbumCount, affectedAlbumCount) || other.affectedAlbumCount == affectedAlbumCount)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(pendingChanges),const DeepCollectionEquality().hash(originalValues),affectedTrackCount,affectedAlbumCount,error);

@override
String toString() {
  return 'BatchMetadataEditState(status: $status, pendingChanges: $pendingChanges, originalValues: $originalValues, affectedTrackCount: $affectedTrackCount, affectedAlbumCount: $affectedAlbumCount, error: $error)';
}


}

/// @nodoc
abstract mixin class $BatchMetadataEditStateCopyWith<$Res>  {
  factory $BatchMetadataEditStateCopyWith(BatchMetadataEditState value, $Res Function(BatchMetadataEditState) _then) = _$BatchMetadataEditStateCopyWithImpl;
@useResult
$Res call({
 BatchEditStatus status, Map<String, Map<String, String>> pendingChanges, Map<String, Map<String, String>> originalValues, int affectedTrackCount, int affectedAlbumCount, String? error
});




}
/// @nodoc
class _$BatchMetadataEditStateCopyWithImpl<$Res>
    implements $BatchMetadataEditStateCopyWith<$Res> {
  _$BatchMetadataEditStateCopyWithImpl(this._self, this._then);

  final BatchMetadataEditState _self;
  final $Res Function(BatchMetadataEditState) _then;

/// Create a copy of BatchMetadataEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? pendingChanges = null,Object? originalValues = null,Object? affectedTrackCount = null,Object? affectedAlbumCount = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchEditStatus,pendingChanges: null == pendingChanges ? _self.pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,originalValues: null == originalValues ? _self.originalValues : originalValues // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,affectedTrackCount: null == affectedTrackCount ? _self.affectedTrackCount : affectedTrackCount // ignore: cast_nullable_to_non_nullable
as int,affectedAlbumCount: null == affectedAlbumCount ? _self.affectedAlbumCount : affectedAlbumCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchMetadataEditState].
extension BatchMetadataEditStatePatterns on BatchMetadataEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchMetadataEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchMetadataEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchMetadataEditState value)  $default,){
final _that = this;
switch (_that) {
case _BatchMetadataEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchMetadataEditState value)?  $default,){
final _that = this;
switch (_that) {
case _BatchMetadataEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BatchEditStatus status,  Map<String, Map<String, String>> pendingChanges,  Map<String, Map<String, String>> originalValues,  int affectedTrackCount,  int affectedAlbumCount,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchMetadataEditState() when $default != null:
return $default(_that.status,_that.pendingChanges,_that.originalValues,_that.affectedTrackCount,_that.affectedAlbumCount,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BatchEditStatus status,  Map<String, Map<String, String>> pendingChanges,  Map<String, Map<String, String>> originalValues,  int affectedTrackCount,  int affectedAlbumCount,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BatchMetadataEditState():
return $default(_that.status,_that.pendingChanges,_that.originalValues,_that.affectedTrackCount,_that.affectedAlbumCount,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BatchEditStatus status,  Map<String, Map<String, String>> pendingChanges,  Map<String, Map<String, String>> originalValues,  int affectedTrackCount,  int affectedAlbumCount,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BatchMetadataEditState() when $default != null:
return $default(_that.status,_that.pendingChanges,_that.originalValues,_that.affectedTrackCount,_that.affectedAlbumCount,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _BatchMetadataEditState implements BatchMetadataEditState {
  const _BatchMetadataEditState({this.status = BatchEditStatus.idle, final  Map<String, Map<String, String>> pendingChanges = const {}, final  Map<String, Map<String, String>> originalValues = const {}, this.affectedTrackCount = 0, this.affectedAlbumCount = 0, this.error}): _pendingChanges = pendingChanges,_originalValues = originalValues;
  

/// Current lifecycle status.
@override@JsonKey() final  BatchEditStatus status;
/// Map of trackId → (tagKey → newValue) for changes to be applied.
 final  Map<String, Map<String, String>> _pendingChanges;
/// Map of trackId → (tagKey → newValue) for changes to be applied.
@override@JsonKey() Map<String, Map<String, String>> get pendingChanges {
  if (_pendingChanges is EqualUnmodifiableMapView) return _pendingChanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pendingChanges);
}

/// Map of trackId → (tagKey → oldValue) for undo support.
 final  Map<String, Map<String, String>> _originalValues;
/// Map of trackId → (tagKey → oldValue) for undo support.
@override@JsonKey() Map<String, Map<String, String>> get originalValues {
  if (_originalValues is EqualUnmodifiableMapView) return _originalValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_originalValues);
}

/// Number of individual tracks affected.
@override@JsonKey() final  int affectedTrackCount;
/// Number of albums affected.
@override@JsonKey() final  int affectedAlbumCount;
/// Error message if status is [BatchEditStatus.error].
@override final  String? error;

/// Create a copy of BatchMetadataEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchMetadataEditStateCopyWith<_BatchMetadataEditState> get copyWith => __$BatchMetadataEditStateCopyWithImpl<_BatchMetadataEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchMetadataEditState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._pendingChanges, _pendingChanges)&&const DeepCollectionEquality().equals(other._originalValues, _originalValues)&&(identical(other.affectedTrackCount, affectedTrackCount) || other.affectedTrackCount == affectedTrackCount)&&(identical(other.affectedAlbumCount, affectedAlbumCount) || other.affectedAlbumCount == affectedAlbumCount)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_pendingChanges),const DeepCollectionEquality().hash(_originalValues),affectedTrackCount,affectedAlbumCount,error);

@override
String toString() {
  return 'BatchMetadataEditState(status: $status, pendingChanges: $pendingChanges, originalValues: $originalValues, affectedTrackCount: $affectedTrackCount, affectedAlbumCount: $affectedAlbumCount, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BatchMetadataEditStateCopyWith<$Res> implements $BatchMetadataEditStateCopyWith<$Res> {
  factory _$BatchMetadataEditStateCopyWith(_BatchMetadataEditState value, $Res Function(_BatchMetadataEditState) _then) = __$BatchMetadataEditStateCopyWithImpl;
@override @useResult
$Res call({
 BatchEditStatus status, Map<String, Map<String, String>> pendingChanges, Map<String, Map<String, String>> originalValues, int affectedTrackCount, int affectedAlbumCount, String? error
});




}
/// @nodoc
class __$BatchMetadataEditStateCopyWithImpl<$Res>
    implements _$BatchMetadataEditStateCopyWith<$Res> {
  __$BatchMetadataEditStateCopyWithImpl(this._self, this._then);

  final _BatchMetadataEditState _self;
  final $Res Function(_BatchMetadataEditState) _then;

/// Create a copy of BatchMetadataEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? pendingChanges = null,Object? originalValues = null,Object? affectedTrackCount = null,Object? affectedAlbumCount = null,Object? error = freezed,}) {
  return _then(_BatchMetadataEditState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchEditStatus,pendingChanges: null == pendingChanges ? _self._pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,originalValues: null == originalValues ? _self._originalValues : originalValues // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, String>>,affectedTrackCount: null == affectedTrackCount ? _self.affectedTrackCount : affectedTrackCount // ignore: cast_nullable_to_non_nullable
as int,affectedAlbumCount: null == affectedAlbumCount ? _self.affectedAlbumCount : affectedAlbumCount // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
