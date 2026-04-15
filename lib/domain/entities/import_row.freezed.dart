// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportRow {

 String get sourceRowId; ImportSource get source; MediaType get mediaType; String? get rawTitle; String? get rawAuthor; int? get rawYear; String? get isbn; String? get imdbId; String? get discogsCatalog; Map<String, String> get rawFields; ImportRowStatus get status; MetadataResult? get enriched; String? get errorMessage; bool get accepted;
/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportRowCopyWith<ImportRow> get copyWith => _$ImportRowCopyWithImpl<ImportRow>(this as ImportRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportRow&&(identical(other.sourceRowId, sourceRowId) || other.sourceRowId == sourceRowId)&&(identical(other.source, source) || other.source == source)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawAuthor, rawAuthor) || other.rawAuthor == rawAuthor)&&(identical(other.rawYear, rawYear) || other.rawYear == rawYear)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.discogsCatalog, discogsCatalog) || other.discogsCatalog == discogsCatalog)&&const DeepCollectionEquality().equals(other.rawFields, rawFields)&&(identical(other.status, status) || other.status == status)&&(identical(other.enriched, enriched) || other.enriched == enriched)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.accepted, accepted) || other.accepted == accepted));
}


@override
int get hashCode => Object.hash(runtimeType,sourceRowId,source,mediaType,rawTitle,rawAuthor,rawYear,isbn,imdbId,discogsCatalog,const DeepCollectionEquality().hash(rawFields),status,enriched,errorMessage,accepted);

@override
String toString() {
  return 'ImportRow(sourceRowId: $sourceRowId, source: $source, mediaType: $mediaType, rawTitle: $rawTitle, rawAuthor: $rawAuthor, rawYear: $rawYear, isbn: $isbn, imdbId: $imdbId, discogsCatalog: $discogsCatalog, rawFields: $rawFields, status: $status, enriched: $enriched, errorMessage: $errorMessage, accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class $ImportRowCopyWith<$Res>  {
  factory $ImportRowCopyWith(ImportRow value, $Res Function(ImportRow) _then) = _$ImportRowCopyWithImpl;
@useResult
$Res call({
 String sourceRowId, ImportSource source, MediaType mediaType, String? rawTitle, String? rawAuthor, int? rawYear, String? isbn, String? imdbId, String? discogsCatalog, Map<String, String> rawFields, ImportRowStatus status, MetadataResult? enriched, String? errorMessage, bool accepted
});


$MetadataResultCopyWith<$Res>? get enriched;

}
/// @nodoc
class _$ImportRowCopyWithImpl<$Res>
    implements $ImportRowCopyWith<$Res> {
  _$ImportRowCopyWithImpl(this._self, this._then);

  final ImportRow _self;
  final $Res Function(ImportRow) _then;

/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceRowId = null,Object? source = null,Object? mediaType = null,Object? rawTitle = freezed,Object? rawAuthor = freezed,Object? rawYear = freezed,Object? isbn = freezed,Object? imdbId = freezed,Object? discogsCatalog = freezed,Object? rawFields = null,Object? status = null,Object? enriched = freezed,Object? errorMessage = freezed,Object? accepted = null,}) {
  return _then(_self.copyWith(
sourceRowId: null == sourceRowId ? _self.sourceRowId : sourceRowId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawAuthor: freezed == rawAuthor ? _self.rawAuthor : rawAuthor // ignore: cast_nullable_to_non_nullable
as String?,rawYear: freezed == rawYear ? _self.rawYear : rawYear // ignore: cast_nullable_to_non_nullable
as int?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,discogsCatalog: freezed == discogsCatalog ? _self.discogsCatalog : discogsCatalog // ignore: cast_nullable_to_non_nullable
as String?,rawFields: null == rawFields ? _self.rawFields : rawFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportRowStatus,enriched: freezed == enriched ? _self.enriched : enriched // ignore: cast_nullable_to_non_nullable
as MetadataResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataResultCopyWith<$Res>? get enriched {
    if (_self.enriched == null) {
    return null;
  }

  return $MetadataResultCopyWith<$Res>(_self.enriched!, (value) {
    return _then(_self.copyWith(enriched: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImportRow].
extension ImportRowPatterns on ImportRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportRow value)  $default,){
final _that = this;
switch (_that) {
case _ImportRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportRow value)?  $default,){
final _that = this;
switch (_that) {
case _ImportRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceRowId,  ImportSource source,  MediaType mediaType,  String? rawTitle,  String? rawAuthor,  int? rawYear,  String? isbn,  String? imdbId,  String? discogsCatalog,  Map<String, String> rawFields,  ImportRowStatus status,  MetadataResult? enriched,  String? errorMessage,  bool accepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportRow() when $default != null:
return $default(_that.sourceRowId,_that.source,_that.mediaType,_that.rawTitle,_that.rawAuthor,_that.rawYear,_that.isbn,_that.imdbId,_that.discogsCatalog,_that.rawFields,_that.status,_that.enriched,_that.errorMessage,_that.accepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceRowId,  ImportSource source,  MediaType mediaType,  String? rawTitle,  String? rawAuthor,  int? rawYear,  String? isbn,  String? imdbId,  String? discogsCatalog,  Map<String, String> rawFields,  ImportRowStatus status,  MetadataResult? enriched,  String? errorMessage,  bool accepted)  $default,) {final _that = this;
switch (_that) {
case _ImportRow():
return $default(_that.sourceRowId,_that.source,_that.mediaType,_that.rawTitle,_that.rawAuthor,_that.rawYear,_that.isbn,_that.imdbId,_that.discogsCatalog,_that.rawFields,_that.status,_that.enriched,_that.errorMessage,_that.accepted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceRowId,  ImportSource source,  MediaType mediaType,  String? rawTitle,  String? rawAuthor,  int? rawYear,  String? isbn,  String? imdbId,  String? discogsCatalog,  Map<String, String> rawFields,  ImportRowStatus status,  MetadataResult? enriched,  String? errorMessage,  bool accepted)?  $default,) {final _that = this;
switch (_that) {
case _ImportRow() when $default != null:
return $default(_that.sourceRowId,_that.source,_that.mediaType,_that.rawTitle,_that.rawAuthor,_that.rawYear,_that.isbn,_that.imdbId,_that.discogsCatalog,_that.rawFields,_that.status,_that.enriched,_that.errorMessage,_that.accepted);case _:
  return null;

}
}

}

/// @nodoc


class _ImportRow implements ImportRow {
  const _ImportRow({required this.sourceRowId, required this.source, required this.mediaType, this.rawTitle, this.rawAuthor, this.rawYear, this.isbn, this.imdbId, this.discogsCatalog, final  Map<String, String> rawFields = const {}, this.status = ImportRowStatus.pending, this.enriched, this.errorMessage, this.accepted = true}): _rawFields = rawFields;
  

@override final  String sourceRowId;
@override final  ImportSource source;
@override final  MediaType mediaType;
@override final  String? rawTitle;
@override final  String? rawAuthor;
@override final  int? rawYear;
@override final  String? isbn;
@override final  String? imdbId;
@override final  String? discogsCatalog;
 final  Map<String, String> _rawFields;
@override@JsonKey() Map<String, String> get rawFields {
  if (_rawFields is EqualUnmodifiableMapView) return _rawFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawFields);
}

@override@JsonKey() final  ImportRowStatus status;
@override final  MetadataResult? enriched;
@override final  String? errorMessage;
@override@JsonKey() final  bool accepted;

/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportRowCopyWith<_ImportRow> get copyWith => __$ImportRowCopyWithImpl<_ImportRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportRow&&(identical(other.sourceRowId, sourceRowId) || other.sourceRowId == sourceRowId)&&(identical(other.source, source) || other.source == source)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawAuthor, rawAuthor) || other.rawAuthor == rawAuthor)&&(identical(other.rawYear, rawYear) || other.rawYear == rawYear)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.discogsCatalog, discogsCatalog) || other.discogsCatalog == discogsCatalog)&&const DeepCollectionEquality().equals(other._rawFields, _rawFields)&&(identical(other.status, status) || other.status == status)&&(identical(other.enriched, enriched) || other.enriched == enriched)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.accepted, accepted) || other.accepted == accepted));
}


