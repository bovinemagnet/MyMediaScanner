// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Shelf {

 String get id; String get name; String? get description; int get sortOrder; int get updatedAt; bool get deleted;
/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfCopyWith<Shelf> get copyWith => _$ShelfCopyWithImpl<Shelf>(this as Shelf, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shelf&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,sortOrder,updatedAt,deleted);

@override
String toString() {
  return 'Shelf(id: $id, name: $name, description: $description, sortOrder: $sortOrder, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $ShelfCopyWith<$Res>  {
  factory $ShelfCopyWith(Shelf value, $Res Function(Shelf) _then) = _$ShelfCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, int sortOrder, int updatedAt, bool deleted
});




}
/// @nodoc
class _$ShelfCopyWithImpl<$Res>
    implements $ShelfCopyWith<$Res> {
  _$ShelfCopyWithImpl(this._self, this._then);

  final Shelf _self;
  final $Res Function(Shelf) _then;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? sortOrder = null,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Shelf].
extension ShelfPatterns on Shelf {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shelf value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shelf() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shelf value)  $default,){
final _that = this;
switch (_that) {
case _Shelf():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shelf value)?  $default,){
final _that = this;
switch (_that) {
case _Shelf() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int sortOrder,  int updatedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shelf() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sortOrder,_that.updatedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int sortOrder,  int updatedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _Shelf():
return $default(_that.id,_that.name,_that.description,_that.sortOrder,_that.updatedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  int sortOrder,  int updatedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _Shelf() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sortOrder,_that.updatedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _Shelf implements Shelf {
  const _Shelf({required this.id, required this.name, this.description, this.sortOrder = 0, required this.updatedAt, this.deleted = false});
  

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int sortOrder;
@override final  int updatedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfCopyWith<_Shelf> get copyWith => __$ShelfCopyWithImpl<_Shelf>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shelf&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,sortOrder,updatedAt,deleted);

@override
String toString() {
  return 'Shelf(id: $id, name: $name, description: $description, sortOrder: $sortOrder, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$ShelfCopyWith<$Res> implements $ShelfCopyWith<$Res> {
  factory _$ShelfCopyWith(_Shelf value, $Res Function(_Shelf) _then) = __$ShelfCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, int sortOrder, int updatedAt, bool deleted
});




}
/// @nodoc
class __$ShelfCopyWithImpl<$Res>
    implements _$ShelfCopyWith<$Res> {
  __$ShelfCopyWithImpl(this._self, this._then);

  final _Shelf _self;
  final $Res Function(_Shelf) _then;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? sortOrder = null,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_Shelf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
