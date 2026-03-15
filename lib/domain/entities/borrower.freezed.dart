// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'borrower.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Borrower {

 String get id; String get name; String? get email; String? get phone; String? get notes; int get updatedAt; bool get deleted;
/// Create a copy of Borrower
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BorrowerCopyWith<Borrower> get copyWith => _$BorrowerCopyWithImpl<Borrower>(this as Borrower, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Borrower&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,notes,updatedAt,deleted);

@override
String toString() {
  return 'Borrower(id: $id, name: $name, email: $email, phone: $phone, notes: $notes, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $BorrowerCopyWith<$Res>  {
  factory $BorrowerCopyWith(Borrower value, $Res Function(Borrower) _then) = _$BorrowerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String? phone, String? notes, int updatedAt, bool deleted
});




}
/// @nodoc
class _$BorrowerCopyWithImpl<$Res>
    implements $BorrowerCopyWith<$Res> {
  _$BorrowerCopyWithImpl(this._self, this._then);

  final Borrower _self;
  final $Res Function(Borrower) _then;

/// Create a copy of Borrower
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? notes = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Borrower].
extension BorrowerPatterns on Borrower {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Borrower value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Borrower() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Borrower value)  $default,){
final _that = this;
switch (_that) {
case _Borrower():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Borrower value)?  $default,){
final _that = this;
switch (_that) {
case _Borrower() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String? notes,  int updatedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Borrower() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.notes,_that.updatedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String? notes,  int updatedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _Borrower():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.notes,_that.updatedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String? phone,  String? notes,  int updatedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _Borrower() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.notes,_that.updatedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _Borrower implements Borrower {
  const _Borrower({required this.id, required this.name, this.email, this.phone, this.notes, required this.updatedAt, this.deleted = false});
  

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String? notes;
@override final  int updatedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of Borrower
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BorrowerCopyWith<_Borrower> get copyWith => __$BorrowerCopyWithImpl<_Borrower>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Borrower&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,notes,updatedAt,deleted);

@override
String toString() {
  return 'Borrower(id: $id, name: $name, email: $email, phone: $phone, notes: $notes, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$BorrowerCopyWith<$Res> implements $BorrowerCopyWith<$Res> {
  factory _$BorrowerCopyWith(_Borrower value, $Res Function(_Borrower) _then) = __$BorrowerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String? phone, String? notes, int updatedAt, bool deleted
});




}
/// @nodoc
class __$BorrowerCopyWithImpl<$Res>
    implements _$BorrowerCopyWith<$Res> {
  __$BorrowerCopyWithImpl(this._self, this._then);

  final _Borrower _self;
  final $Res Function(_Borrower) _then;

/// Create a copy of Borrower
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? notes = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_Borrower(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
