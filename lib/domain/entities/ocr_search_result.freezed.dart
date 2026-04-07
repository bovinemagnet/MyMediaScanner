// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OcrSearchResult {

 ScanResult get scanResult; OcrResult get ocrResult; String get searchTermUsed; String? get inferredArtist; int? get inferredYear; double get confidence;
/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrSearchResultCopyWith<OcrSearchResult> get copyWith => _$OcrSearchResultCopyWithImpl<OcrSearchResult>(this as OcrSearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrSearchResult&&(identical(other.scanResult, scanResult) || other.scanResult == scanResult)&&(identical(other.ocrResult, ocrResult) || other.ocrResult == ocrResult)&&(identical(other.searchTermUsed, searchTermUsed) || other.searchTermUsed == searchTermUsed)&&(identical(other.inferredArtist, inferredArtist) || other.inferredArtist == inferredArtist)&&(identical(other.inferredYear, inferredYear) || other.inferredYear == inferredYear)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,scanResult,ocrResult,searchTermUsed,inferredArtist,inferredYear,confidence);

@override
String toString() {
  return 'OcrSearchResult(scanResult: $scanResult, ocrResult: $ocrResult, searchTermUsed: $searchTermUsed, inferredArtist: $inferredArtist, inferredYear: $inferredYear, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $OcrSearchResultCopyWith<$Res>  {
  factory $OcrSearchResultCopyWith(OcrSearchResult value, $Res Function(OcrSearchResult) _then) = _$OcrSearchResultCopyWithImpl;
@useResult
$Res call({
 ScanResult scanResult, OcrResult ocrResult, String searchTermUsed, String? inferredArtist, int? inferredYear, double confidence
});


$ScanResultCopyWith<$Res> get scanResult;$OcrResultCopyWith<$Res> get ocrResult;

}
/// @nodoc
class _$OcrSearchResultCopyWithImpl<$Res>
    implements $OcrSearchResultCopyWith<$Res> {
  _$OcrSearchResultCopyWithImpl(this._self, this._then);

  final OcrSearchResult _self;
  final $Res Function(OcrSearchResult) _then;

/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scanResult = null,Object? ocrResult = null,Object? searchTermUsed = null,Object? inferredArtist = freezed,Object? inferredYear = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
scanResult: null == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as ScanResult,ocrResult: null == ocrResult ? _self.ocrResult : ocrResult // ignore: cast_nullable_to_non_nullable
as OcrResult,searchTermUsed: null == searchTermUsed ? _self.searchTermUsed : searchTermUsed // ignore: cast_nullable_to_non_nullable
as String,inferredArtist: freezed == inferredArtist ? _self.inferredArtist : inferredArtist // ignore: cast_nullable_to_non_nullable
as String?,inferredYear: freezed == inferredYear ? _self.inferredYear : inferredYear // ignore: cast_nullable_to_non_nullable
as int?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultCopyWith<$Res> get scanResult {
  
  return $ScanResultCopyWith<$Res>(_self.scanResult, (value) {
    return _then(_self.copyWith(scanResult: value));
  });
}/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrResultCopyWith<$Res> get ocrResult {
  
  return $OcrResultCopyWith<$Res>(_self.ocrResult, (value) {
    return _then(_self.copyWith(ocrResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [OcrSearchResult].
extension OcrSearchResultPatterns on OcrSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _OcrSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _OcrSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScanResult scanResult,  OcrResult ocrResult,  String searchTermUsed,  String? inferredArtist,  int? inferredYear,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrSearchResult() when $default != null:
return $default(_that.scanResult,_that.ocrResult,_that.searchTermUsed,_that.inferredArtist,_that.inferredYear,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScanResult scanResult,  OcrResult ocrResult,  String searchTermUsed,  String? inferredArtist,  int? inferredYear,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _OcrSearchResult():
return $default(_that.scanResult,_that.ocrResult,_that.searchTermUsed,_that.inferredArtist,_that.inferredYear,_that.confidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScanResult scanResult,  OcrResult ocrResult,  String searchTermUsed,  String? inferredArtist,  int? inferredYear,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _OcrSearchResult() when $default != null:
return $default(_that.scanResult,_that.ocrResult,_that.searchTermUsed,_that.inferredArtist,_that.inferredYear,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc


class _OcrSearchResult implements OcrSearchResult {
  const _OcrSearchResult({required this.scanResult, required this.ocrResult, required this.searchTermUsed, this.inferredArtist, this.inferredYear, required this.confidence});
  

@override final  ScanResult scanResult;
@override final  OcrResult ocrResult;
@override final  String searchTermUsed;
@override final  String? inferredArtist;
@override final  int? inferredYear;
@override final  double confidence;

/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrSearchResultCopyWith<_OcrSearchResult> get copyWith => __$OcrSearchResultCopyWithImpl<_OcrSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrSearchResult&&(identical(other.scanResult, scanResult) || other.scanResult == scanResult)&&(identical(other.ocrResult, ocrResult) || other.ocrResult == ocrResult)&&(identical(other.searchTermUsed, searchTermUsed) || other.searchTermUsed == searchTermUsed)&&(identical(other.inferredArtist, inferredArtist) || other.inferredArtist == inferredArtist)&&(identical(other.inferredYear, inferredYear) || other.inferredYear == inferredYear)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,scanResult,ocrResult,searchTermUsed,inferredArtist,inferredYear,confidence);

@override
String toString() {
  return 'OcrSearchResult(scanResult: $scanResult, ocrResult: $ocrResult, searchTermUsed: $searchTermUsed, inferredArtist: $inferredArtist, inferredYear: $inferredYear, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$OcrSearchResultCopyWith<$Res> implements $OcrSearchResultCopyWith<$Res> {
  factory _$OcrSearchResultCopyWith(_OcrSearchResult value, $Res Function(_OcrSearchResult) _then) = __$OcrSearchResultCopyWithImpl;
@override @useResult
$Res call({
 ScanResult scanResult, OcrResult ocrResult, String searchTermUsed, String? inferredArtist, int? inferredYear, double confidence
});


@override $ScanResultCopyWith<$Res> get scanResult;@override $OcrResultCopyWith<$Res> get ocrResult;

}
/// @nodoc
class __$OcrSearchResultCopyWithImpl<$Res>
    implements _$OcrSearchResultCopyWith<$Res> {
  __$OcrSearchResultCopyWithImpl(this._self, this._then);

  final _OcrSearchResult _self;
  final $Res Function(_OcrSearchResult) _then;

/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scanResult = null,Object? ocrResult = null,Object? searchTermUsed = null,Object? inferredArtist = freezed,Object? inferredYear = freezed,Object? confidence = null,}) {
  return _then(_OcrSearchResult(
scanResult: null == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as ScanResult,ocrResult: null == ocrResult ? _self.ocrResult : ocrResult // ignore: cast_nullable_to_non_nullable
as OcrResult,searchTermUsed: null == searchTermUsed ? _self.searchTermUsed : searchTermUsed // ignore: cast_nullable_to_non_nullable
as String,inferredArtist: freezed == inferredArtist ? _self.inferredArtist : inferredArtist // ignore: cast_nullable_to_non_nullable
as String?,inferredYear: freezed == inferredYear ? _self.inferredYear : inferredYear // ignore: cast_nullable_to_non_nullable
as int?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanResultCopyWith<$Res> get scanResult {
  
  return $ScanResultCopyWith<$Res>(_self.scanResult, (value) {
    return _then(_self.copyWith(scanResult: value));
  });
}/// Create a copy of OcrSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrResultCopyWith<$Res> get ocrResult {
  
  return $OcrResultCopyWith<$Res>(_self.ocrResult, (value) {
    return _then(_self.copyWith(ocrResult: value));
  });
}
}

// dart format on
