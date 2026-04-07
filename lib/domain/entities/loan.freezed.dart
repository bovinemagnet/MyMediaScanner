// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Loan {

 String get id; String get mediaItemId; String get borrowerId; int get lentAt; int? get returnedAt; int? get dueAt; String? get notes; int get updatedAt; bool get deleted;
/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanCopyWith<Loan> get copyWith => _$LoanCopyWithImpl<Loan>(this as Loan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loan&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaItemId, mediaItemId) || other.mediaItemId == mediaItemId)&&(identical(other.borrowerId, borrowerId) || other.borrowerId == borrowerId)&&(identical(other.lentAt, lentAt) || other.lentAt == lentAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,mediaItemId,borrowerId,lentAt,returnedAt,dueAt,notes,updatedAt,deleted);

@override
String toString() {
  return 'Loan(id: $id, mediaItemId: $mediaItemId, borrowerId: $borrowerId, lentAt: $lentAt, returnedAt: $returnedAt, dueAt: $dueAt, notes: $notes, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $LoanCopyWith<$Res>  {
  factory $LoanCopyWith(Loan value, $Res Function(Loan) _then) = _$LoanCopyWithImpl;
@useResult
$Res call({
 String id, String mediaItemId, String borrowerId, int lentAt, int? returnedAt, int? dueAt, String? notes, int updatedAt, bool deleted
});




}
/// @nodoc
class _$LoanCopyWithImpl<$Res>
    implements $LoanCopyWith<$Res> {
  _$LoanCopyWithImpl(this._self, this._then);

  final Loan _self;
  final $Res Function(Loan) _then;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mediaItemId = null,Object? borrowerId = null,Object? lentAt = null,Object? returnedAt = freezed,Object? dueAt = freezed,Object? notes = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaItemId: null == mediaItemId ? _self.mediaItemId : mediaItemId // ignore: cast_nullable_to_non_nullable
as String,borrowerId: null == borrowerId ? _self.borrowerId : borrowerId // ignore: cast_nullable_to_non_nullable
as String,lentAt: null == lentAt ? _self.lentAt : lentAt // ignore: cast_nullable_to_non_nullable
as int,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as int?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Loan].
extension LoanPatterns on Loan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Loan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Loan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Loan value)  $default,){
final _that = this;
switch (_that) {
case _Loan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Loan value)?  $default,){
final _that = this;
switch (_that) {
case _Loan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String mediaItemId,  String borrowerId,  int lentAt,  int? returnedAt,  int? dueAt,  String? notes,  int updatedAt,  bool deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Loan() when $default != null:
return $default(_that.id,_that.mediaItemId,_that.borrowerId,_that.lentAt,_that.returnedAt,_that.dueAt,_that.notes,_that.updatedAt,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String mediaItemId,  String borrowerId,  int lentAt,  int? returnedAt,  int? dueAt,  String? notes,  int updatedAt,  bool deleted)  $default,) {final _that = this;
switch (_that) {
case _Loan():
return $default(_that.id,_that.mediaItemId,_that.borrowerId,_that.lentAt,_that.returnedAt,_that.dueAt,_that.notes,_that.updatedAt,_that.deleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String mediaItemId,  String borrowerId,  int lentAt,  int? returnedAt,  int? dueAt,  String? notes,  int updatedAt,  bool deleted)?  $default,) {final _that = this;
switch (_that) {
case _Loan() when $default != null:
return $default(_that.id,_that.mediaItemId,_that.borrowerId,_that.lentAt,_that.returnedAt,_that.dueAt,_that.notes,_that.updatedAt,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _Loan extends Loan {
  const _Loan({required this.id, required this.mediaItemId, required this.borrowerId, required this.lentAt, this.returnedAt, this.dueAt, this.notes, required this.updatedAt, this.deleted = false}): super._();
  

@override final  String id;
@override final  String mediaItemId;
@override final  String borrowerId;
@override final  int lentAt;
@override final  int? returnedAt;
@override final  int? dueAt;
@override final  String? notes;
@override final  int updatedAt;
@override@JsonKey() final  bool deleted;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanCopyWith<_Loan> get copyWith => __$LoanCopyWithImpl<_Loan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loan&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaItemId, mediaItemId) || other.mediaItemId == mediaItemId)&&(identical(other.borrowerId, borrowerId) || other.borrowerId == borrowerId)&&(identical(other.lentAt, lentAt) || other.lentAt == lentAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,mediaItemId,borrowerId,lentAt,returnedAt,dueAt,notes,updatedAt,deleted);

@override
String toString() {
  return 'Loan(id: $id, mediaItemId: $mediaItemId, borrowerId: $borrowerId, lentAt: $lentAt, returnedAt: $returnedAt, dueAt: $dueAt, notes: $notes, updatedAt: $updatedAt, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$LoanCopyWith<$Res> implements $LoanCopyWith<$Res> {
  factory _$LoanCopyWith(_Loan value, $Res Function(_Loan) _then) = __$LoanCopyWithImpl;
@override @useResult
$Res call({
 String id, String mediaItemId, String borrowerId, int lentAt, int? returnedAt, int? dueAt, String? notes, int updatedAt, bool deleted
});




}
/// @nodoc
class __$LoanCopyWithImpl<$Res>
    implements _$LoanCopyWith<$Res> {
  __$LoanCopyWithImpl(this._self, this._then);

  final _Loan _self;
  final $Res Function(_Loan) _then;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mediaItemId = null,Object? borrowerId = null,Object? lentAt = null,Object? returnedAt = freezed,Object? dueAt = freezed,Object? notes = freezed,Object? updatedAt = null,Object? deleted = null,}) {
  return _then(_Loan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaItemId: null == mediaItemId ? _self.mediaItemId : mediaItemId // ignore: cast_nullable_to_non_nullable
as String,borrowerId: null == borrowerId ? _self.borrowerId : borrowerId // ignore: cast_nullable_to_non_nullable
as String,lentAt: null == lentAt ? _self.lentAt : lentAt // ignore: cast_nullable_to_non_nullable
as int,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as int?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
