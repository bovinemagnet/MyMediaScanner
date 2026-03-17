// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScanResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScanResult()';
}


}

/// @nodoc
class $ScanResultCopyWith<$Res>  {
$ScanResultCopyWith(ScanResult _, $Res Function(ScanResult) __);
}


/// Adds pattern-matching-related methods to [ScanResult].
extension ScanResultPatterns on ScanResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SingleScanResult value)?  single,TResult Function( MultiMatchScanResult value)?  multiMatch,TResult Function( NotFoundScanResult value)?  notFound,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SingleScanResult() when single != null:
return single(_that);case MultiMatchScanResult() when multiMatch != null:
return multiMatch(_that);case NotFoundScanResult() when notFound != null:
return notFound(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SingleScanResult value)  single,required TResult Function( MultiMatchScanResult value)  multiMatch,required TResult Function( NotFoundScanResult value)  notFound,}){
final _that = this;
switch (_that) {
case SingleScanResult():
return single(_that);case MultiMatchScanResult():
return multiMatch(_that);case NotFoundScanResult():
return notFound(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SingleScanResult value)?  single,TResult? Function( MultiMatchScanResult value)?  multiMatch,TResult? Function( NotFoundScanResult value)?  notFound,}){
final _that = this;
switch (_that) {
case SingleScanResult() when single != null:
return single(_that);case MultiMatchScanResult() when multiMatch != null:
return multiMatch(_that);case NotFoundScanResult() when notFound != null:
return notFound(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MetadataResult metadata,  bool isDuplicate)?  single,TResult Function( List<MetadataCandidate> candidates,  String barcode,  String barcodeType)?  multiMatch,TResult Function( String barcode,  String barcodeType)?  notFound,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SingleScanResult() when single != null:
return single(_that.metadata,_that.isDuplicate);case MultiMatchScanResult() when multiMatch != null:
return multiMatch(_that.candidates,_that.barcode,_that.barcodeType);case NotFoundScanResult() when notFound != null:
return notFound(_that.barcode,_that.barcodeType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MetadataResult metadata,  bool isDuplicate)  single,required TResult Function( List<MetadataCandidate> candidates,  String barcode,  String barcodeType)  multiMatch,required TResult Function( String barcode,  String barcodeType)  notFound,}) {final _that = this;
switch (_that) {
case SingleScanResult():
return single(_that.metadata,_that.isDuplicate);case MultiMatchScanResult():
return multiMatch(_that.candidates,_that.barcode,_that.barcodeType);case NotFoundScanResult():
return notFound(_that.barcode,_that.barcodeType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MetadataResult metadata,  bool isDuplicate)?  single,TResult? Function( List<MetadataCandidate> candidates,  String barcode,  String barcodeType)?  multiMatch,TResult? Function( String barcode,  String barcodeType)?  notFound,}) {final _that = this;
switch (_that) {
case SingleScanResult() when single != null:
return single(_that.metadata,_that.isDuplicate);case MultiMatchScanResult() when multiMatch != null:
return multiMatch(_that.candidates,_that.barcode,_that.barcodeType);case NotFoundScanResult() when notFound != null:
return notFound(_that.barcode,_that.barcodeType);case _:
  return null;

}
}

}

/// @nodoc


class SingleScanResult implements ScanResult {
  const SingleScanResult({required this.metadata, required this.isDuplicate});
  

 final  MetadataResult metadata;
 final  bool isDuplicate;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SingleScanResultCopyWith<SingleScanResult> get copyWith => _$SingleScanResultCopyWithImpl<SingleScanResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SingleScanResult&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate));
}


@override
int get hashCode => Object.hash(runtimeType,metadata,isDuplicate);

@override
String toString() {
  return 'ScanResult.single(metadata: $metadata, isDuplicate: $isDuplicate)';
}


}

