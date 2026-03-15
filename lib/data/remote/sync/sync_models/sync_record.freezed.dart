// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncRecord {

 String get entityType; String get entityId; String get operation; Map<String, dynamic> get payload; int get createdAt;
/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncRecordCopyWith<SyncRecord> get copyWith => _$SyncRecordCopyWithImpl<SyncRecord>(this as SyncRecord, _$identity);

  /// Serializes this SyncRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncRecord&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,entityId,operation,const DeepCollectionEquality().hash(payload),createdAt);

@override
String toString() {
  return 'SyncRecord(entityType: $entityType, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SyncRecordCopyWith<$Res>  {
  factory $SyncRecordCopyWith(SyncRecord value, $Res Function(SyncRecord) _then) = _$SyncRecordCopyWithImpl;
@useResult
$Res call({
 String entityType, String entityId, String operation, Map<String, dynamic> payload, int createdAt
});




}
/// @nodoc
class _$SyncRecordCopyWithImpl<$Res>
    implements $SyncRecordCopyWith<$Res> {
  _$SyncRecordCopyWithImpl(this._self, this._then);

  final SyncRecord _self;
  final $Res Function(SyncRecord) _then;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncRecord].
extension SyncRecordPatterns on SyncRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncRecord value)  $default,){
final _that = this;
switch (_that) {
case _SyncRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityType,  String entityId,  String operation,  Map<String, dynamic> payload,  int createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
return $default(_that.entityType,_that.entityId,_that.operation,_that.payload,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityType,  String entityId,  String operation,  Map<String, dynamic> payload,  int createdAt)  $default,) {final _that = this;
switch (_that) {
case _SyncRecord():
return $default(_that.entityType,_that.entityId,_that.operation,_that.payload,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityType,  String entityId,  String operation,  Map<String, dynamic> payload,  int createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SyncRecord() when $default != null:
return $default(_that.entityType,_that.entityId,_that.operation,_that.payload,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncRecord implements SyncRecord {
  const _SyncRecord({required this.entityType, required this.entityId, required this.operation, required final  Map<String, dynamic> payload, required this.createdAt}): _payload = payload;
  factory _SyncRecord.fromJson(Map<String, dynamic> json) => _$SyncRecordFromJson(json);

@override final  String entityType;
@override final  String entityId;
@override final  String operation;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  int createdAt;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncRecordCopyWith<_SyncRecord> get copyWith => __$SyncRecordCopyWithImpl<_SyncRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncRecord&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,entityId,operation,const DeepCollectionEquality().hash(_payload),createdAt);

@override
String toString() {
  return 'SyncRecord(entityType: $entityType, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SyncRecordCopyWith<$Res> implements $SyncRecordCopyWith<$Res> {
  factory _$SyncRecordCopyWith(_SyncRecord value, $Res Function(_SyncRecord) _then) = __$SyncRecordCopyWithImpl;
@override @useResult
$Res call({
 String entityType, String entityId, String operation, Map<String, dynamic> payload, int createdAt
});




}
/// @nodoc
class __$SyncRecordCopyWithImpl<$Res>
    implements _$SyncRecordCopyWith<$Res> {
  __$SyncRecordCopyWithImpl(this._self, this._then);

  final _SyncRecord _self;
  final $Res Function(_SyncRecord) _then;

/// Create a copy of SyncRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? entityId = null,Object? operation = null,Object? payload = null,Object? createdAt = null,}) {
  return _then(_SyncRecord(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
