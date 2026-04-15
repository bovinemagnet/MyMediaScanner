// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendationReason {

 String get label; double get weight;
/// Create a copy of RecommendationReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationReasonCopyWith<RecommendationReason> get copyWith => _$RecommendationReasonCopyWithImpl<RecommendationReason>(this as RecommendationReason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationReason&&(identical(other.label, label) || other.label == label)&&(identical(other.weight, weight) || other.weight == weight));
}


@override
int get hashCode => Object.hash(runtimeType,label,weight);

@override
String toString() {
  return 'RecommendationReason(label: $label, weight: $weight)';
}


}

/// @nodoc
abstract mixin class $RecommendationReasonCopyWith<$Res>  {
  factory $RecommendationReasonCopyWith(RecommendationReason value, $Res Function(RecommendationReason) _then) = _$RecommendationReasonCopyWithImpl;
@useResult
$Res call({
 String label, double weight
});




}
/// @nodoc
class _$RecommendationReasonCopyWithImpl<$Res>
    implements $RecommendationReasonCopyWith<$Res> {
  _$RecommendationReasonCopyWithImpl(this._self, this._then);

  final RecommendationReason _self;
  final $Res Function(RecommendationReason) _then;

/// Create a copy of RecommendationReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? weight = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationReason].
extension RecommendationReasonPatterns on RecommendationReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationReason value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationReason value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double weight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationReason() when $default != null:
return $default(_that.label,_that.weight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double weight)  $default,) {final _that = this;
switch (_that) {
case _RecommendationReason():
return $default(_that.label,_that.weight);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double weight)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationReason() when $default != null:
return $default(_that.label,_that.weight);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendationReason implements RecommendationReason {
  const _RecommendationReason({required this.label, required this.weight});
  

@override final  String label;
@override final  double weight;

/// Create a copy of RecommendationReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationReasonCopyWith<_RecommendationReason> get copyWith => __$RecommendationReasonCopyWithImpl<_RecommendationReason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationReason&&(identical(other.label, label) || other.label == label)&&(identical(other.weight, weight) || other.weight == weight));
}


@override
int get hashCode => Object.hash(runtimeType,label,weight);

@override
String toString() {
  return 'RecommendationReason(label: $label, weight: $weight)';
}


}

/// @nodoc
abstract mixin class _$RecommendationReasonCopyWith<$Res> implements $RecommendationReasonCopyWith<$Res> {
  factory _$RecommendationReasonCopyWith(_RecommendationReason value, $Res Function(_RecommendationReason) _then) = __$RecommendationReasonCopyWithImpl;
@override @useResult
$Res call({
 String label, double weight
});




}
/// @nodoc
class __$RecommendationReasonCopyWithImpl<$Res>
    implements _$RecommendationReasonCopyWith<$Res> {
  __$RecommendationReasonCopyWithImpl(this._self, this._then);

  final _RecommendationReason _self;
  final $Res Function(_RecommendationReason) _then;

/// Create a copy of RecommendationReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? weight = null,}) {
  return _then(_RecommendationReason(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$Recommendation {

 MediaItem get item; double get score; List<RecommendationReason> get reasons;
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCopyWith<Recommendation> get copyWith => _$RecommendationCopyWithImpl<Recommendation>(this as Recommendation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recommendation&&(identical(other.item, item) || other.item == item)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}


@override
int get hashCode => Object.hash(runtimeType,item,score,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'Recommendation(item: $item, score: $score, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $RecommendationCopyWith<$Res>  {
  factory $RecommendationCopyWith(Recommendation value, $Res Function(Recommendation) _then) = _$RecommendationCopyWithImpl;
@useResult
$Res call({
 MediaItem item, double score, List<RecommendationReason> reasons
});


$MediaItemCopyWith<$Res> get item;

}
/// @nodoc
class _$RecommendationCopyWithImpl<$Res>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._self, this._then);

  final Recommendation _self;
  final $Res Function(Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? score = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MediaItem,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<RecommendationReason>,
  ));
}
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaItemCopyWith<$Res> get item {
  
  return $MediaItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recommendation].
extension RecommendationPatterns on Recommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recommendation value)  $default,){
final _that = this;
switch (_that) {
case _Recommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recommendation value)?  $default,){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MediaItem item,  double score,  List<RecommendationReason> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.item,_that.score,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MediaItem item,  double score,  List<RecommendationReason> reasons)  $default,) {final _that = this;
switch (_that) {
case _Recommendation():
return $default(_that.item,_that.score,_that.reasons);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MediaItem item,  double score,  List<RecommendationReason> reasons)?  $default,) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.item,_that.score,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc


class _Recommendation implements Recommendation {
  const _Recommendation({required this.item, required this.score, required final  List<RecommendationReason> reasons}): _reasons = reasons;
  

@override final  MediaItem item;
@override final  double score;
 final  List<RecommendationReason> _reasons;
@override List<RecommendationReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCopyWith<_Recommendation> get copyWith => __$RecommendationCopyWithImpl<_Recommendation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recommendation&&(identical(other.item, item) || other.item == item)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}


