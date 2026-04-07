// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_conflict.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncConflict {

 String get entityType; String get entityId; String get fieldName; dynamic get localValue; dynamic get remoteValue; int get localUpdatedAt; int get remoteUpdatedAt; ConflictResolution get resolution;
/// Create a copy of SyncConflict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncConflictCopyWith<SyncConflict> get copyWith => _$SyncConflictCopyWithImpl<SyncConflict>(this as SyncConflict, _$identity);

  /// Serializes this SyncConflict to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncConflict&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.fieldName, fieldName) || other.fieldName == fieldName)&&const DeepCollectionEquality().equals(other.localValue, localValue)&&const DeepCollectionEquality().equals(other.remoteValue, remoteValue)&&(identical(other.localUpdatedAt, localUpdatedAt) || other.localUpdatedAt == localUpdatedAt)&&(identical(other.remoteUpdatedAt, remoteUpdatedAt) || other.remoteUpdatedAt == remoteUpdatedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,entityId,fieldName,const DeepCollectionEquality().hash(localValue),const DeepCollectionEquality().hash(remoteValue),localUpdatedAt,remoteUpdatedAt,resolution);

@override
String toString() {
  return 'SyncConflict(entityType: $entityType, entityId: $entityId, fieldName: $fieldName, localValue: $localValue, remoteValue: $remoteValue, localUpdatedAt: $localUpdatedAt, remoteUpdatedAt: $remoteUpdatedAt, resolution: $resolution)';
}


}

