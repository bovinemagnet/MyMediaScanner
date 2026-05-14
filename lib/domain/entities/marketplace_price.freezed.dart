// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketplacePrice {

 double get value; String get currency; int get numForSale; String get source; int get fetchedAt;
/// Create a copy of MarketplacePrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplacePriceCopyWith<MarketplacePrice> get copyWith => _$MarketplacePriceCopyWithImpl<MarketplacePrice>(this as MarketplacePrice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplacePrice&&(identical(other.value, value) || other.value == value)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.numForSale, numForSale) || other.numForSale == numForSale)&&(identical(other.source, source) || other.source == source)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,value,currency,numForSale,source,fetchedAt);

@override
String toString() {
  return 'MarketplacePrice(value: $value, currency: $currency, numForSale: $numForSale, source: $source, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $MarketplacePriceCopyWith<$Res>  {
  factory $MarketplacePriceCopyWith(MarketplacePrice value, $Res Function(MarketplacePrice) _then) = _$MarketplacePriceCopyWithImpl;
@useResult
$Res call({
 double value, String currency, int numForSale, String source, int fetchedAt
});




}
/// @nodoc
class _$MarketplacePriceCopyWithImpl<$Res>
    implements $MarketplacePriceCopyWith<$Res> {
  _$MarketplacePriceCopyWithImpl(this._self, this._then);

  final MarketplacePrice _self;
  final $Res Function(MarketplacePrice) _then;

/// Create a copy of MarketplacePrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? currency = null,Object? numForSale = null,Object? source = null,Object? fetchedAt = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,numForSale: null == numForSale ? _self.numForSale : numForSale // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketplacePrice].
extension MarketplacePricePatterns on MarketplacePrice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketplacePrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketplacePrice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketplacePrice value)  $default,){
final _that = this;
switch (_that) {
case _MarketplacePrice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketplacePrice value)?  $default,){
final _that = this;
switch (_that) {
case _MarketplacePrice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double value,  String currency,  int numForSale,  String source,  int fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplacePrice() when $default != null:
return $default(_that.value,_that.currency,_that.numForSale,_that.source,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double value,  String currency,  int numForSale,  String source,  int fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplacePrice():
return $default(_that.value,_that.currency,_that.numForSale,_that.source,_that.fetchedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double value,  String currency,  int numForSale,  String source,  int fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplacePrice() when $default != null:
return $default(_that.value,_that.currency,_that.numForSale,_that.source,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MarketplacePrice implements MarketplacePrice {
  const _MarketplacePrice({required this.value, required this.currency, required this.numForSale, required this.source, required this.fetchedAt});
  

@override final  double value;
@override final  String currency;
@override final  int numForSale;
@override final  String source;
@override final  int fetchedAt;

/// Create a copy of MarketplacePrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketplacePriceCopyWith<_MarketplacePrice> get copyWith => __$MarketplacePriceCopyWithImpl<_MarketplacePrice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplacePrice&&(identical(other.value, value) || other.value == value)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.numForSale, numForSale) || other.numForSale == numForSale)&&(identical(other.source, source) || other.source == source)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,value,currency,numForSale,source,fetchedAt);

@override
String toString() {
  return 'MarketplacePrice(value: $value, currency: $currency, numForSale: $numForSale, source: $source, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplacePriceCopyWith<$Res> implements $MarketplacePriceCopyWith<$Res> {
  factory _$MarketplacePriceCopyWith(_MarketplacePrice value, $Res Function(_MarketplacePrice) _then) = __$MarketplacePriceCopyWithImpl;
@override @useResult
$Res call({
 double value, String currency, int numForSale, String source, int fetchedAt
});




}
/// @nodoc
class __$MarketplacePriceCopyWithImpl<$Res>
    implements _$MarketplacePriceCopyWith<$Res> {
  __$MarketplacePriceCopyWithImpl(this._self, this._then);

  final _MarketplacePrice _self;
  final $Res Function(_MarketplacePrice) _then;

/// Create a copy of MarketplacePrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? currency = null,Object? numForSale = null,Object? source = null,Object? fetchedAt = null,}) {
  return _then(_MarketplacePrice(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,numForSale: null == numForSale ? _self.numForSale : numForSale // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