@override
int get hashCode => Object.hash(runtimeType,sourceRowId,source,mediaType,rawTitle,rawAuthor,rawYear,isbn,imdbId,discogsCatalog,const DeepCollectionEquality().hash(_rawFields),status,enriched,errorMessage,accepted);

@override
String toString() {
  return 'ImportRow(sourceRowId: $sourceRowId, source: $source, mediaType: $mediaType, rawTitle: $rawTitle, rawAuthor: $rawAuthor, rawYear: $rawYear, isbn: $isbn, imdbId: $imdbId, discogsCatalog: $discogsCatalog, rawFields: $rawFields, status: $status, enriched: $enriched, errorMessage: $errorMessage, accepted: $accepted)';
}


}

/// @nodoc
abstract mixin class _$ImportRowCopyWith<$Res> implements $ImportRowCopyWith<$Res> {
  factory _$ImportRowCopyWith(_ImportRow value, $Res Function(_ImportRow) _then) = __$ImportRowCopyWithImpl;
@override @useResult
$Res call({
 String sourceRowId, ImportSource source, MediaType mediaType, String? rawTitle, String? rawAuthor, int? rawYear, String? isbn, String? imdbId, String? discogsCatalog, Map<String, String> rawFields, ImportRowStatus status, MetadataResult? enriched, String? errorMessage, bool accepted
});


@override $MetadataResultCopyWith<$Res>? get enriched;

}
/// @nodoc
class __$ImportRowCopyWithImpl<$Res>
    implements _$ImportRowCopyWith<$Res> {
  __$ImportRowCopyWithImpl(this._self, this._then);

  final _ImportRow _self;
  final $Res Function(_ImportRow) _then;

/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceRowId = null,Object? source = null,Object? mediaType = null,Object? rawTitle = freezed,Object? rawAuthor = freezed,Object? rawYear = freezed,Object? isbn = freezed,Object? imdbId = freezed,Object? discogsCatalog = freezed,Object? rawFields = null,Object? status = null,Object? enriched = freezed,Object? errorMessage = freezed,Object? accepted = null,}) {
  return _then(_ImportRow(
sourceRowId: null == sourceRowId ? _self.sourceRowId : sourceRowId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawAuthor: freezed == rawAuthor ? _self.rawAuthor : rawAuthor // ignore: cast_nullable_to_non_nullable
as String?,rawYear: freezed == rawYear ? _self.rawYear : rawYear // ignore: cast_nullable_to_non_nullable
as int?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,discogsCatalog: freezed == discogsCatalog ? _self.discogsCatalog : discogsCatalog // ignore: cast_nullable_to_non_nullable
as String?,rawFields: null == rawFields ? _self._rawFields : rawFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportRowStatus,enriched: freezed == enriched ? _self.enriched : enriched // ignore: cast_nullable_to_non_nullable
as MetadataResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ImportRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataResultCopyWith<$Res>? get enriched {
    if (_self.enriched == null) {
    return null;
  }

  return $MetadataResultCopyWith<$Res>(_self.enriched!, (value) {
    return _then(_self.copyWith(enriched: value));
  });
}
}

// dart format on