/// @nodoc
abstract mixin class $SyncConflictCopyWith<$Res>  {
  factory $SyncConflictCopyWith(SyncConflict value, $Res Function(SyncConflict) _then) = _$SyncConflictCopyWithImpl;
@useResult
$Res call({
 String entityType, String entityId, String fieldName, dynamic localValue, dynamic remoteValue, int localUpdatedAt, int remoteUpdatedAt, ConflictResolution resolution
});




}
/// @nodoc
class _$SyncConflictCopyWithImpl<$Res>
    implements $SyncConflictCopyWith<$Res> {
  _$SyncConflictCopyWithImpl(this._self, this._then);

  final SyncConflict _self;
  final $Res Function(SyncConflict) _then;

/// Create a copy of SyncConflict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? entityId = null,Object? fieldName = null,Object? localValue = freezed,Object? remoteValue = freezed,Object? localUpdatedAt = null,Object? remoteUpdatedAt = null,Object? resolution = null,}) {
  return _then(_self.copyWith(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,fieldName: null == fieldName ? _self.fieldName : fieldName // ignore: cast_nullable_to_non_nullable
as String,localValue: freezed == localValue ? _self.localValue : localValue // ignore: cast_nullable_to_non_nullable
as dynamic,remoteValue: freezed == remoteValue ? _self.remoteValue : remoteValue // ignore: cast_nullable_to_non_nullable
as dynamic,localUpdatedAt: null == localUpdatedAt ? _self.localUpdatedAt : localUpdatedAt // ignore: cast_nullable_to_non_nullable
as int,remoteUpdatedAt: null == remoteUpdatedAt ? _self.remoteUpdatedAt : remoteUpdatedAt // ignore: cast_nullable_to_non_nullable
as int,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as ConflictResolution,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncConflict].
extension SyncConflictPatterns on SyncConflict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncConflict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncConflict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncConflict value)  $default,){
final _that = this;
switch (_that) {
case _SyncConflict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncConflict value)?  $default,){
final _that = this;
switch (_that) {
case _SyncConflict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityType,  String entityId,  String fieldName,  dynamic localValue,  dynamic remoteValue,  int localUpdatedAt,  int remoteUpdatedAt,  ConflictResolution resolution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncConflict() when $default != null:
return $default(_that.entityType,_that.entityId,_that.fieldName,_that.localValue,_that.remoteValue,_that.localUpdatedAt,_that.remoteUpdatedAt,_that.resolution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityType,  String entityId,  String fieldName,  dynamic localValue,  dynamic remoteValue,  int localUpdatedAt,  int remoteUpdatedAt,  ConflictResolution resolution)  $default,) {final _that = this;
switch (_that) {
case _SyncConflict():
return $default(_that.entityType,_that.entityId,_that.fieldName,_that.localValue,_that.remoteValue,_that.localUpdatedAt,_that.remoteUpdatedAt,_that.resolution);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityType,  String entityId,  String fieldName,  dynamic localValue,  dynamic remoteValue,  int localUpdatedAt,  int remoteUpdatedAt,  ConflictResolution resolution)?  $default,) {final _that = this;
switch (_that) {
case _SyncConflict() when $default != null:
return $default(_that.entityType,_that.entityId,_that.fieldName,_that.localValue,_that.remoteValue,_that.localUpdatedAt,_that.remoteUpdatedAt,_that.resolution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncConflict implements SyncConflict {
  const _SyncConflict({required this.entityType, required this.entityId, required this.fieldName, required this.localValue, required this.remoteValue, required this.localUpdatedAt, required this.remoteUpdatedAt, this.resolution = ConflictResolution.keepLocal});
  factory _SyncConflict.fromJson(Map<String, dynamic> json) => _$SyncConflictFromJson(json);

@override final  String entityType;
@override final  String entityId;
@override final  String fieldName;
@override final  dynamic localValue;
@override final  dynamic remoteValue;
@override final  int localUpdatedAt;
@override final  int remoteUpdatedAt;
@override@JsonKey() final  ConflictResolution resolution;

/// Create a copy of SyncConflict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncConflictCopyWith<_SyncConflict> get copyWith => __$SyncConflictCopyWithImpl<_SyncConflict>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncConflictToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncConflict&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.fieldName, fieldName) || other.fieldName == fieldName)&&const DeepCollectionEquality().equals(other.localValue, localValue)&&const DeepCollectionEquality().equals(other.remoteValue, remoteValue)&&(identical(other.localUpdatedAt, localUpdatedAt) || other.localUpdatedAt == localUpdatedAt)&&(identical(other.remoteUpdatedAt, remoteUpdatedAt) || other.remoteUpdatedAt == remoteUpdatedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,entityId,fieldName,const DeepCollectionEquality().hash(localValue),const DeepCollectionEquality().hash(remoteValue),localUpdatedAt,remoteUpdatedAt,resolution);

@override
String toString() {
  return 'SyncConflict(entityType: $entityType, entityId: $entityId, fieldName: $fieldName, localValue: $localValue, remoteValue: $remoteValue, localUpdatedAt: $localUpdatedAt, remoteUpdatedAt: $remoteUpdatedAt, resolution: $resolution)';
}


}

/// @nodoc
abstract mixin class _$SyncConflictCopyWith<$Res> implements $SyncConflictCopyWith<$Res> {
  factory _$SyncConflictCopyWith(_SyncConflict value, $Res Function(_SyncConflict) _then) = __$SyncConflictCopyWithImpl;
@override @useResult
$Res call({
 String entityType, String entityId, String fieldName, dynamic localValue, dynamic remoteValue, int localUpdatedAt, int remoteUpdatedAt, ConflictResolution resolution
});




}
/// @nodoc
class __$SyncConflictCopyWithImpl<$Res>
    implements _$SyncConflictCopyWith<$Res> {
  __$SyncConflictCopyWithImpl(this._self, this._then);

  final _SyncConflict _self;
  final $Res Function(_SyncConflict) _then;

/// Create a copy of SyncConflict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? entityId = null,Object? fieldName = null,Object? localValue = freezed,Object? remoteValue = freezed,Object? localUpdatedAt = null,Object? remoteUpdatedAt = null,Object? resolution = null,}) {
  return _then(_SyncConflict(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,fieldName: null == fieldName ? _self.fieldName : fieldName // ignore: cast_nullable_to_non_nullable
as String,localValue: freezed == localValue ? _self.localValue : localValue // ignore: cast_nullable_to_non_nullable
as dynamic,remoteValue: freezed == remoteValue ? _self.remoteValue : remoteValue // ignore: cast_nullable_to_non_nullable
as dynamic,localUpdatedAt: null == localUpdatedAt ? _self.localUpdatedAt : localUpdatedAt // ignore: cast_nullable_to_non_nullable
as int,remoteUpdatedAt: null == remoteUpdatedAt ? _self.remoteUpdatedAt : remoteUpdatedAt // ignore: cast_nullable_to_non_nullable
as int,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as ConflictResolution,
  ));
}


}

// dart format on
