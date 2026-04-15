// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_sheet_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabelSheetPreset {

 String get id; String get name; double get pageWidthPt; double get pageHeightPt; int get columns; int get rows; double get marginLeftPt; double get marginTopPt; double get gutterXPt; double get gutterYPt;
/// Create a copy of LabelSheetPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelSheetPresetCopyWith<LabelSheetPreset> get copyWith => _$LabelSheetPresetCopyWithImpl<LabelSheetPreset>(this as LabelSheetPreset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelSheetPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pageWidthPt, pageWidthPt) || other.pageWidthPt == pageWidthPt)&&(identical(other.pageHeightPt, pageHeightPt) || other.pageHeightPt == pageHeightPt)&&(identical(other.columns, columns) || other.columns == columns)&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.marginLeftPt, marginLeftPt) || other.marginLeftPt == marginLeftPt)&&(identical(other.marginTopPt, marginTopPt) || other.marginTopPt == marginTopPt)&&(identical(other.gutterXPt, gutterXPt) || other.gutterXPt == gutterXPt)&&(identical(other.gutterYPt, gutterYPt) || other.gutterYPt == gutterYPt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,pageWidthPt,pageHeightPt,columns,rows,marginLeftPt,marginTopPt,gutterXPt,gutterYPt);

@override
String toString() {
  return 'LabelSheetPreset(id: $id, name: $name, pageWidthPt: $pageWidthPt, pageHeightPt: $pageHeightPt, columns: $columns, rows: $rows, marginLeftPt: $marginLeftPt, marginTopPt: $marginTopPt, gutterXPt: $gutterXPt, gutterYPt: $gutterYPt)';
}


}