@override
int get hashCode => Object.hash(runtimeType,item,score,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'Recommendation(item: $item, score: $score, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCopyWith<$Res> implements $RecommendationCopyWith<$Res> {
  factory _$RecommendationCopyWith(_Recommendation value, $Res Function(_Recommendation) _then) = __$RecommendationCopyWithImpl;
@override @useResult
$Res call({
 MediaItem item, double score, List<RecommendationReason> reasons
});


@override $MediaItemCopyWith<$Res> get item;

}
/// @nodoc
class __$RecommendationCopyWithImpl<$Res>
    implements _$RecommendationCopyWith<$Res> {
  __$RecommendationCopyWithImpl(this._self, this._then);

  final _Recommendation _self;
  final $Res Function(_Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? score = null,Object? reasons = null,}) {
  return _then(_Recommendation(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as MediaItem,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<RecommendationReason>,
  ));
}

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaItemCopyWith<$Res> get item {
  
  return $MediaItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

/// @nodoc
mixin _$WishlistSuggestion {

 String get externalId; String get title; String? get subtitle; String? get coverUrl; int? get year; List<String> get genres; String get source; double get score; List<RecommendationReason> get reasons;
/// Create a copy of WishlistSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistSuggestionCopyWith<WishlistSuggestion> get copyWith => _$WishlistSuggestionCopyWithImpl<WishlistSuggestion>(this as WishlistSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistSuggestion&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.source, source) || other.source == source)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}


@override
int get hashCode => Object.hash(runtimeType,externalId,title,subtitle,coverUrl,year,const DeepCollectionEquality().hash(genres),source,score,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'WishlistSuggestion(externalId: $externalId, title: $title, subtitle: $subtitle, coverUrl: $coverUrl, year: $year, genres: $genres, source: $source, score: $score, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $WishlistSuggestionCopyWith<$Res>  {
  factory $WishlistSuggestionCopyWith(WishlistSuggestion value, $Res Function(WishlistSuggestion) _then) = _$WishlistSuggestionCopyWithImpl;
@useResult
$Res call({
 String externalId, String title, String? subtitle, String? coverUrl, int? year, List<String> genres, String source, double score, List<RecommendationReason> reasons
});




}
/// @nodoc
class _$WishlistSuggestionCopyWithImpl<$Res>
    implements $WishlistSuggestionCopyWith<$Res> {
  _$WishlistSuggestionCopyWithImpl(this._self, this._then);

  final WishlistSuggestion _self;
  final $Res Function(WishlistSuggestion) _then;

/// Create a copy of WishlistSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? externalId = null,Object? title = null,Object? subtitle = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? genres = null,Object? source = null,Object? score = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<RecommendationReason>,
  ));
}

}


/// Adds pattern-matching-related methods to [WishlistSuggestion].
extension WishlistSuggestionPatterns on WishlistSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _WishlistSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String externalId,  String title,  String? subtitle,  String? coverUrl,  int? year,  List<String> genres,  String source,  double score,  List<RecommendationReason> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistSuggestion() when $default != null:
return $default(_that.externalId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.genres,_that.source,_that.score,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String externalId,  String title,  String? subtitle,  String? coverUrl,  int? year,  List<String> genres,  String source,  double score,  List<RecommendationReason> reasons)  $default,) {final _that = this;
switch (_that) {
case _WishlistSuggestion():
return $default(_that.externalId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.genres,_that.source,_that.score,_that.reasons);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String externalId,  String title,  String? subtitle,  String? coverUrl,  int? year,  List<String> genres,  String source,  double score,  List<RecommendationReason> reasons)?  $default,) {final _that = this;
switch (_that) {
case _WishlistSuggestion() when $default != null:
return $default(_that.externalId,_that.title,_that.subtitle,_that.coverUrl,_that.year,_that.genres,_that.source,_that.score,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc


class _WishlistSuggestion implements WishlistSuggestion {
  const _WishlistSuggestion({required this.externalId, required this.title, this.subtitle, this.coverUrl, this.year, final  List<String> genres = const [], required this.source, required this.score, required final  List<RecommendationReason> reasons}): _genres = genres,_reasons = reasons;
  

@override final  String externalId;
@override final  String title;
@override final  String? subtitle;
@override final  String? coverUrl;
@override final  int? year;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  String source;
@override final  double score;
 final  List<RecommendationReason> _reasons;
@override List<RecommendationReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of WishlistSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistSuggestionCopyWith<_WishlistSuggestion> get copyWith => __$WishlistSuggestionCopyWithImpl<_WishlistSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistSuggestion&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.source, source) || other.source == source)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}


@override
int get hashCode => Object.hash(runtimeType,externalId,title,subtitle,coverUrl,year,const DeepCollectionEquality().hash(_genres),source,score,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'WishlistSuggestion(externalId: $externalId, title: $title, subtitle: $subtitle, coverUrl: $coverUrl, year: $year, genres: $genres, source: $source, score: $score, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$WishlistSuggestionCopyWith<$Res> implements $WishlistSuggestionCopyWith<$Res> {
  factory _$WishlistSuggestionCopyWith(_WishlistSuggestion value, $Res Function(_WishlistSuggestion) _then) = __$WishlistSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String externalId, String title, String? subtitle, String? coverUrl, int? year, List<String> genres, String source, double score, List<RecommendationReason> reasons
});




}
/// @nodoc
class __$WishlistSuggestionCopyWithImpl<$Res>
    implements _$WishlistSuggestionCopyWith<$Res> {
  __$WishlistSuggestionCopyWithImpl(this._self, this._then);

  final _WishlistSuggestion _self;
  final $Res Function(_WishlistSuggestion) _then;

/// Create a copy of WishlistSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? externalId = null,Object? title = null,Object? subtitle = freezed,Object? coverUrl = freezed,Object? year = freezed,Object? genres = null,Object? source = null,Object? score = null,Object? reasons = null,}) {
  return _then(_WishlistSuggestion(
externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<RecommendationReason>,
  ));
}


}

// dart format on
