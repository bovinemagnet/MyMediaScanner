// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OcrTextBlock {

 String get text; double get confidence; double get area;
/// Create a copy of OcrTextBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrTextBlockCopyWith<OcrTextBlock> get copyWith => _$OcrTextBlockCopyWithImpl<OcrTextBlock>(this as OcrTextBlock, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrTextBlock&&(identical(other.text, text) || other.text == text)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,text,confidence,area);

@override
String toString() {
  return 'OcrTextBlock(text: $text, confidence: $confidence, area: $area)';
}


}

/// @nodoc
abstract mixin class $OcrTextBlockCopyWith<$Res>  {
  factory $OcrTextBlockCopyWith(OcrTextBlock value, $Res Function(OcrTextBlock) _then) = _$OcrTextBlockCopyWithImpl;
@useResult
$Res call({
 String text, double confidence, double area
});




}
/// @nodoc
class _$OcrTextBlockCopyWithImpl<$Res>
    implements $OcrTextBlockCopyWith<$Res> {
  _$OcrTextBlockCopyWithImpl(this._self, this._then);

  final OcrTextBlock _self;
  final $Res Function(OcrTextBlock) _then;

/// Create a copy of OcrTextBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? confidence = null,Object? area = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrTextBlock].
extension OcrTextBlockPatterns on OcrTextBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrTextBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrTextBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrTextBlock value)  $default,){
final _that = this;
switch (_that) {
case _OcrTextBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrTextBlock value)?  $default,){
final _that = this;
switch (_that) {
case _OcrTextBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  double confidence,  double area)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrTextBlock() when $default != null:
return $default(_that.text,_that.confidence,_that.area);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  double confidence,  double area)  $default,) {final _that = this;
switch (_that) {
case _OcrTextBlock():
return $default(_that.text,_that.confidence,_that.area);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  double confidence,  double area)?  $default,) {final _that = this;
switch (_that) {
case _OcrTextBlock() when $default != null:
return $default(_that.text,_that.confidence,_that.area);case _:
  return null;

}
}

}

/// @nodoc


class _OcrTextBlock extends OcrTextBlock {
  const _OcrTextBlock({required this.text, required this.confidence, required this.area}): super._();
  

@override final  String text;
@override final  double confidence;
@override final  double area;

/// Create a copy of OcrTextBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrTextBlockCopyWith<_OcrTextBlock> get copyWith => __$OcrTextBlockCopyWithImpl<_OcrTextBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrTextBlock&&(identical(other.text, text) || other.text == text)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,text,confidence,area);

@override
String toString() {
  return 'OcrTextBlock(text: $text, confidence: $confidence, area: $area)';
}


}

/// @nodoc
abstract mixin class _$OcrTextBlockCopyWith<$Res> implements $OcrTextBlockCopyWith<$Res> {
  factory _$OcrTextBlockCopyWith(_OcrTextBlock value, $Res Function(_OcrTextBlock) _then) = __$OcrTextBlockCopyWithImpl;
@override @useResult
$Res call({
 String text, double confidence, double area
});




}
/// @nodoc
class __$OcrTextBlockCopyWithImpl<$Res>
    implements _$OcrTextBlockCopyWith<$Res> {
  __$OcrTextBlockCopyWithImpl(this._self, this._then);

  final _OcrTextBlock _self;
  final $Res Function(_OcrTextBlock) _then;

/// Create a copy of OcrTextBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? confidence = null,Object? area = null,}) {
  return _then(_OcrTextBlock(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OcrResult {

 List<OcrTextBlock> get blocks;
/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrResultCopyWith<OcrResult> get copyWith => _$OcrResultCopyWithImpl<OcrResult>(this as OcrResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrResult&&const DeepCollectionEquality().equals(other.blocks, blocks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(blocks));

@override
String toString() {
  return 'OcrResult(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $OcrResultCopyWith<$Res>  {
  factory $OcrResultCopyWith(OcrResult value, $Res Function(OcrResult) _then) = _$OcrResultCopyWithImpl;
@useResult
$Res call({
 List<OcrTextBlock> blocks
});




}
/// @nodoc
class _$OcrResultCopyWithImpl<$Res>
    implements $OcrResultCopyWith<$Res> {
  _$OcrResultCopyWithImpl(this._self, this._then);

  final OcrResult _self;
  final $Res Function(OcrResult) _then;

/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blocks = null,}) {
  return _then(_self.copyWith(
blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<OcrTextBlock>,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrResult].
extension OcrResultPatterns on OcrResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrResult value)  $default,){
final _that = this;
switch (_that) {
case _OcrResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrResult value)?  $default,){
final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OcrTextBlock> blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
return $default(_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OcrTextBlock> blocks)  $default,) {final _that = this;
switch (_that) {
case _OcrResult():
return $default(_that.blocks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OcrTextBlock> blocks)?  $default,) {final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
return $default(_that.blocks);case _:
  return null;

}
}

}

/// @nodoc


class _OcrResult extends OcrResult {
  const _OcrResult({final  List<OcrTextBlock> blocks = const []}): _blocks = blocks,super._();
  

 final  List<OcrTextBlock> _blocks;
@override@JsonKey() List<OcrTextBlock> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrResultCopyWith<_OcrResult> get copyWith => __$OcrResultCopyWithImpl<_OcrResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrResult&&const DeepCollectionEquality().equals(other._blocks, _blocks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks));

@override
String toString() {
  return 'OcrResult(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$OcrResultCopyWith<$Res> implements $OcrResultCopyWith<$Res> {
  factory _$OcrResultCopyWith(_OcrResult value, $Res Function(_OcrResult) _then) = __$OcrResultCopyWithImpl;
@override @useResult
$Res call({
 List<OcrTextBlock> blocks
});




}
/// @nodoc
class __$OcrResultCopyWithImpl<$Res>
    implements _$OcrResultCopyWith<$Res> {
  __$OcrResultCopyWithImpl(this._self, this._then);

  final _OcrResult _self;
  final $Res Function(_OcrResult) _then;

/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blocks = null,}) {
  return _then(_OcrResult(
blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<OcrTextBlock>,
  ));
}


}

// dart format on