/// @nodoc
abstract mixin class $LabelSheetPresetCopyWith<$Res>  {
  factory $LabelSheetPresetCopyWith(LabelSheetPreset value, $Res Function(LabelSheetPreset) _then) = _$LabelSheetPresetCopyWithImpl;
@useResult
$Res call({
 String id, String name, double pageWidthPt, double pageHeightPt, int columns, int rows, double marginLeftPt, double marginTopPt, double gutterXPt, double gutterYPt
});




}
/// @nodoc
class _$LabelSheetPresetCopyWithImpl<$Res>
    implements $LabelSheetPresetCopyWith<$Res> {
  _$LabelSheetPresetCopyWithImpl(this._self, this._then);

  final LabelSheetPreset _self;
  final $Res Function(LabelSheetPreset) _then;

/// Create a copy of LabelSheetPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? pageWidthPt = null,Object? pageHeightPt = null,Object? columns = null,Object? rows = null,Object? marginLeftPt = null,Object? marginTopPt = null,Object? gutterXPt = null,Object? gutterYPt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pageWidthPt: null == pageWidthPt ? _self.pageWidthPt : pageWidthPt // ignore: cast_nullable_to_non_nullable
as double,pageHeightPt: null == pageHeightPt ? _self.pageHeightPt : pageHeightPt // ignore: cast_nullable_to_non_nullable
as double,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,marginLeftPt: null == marginLeftPt ? _self.marginLeftPt : marginLeftPt // ignore: cast_nullable_to_non_nullable
as double,marginTopPt: null == marginTopPt ? _self.marginTopPt : marginTopPt // ignore: cast_nullable_to_non_nullable
as double,gutterXPt: null == gutterXPt ? _self.gutterXPt : gutterXPt // ignore: cast_nullable_to_non_nullable
as double,gutterYPt: null == gutterYPt ? _self.gutterYPt : gutterYPt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelSheetPreset].
extension LabelSheetPresetPatterns on LabelSheetPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelSheetPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelSheetPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelSheetPreset value)  $default,){
final _that = this;
switch (_that) {
case _LabelSheetPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelSheetPreset value)?  $default,){
final _that = this;
switch (_that) {
case _LabelSheetPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double pageWidthPt,  double pageHeightPt,  int columns,  int rows,  double marginLeftPt,  double marginTopPt,  double gutterXPt,  double gutterYPt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelSheetPreset() when $default != null:
return $default(_that.id,_that.name,_that.pageWidthPt,_that.pageHeightPt,_that.columns,_that.rows,_that.marginLeftPt,_that.marginTopPt,_that.gutterXPt,_that.gutterYPt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double pageWidthPt,  double pageHeightPt,  int columns,  int rows,  double marginLeftPt,  double marginTopPt,  double gutterXPt,  double gutterYPt)  $default,) {final _that = this;
switch (_that) {
case _LabelSheetPreset():
return $default(_that.id,_that.name,_that.pageWidthPt,_that.pageHeightPt,_that.columns,_that.rows,_that.marginLeftPt,_that.marginTopPt,_that.gutterXPt,_that.gutterYPt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double pageWidthPt,  double pageHeightPt,  int columns,  int rows,  double marginLeftPt,  double marginTopPt,  double gutterXPt,  double gutterYPt)?  $default,) {final _that = this;
switch (_that) {
case _LabelSheetPreset() when $default != null:
return $default(_that.id,_that.name,_that.pageWidthPt,_that.pageHeightPt,_that.columns,_that.rows,_that.marginLeftPt,_that.marginTopPt,_that.gutterXPt,_that.gutterYPt);case _:
  return null;

}
}

}

/// @nodoc


class _LabelSheetPreset implements LabelSheetPreset {
  const _LabelSheetPreset({required this.id, required this.name, required this.pageWidthPt, required this.pageHeightPt, required this.columns, required this.rows, required this.marginLeftPt, required this.marginTopPt, required this.gutterXPt, required this.gutterYPt});
  

@override final  String id;
@override final  String name;
@override final  double pageWidthPt;
@override final  double pageHeightPt;
@override final  int columns;
@override final  int rows;
@override final  double marginLeftPt;
@override final  double marginTopPt;
@override final  double gutterXPt;
@override final  double gutterYPt;

/// Create a copy of LabelSheetPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelSheetPresetCopyWith<_LabelSheetPreset> get copyWith => __$LabelSheetPresetCopyWithImpl<_LabelSheetPreset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelSheetPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pageWidthPt, pageWidthPt) || other.pageWidthPt == pageWidthPt)&&(identical(other.pageHeightPt, pageHeightPt) || other.pageHeightPt == pageHeightPt)&&(identical(other.columns, columns) || other.columns == columns)&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.marginLeftPt, marginLeftPt) || other.marginLeftPt == marginLeftPt)&&(identical(other.marginTopPt, marginTopPt) || other.marginTopPt == marginTopPt)&&(identical(other.gutterXPt, gutterXPt) || other.gutterXPt == gutterXPt)&&(identical(other.gutterYPt, gutterYPt) || other.gutterYPt == gutterYPt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,pageWidthPt,pageHeightPt,columns,rows,marginLeftPt,marginTopPt,gutterXPt,gutterYPt);

@override
String toString() {
  return 'LabelSheetPreset(id: $id, name: $name, pageWidthPt: $pageWidthPt, pageHeightPt: $pageHeightPt, columns: $columns, rows: $rows, marginLeftPt: $marginLeftPt, marginTopPt: $marginTopPt, gutterXPt: $gutterXPt, gutterYPt: $gutterYPt)';
}


}

/// @nodoc
abstract mixin class _$LabelSheetPresetCopyWith<$Res> implements $LabelSheetPresetCopyWith<$Res> {
  factory _$LabelSheetPresetCopyWith(_LabelSheetPreset value, $Res Function(_LabelSheetPreset) _then) = __$LabelSheetPresetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double pageWidthPt, double pageHeightPt, int columns, int rows, double marginLeftPt, double marginTopPt, double gutterXPt, double gutterYPt
});




}
/// @nodoc
class __$LabelSheetPresetCopyWithImpl<$Res>
    implements _$LabelSheetPresetCopyWith<$Res> {
  __$LabelSheetPresetCopyWithImpl(this._self, this._then);

  final _LabelSheetPreset _self;
  final $Res Function(_LabelSheetPreset) _then;

/// Create a copy of LabelSheetPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? pageWidthPt = null,Object? pageHeightPt = null,Object? columns = null,Object? rows = null,Object? marginLeftPt = null,Object? marginTopPt = null,Object? gutterXPt = null,Object? gutterYPt = null,}) {
  return _then(_LabelSheetPreset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pageWidthPt: null == pageWidthPt ? _self.pageWidthPt : pageWidthPt // ignore: cast_nullable_to_non_nullable
as double,pageHeightPt: null == pageHeightPt ? _self.pageHeightPt : pageHeightPt // ignore: cast_nullable_to_non_nullable
as double,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,marginLeftPt: null == marginLeftPt ? _self.marginLeftPt : marginLeftPt // ignore: cast_nullable_to_non_nullable
as double,marginTopPt: null == marginTopPt ? _self.marginTopPt : marginTopPt // ignore: cast_nullable_to_non_nullable
as double,gutterXPt: null == gutterXPt ? _self.gutterXPt : gutterXPt // ignore: cast_nullable_to_non_nullable
as double,gutterYPt: null == gutterYPt ? _self.gutterYPt : gutterYPt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
