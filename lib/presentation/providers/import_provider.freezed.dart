// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportState {

 ImportPhase get phase; ImportSource? get source; List<ImportRow> get rows; int get enrichedCount; int get savedCount; String? get errorMessage;
/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportStateCopyWith<ImportState> get copyWith => _$ImportStateCopyWithImpl<ImportState>(this as ImportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.enrichedCount, enrichedCount) || other.enrichedCount == enrichedCount)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,phase,source,const DeepCollectionEquality().hash(rows),enrichedCount,savedCount,errorMessage);

@override
String toString() {
  return 'ImportState(phase: $phase, source: $source, rows: $rows, enrichedCount: $enrichedCount, savedCount: $savedCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ImportStateCopyWith<$Res>  {
  factory $ImportStateCopyWith(ImportState value, $Res Function(ImportState) _then) = _$ImportStateCopyWithImpl;
@useResult
$Res call({
 ImportPhase phase, ImportSource? source, List<ImportRow> rows, int enrichedCount, int savedCount, String? errorMessage
});




}
/// @nodoc
class _$ImportStateCopyWithImpl<$Res>
    implements $ImportStateCopyWith<$Res> {
  _$ImportStateCopyWithImpl(this._self, this._then);

  final ImportState _self;
  final $Res Function(ImportState) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? source = freezed,Object? rows = null,Object? enrichedCount = null,Object? savedCount = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ImportPhase,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource?,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ImportRow>,enrichedCount: null == enrichedCount ? _self.enrichedCount : enrichedCount // ignore: cast_nullable_to_non_nullable
as int,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportState].
extension ImportStatePatterns on ImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportState value)  $default,){
final _that = this;
switch (_that) {
case _ImportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportState value)?  $default,){
final _that = this;
switch (_that) {
case _ImportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImportPhase phase,  ImportSource? source,  List<ImportRow> rows,  int enrichedCount,  int savedCount,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportState() when $default != null:
return $default(_that.phase,_that.source,_that.rows,_that.enrichedCount,_that.savedCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImportPhase phase,  ImportSource? source,  List<ImportRow> rows,  int enrichedCount,  int savedCount,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ImportState():
return $default(_that.phase,_that.source,_that.rows,_that.enrichedCount,_that.savedCount,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImportPhase phase,  ImportSource? source,  List<ImportRow> rows,  int enrichedCount,  int savedCount,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ImportState() when $default != null:
return $default(_that.phase,_that.source,_that.rows,_that.enrichedCount,_that.savedCount,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ImportState implements ImportState {
  const _ImportState({this.phase = ImportPhase.idle, this.source, final  List<ImportRow> rows = const [], this.enrichedCount = 0, this.savedCount = 0, this.errorMessage}): _rows = rows;
  

@override@JsonKey() final  ImportPhase phase;
@override final  ImportSource? source;
 final  List<ImportRow> _rows;
@override@JsonKey() List<ImportRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

@override@JsonKey() final  int enrichedCount;
@override@JsonKey() final  int savedCount;
@override final  String? errorMessage;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportStateCopyWith<_ImportState> get copyWith => __$ImportStateCopyWithImpl<_ImportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.enrichedCount, enrichedCount) || other.enrichedCount == enrichedCount)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,phase,source,const DeepCollectionEquality().hash(_rows),enrichedCount,savedCount,errorMessage);

@override
String toString() {
  return 'ImportState(phase: $phase, source: $source, rows: $rows, enrichedCount: $enrichedCount, savedCount: $savedCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ImportStateCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory _$ImportStateCopyWith(_ImportState value, $Res Function(_ImportState) _then) = __$ImportStateCopyWithImpl;
@override @useResult
$Res call({
 ImportPhase phase, ImportSource? source, List<ImportRow> rows, int enrichedCount, int savedCount, String? errorMessage
});




}
/// @nodoc
class __$ImportStateCopyWithImpl<$Res>
    implements _$ImportStateCopyWith<$Res> {
  __$ImportStateCopyWithImpl(this._self, this._then);

  final _ImportState _self;
  final $Res Function(_ImportState) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? source = freezed,Object? rows = null,Object? enrichedCount = null,Object? savedCount = null,Object? errorMessage = freezed,}) {
  return _then(_ImportState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ImportPhase,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource?,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ImportRow>,enrichedCount: null == enrichedCount ? _self.enrichedCount : enrichedCount // ignore: cast_nullable_to_non_nullable
as int,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