/// @nodoc
abstract mixin class $SingleScanResultCopyWith<$Res> implements $ScanResultCopyWith<$Res> {
  factory $SingleScanResultCopyWith(SingleScanResult value, $Res Function(SingleScanResult) _then) = _$SingleScanResultCopyWithImpl;
@useResult
$Res call({
 MetadataResult metadata, bool isDuplicate
});


$MetadataResultCopyWith<$Res> get metadata;

}
/// @nodoc
class _$SingleScanResultCopyWithImpl<$Res>
    implements $SingleScanResultCopyWith<$Res> {
  _$SingleScanResultCopyWithImpl(this._self, this._then);

  final SingleScanResult _self;
  final $Res Function(SingleScanResult) _then;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? metadata = null,Object? isDuplicate = null,}) {
  return _then(SingleScanResult(
metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as MetadataResult,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataResultCopyWith<$Res> get metadata {
  
  return $MetadataResultCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

/// @nodoc


class MultiMatchScanResult implements ScanResult {
  const MultiMatchScanResult({required final  List<MetadataCandidate> candidates, required this.barcode, required this.barcodeType}): _candidates = candidates;
  

 final  List<MetadataCandidate> _candidates;
 List<MetadataCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

 final  String barcode;
 final  String barcodeType;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiMatchScanResultCopyWith<MultiMatchScanResult> get copyWith => _$MultiMatchScanResultCopyWithImpl<MultiMatchScanResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiMatchScanResult&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates),barcode,barcodeType);

@override
String toString() {
  return 'ScanResult.multiMatch(candidates: $candidates, barcode: $barcode, barcodeType: $barcodeType)';
}


}

/// @nodoc
abstract mixin class $MultiMatchScanResultCopyWith<$Res> implements $ScanResultCopyWith<$Res> {
  factory $MultiMatchScanResultCopyWith(MultiMatchScanResult value, $Res Function(MultiMatchScanResult) _then) = _$MultiMatchScanResultCopyWithImpl;
@useResult
$Res call({
 List<MetadataCandidate> candidates, String barcode, String barcodeType
});




}
/// @nodoc
class _$MultiMatchScanResultCopyWithImpl<$Res>
    implements $MultiMatchScanResultCopyWith<$Res> {
  _$MultiMatchScanResultCopyWithImpl(this._self, this._then);

  final MultiMatchScanResult _self;
  final $Res Function(MultiMatchScanResult) _then;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,Object? barcode = null,Object? barcodeType = null,}) {
  return _then(MultiMatchScanResult(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<MetadataCandidate>,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NotFoundScanResult implements ScanResult {
  const NotFoundScanResult({required this.barcode, required this.barcodeType});
  

 final  String barcode;
 final  String barcodeType;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundScanResultCopyWith<NotFoundScanResult> get copyWith => _$NotFoundScanResultCopyWithImpl<NotFoundScanResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundScanResult&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeType, barcodeType) || other.barcodeType == barcodeType));
}


@override
int get hashCode => Object.hash(runtimeType,barcode,barcodeType);

@override
String toString() {
  return 'ScanResult.notFound(barcode: $barcode, barcodeType: $barcodeType)';
}


}

/// @nodoc
abstract mixin class $NotFoundScanResultCopyWith<$Res> implements $ScanResultCopyWith<$Res> {
  factory $NotFoundScanResultCopyWith(NotFoundScanResult value, $Res Function(NotFoundScanResult) _then) = _$NotFoundScanResultCopyWithImpl;
@useResult
$Res call({
 String barcode, String barcodeType
});




}
/// @nodoc
class _$NotFoundScanResultCopyWithImpl<$Res>
    implements $NotFoundScanResultCopyWith<$Res> {
  _$NotFoundScanResultCopyWithImpl(this._self, this._then);

  final NotFoundScanResult _self;
  final $Res Function(NotFoundScanResult) _then;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? barcodeType = null,}) {
  return _then(NotFoundScanResult(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeType: null == barcodeType ? _self.barcodeType : barcodeType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
