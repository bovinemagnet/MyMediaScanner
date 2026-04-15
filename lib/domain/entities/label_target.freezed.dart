// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabelTarget {

 String get qrPayload; String get title; String? get subtitle;
/// Create a copy of LabelTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelTargetCopyWith<LabelTarget> get copyWith => _$LabelTargetCopyWithImpl<LabelTarget>(this as LabelTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelTarget&&(identical(other.qrPayload, qrPayload) || other.qrPayload == qrPayload)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle));
}


@override
int get hashCode => Object.hash(runtimeType,qrPayload,title,subtitle);

@override
String toString() {
  return 'LabelTarget(qrPayload: $qrPayload, title: $title, subtitle: $subtitle)';
}


}

/// @nodoc
abstract mixin class $LabelTargetCopyWith<$Res>  {
  factory $LabelTargetCopyWith(LabelTarget value, $Res Function(LabelTarget) _then) = _$LabelTargetCopyWithImpl;
@useResult
$Res call({
 String qrPayload, String title, String? subtitle
});




}
/// @nodoc
class _$LabelTargetCopyWithImpl<$Res>
    implements $LabelTargetCopyWith<$Res> {
  _$LabelTargetCopyWithImpl(this._self, this._then);

  final LabelTarget _self;
  final $Res Function(LabelTarget) _then;

/// Create a copy of LabelTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qrPayload = null,Object? title = null,Object? subtitle = freezed,}) {
  return _then(_self.copyWith(
qrPayload: null == qrPayload ? _self.qrPayload : qrPayload // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelTarget].
extension LabelTargetPatterns on LabelTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelTarget value)  $default,){
final _that = this;
switch (_that) {
case _LabelTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelTarget value)?  $default,){
final _that = this;
switch (_that) {
case _LabelTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String qrPayload,  String title,  String? subtitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelTarget() when $default != null:
return $default(_that.qrPayload,_that.title,_that.subtitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String qrPayload,  String title,  String? subtitle)  $default,) {final _that = this;
switch (_that) {
case _LabelTarget():
return $default(_that.qrPayload,_that.title,_that.subtitle);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String qrPayload,  String title,  String? subtitle)?  $default,) {final _that = this;
switch (_that) {
case _LabelTarget() when $default != null:
return $default(_that.qrPayload,_that.title,_that.subtitle);case _:
  return null;

}
}

}

/// @nodoc


class _LabelTarget implements LabelTarget {
  const _LabelTarget({required this.qrPayload, required this.title, this.subtitle});
  

@override final  String qrPayload;
@override final  String title;
@override final  String? subtitle;

/// Create a copy of LabelTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelTargetCopyWith<_LabelTarget> get copyWith => __$LabelTargetCopyWithImpl<_LabelTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelTarget&&(identical(other.qrPayload, qrPayload) || other.qrPayload == qrPayload)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle));
}


@override
int get hashCode => Object.hash(runtimeType,qrPayload,title,subtitle);

@override
String toString() {
  return 'LabelTarget(qrPayload: $qrPayload, title: $title, subtitle: $subtitle)';
}


}

/// @nodoc
abstract mixin class _$LabelTargetCopyWith<$Res> implements $LabelTargetCopyWith<$Res> {
  factory _$LabelTargetCopyWith(_LabelTarget value, $Res Function(_LabelTarget) _then) = __$LabelTargetCopyWithImpl;
@override @useResult
$Res call({
 String qrPayload, String title, String? subtitle
});




}
/// @nodoc
class __$LabelTargetCopyWithImpl<$Res>
    implements _$LabelTargetCopyWith<$Res> {
  __$LabelTargetCopyWithImpl(this._self, this._then);

  final _LabelTarget _self;
  final $Res Function(_LabelTarget) _then;

/// Create a copy of LabelTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qrPayload = null,Object? title = null,Object? subtitle = freezed,}) {
  return _then(_LabelTarget(
qrPayload: null == qrPayload ? _self.qrPayload : qrPayload // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
