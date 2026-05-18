// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_extra_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingExtraRequest {

 String get label; int get priceDeltaCents; bool? get isSelectedByDefault;
/// Create a copy of ListingExtraRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingExtraRequestCopyWith<ListingExtraRequest> get copyWith => _$ListingExtraRequestCopyWithImpl<ListingExtraRequest>(this as ListingExtraRequest, _$identity);

  /// Serializes this ListingExtraRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingExtraRequest&&(identical(other.label, label) || other.label == label)&&(identical(other.priceDeltaCents, priceDeltaCents) || other.priceDeltaCents == priceDeltaCents)&&(identical(other.isSelectedByDefault, isSelectedByDefault) || other.isSelectedByDefault == isSelectedByDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,priceDeltaCents,isSelectedByDefault);

@override
String toString() {
  return 'ListingExtraRequest(label: $label, priceDeltaCents: $priceDeltaCents, isSelectedByDefault: $isSelectedByDefault)';
}


}

/// @nodoc
abstract mixin class $ListingExtraRequestCopyWith<$Res>  {
  factory $ListingExtraRequestCopyWith(ListingExtraRequest value, $Res Function(ListingExtraRequest) _then) = _$ListingExtraRequestCopyWithImpl;
@useResult
$Res call({
 String label, int priceDeltaCents, bool? isSelectedByDefault
});




}
/// @nodoc
class _$ListingExtraRequestCopyWithImpl<$Res>
    implements $ListingExtraRequestCopyWith<$Res> {
  _$ListingExtraRequestCopyWithImpl(this._self, this._then);

  final ListingExtraRequest _self;
  final $Res Function(ListingExtraRequest) _then;

/// Create a copy of ListingExtraRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? priceDeltaCents = null,Object? isSelectedByDefault = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,priceDeltaCents: null == priceDeltaCents ? _self.priceDeltaCents : priceDeltaCents // ignore: cast_nullable_to_non_nullable
as int,isSelectedByDefault: freezed == isSelectedByDefault ? _self.isSelectedByDefault : isSelectedByDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingExtraRequest].
extension ListingExtraRequestPatterns on ListingExtraRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingExtraRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingExtraRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingExtraRequest value)  $default,){
final _that = this;
switch (_that) {
case _ListingExtraRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingExtraRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ListingExtraRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int priceDeltaCents,  bool? isSelectedByDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingExtraRequest() when $default != null:
return $default(_that.label,_that.priceDeltaCents,_that.isSelectedByDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int priceDeltaCents,  bool? isSelectedByDefault)  $default,) {final _that = this;
switch (_that) {
case _ListingExtraRequest():
return $default(_that.label,_that.priceDeltaCents,_that.isSelectedByDefault);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int priceDeltaCents,  bool? isSelectedByDefault)?  $default,) {final _that = this;
switch (_that) {
case _ListingExtraRequest() when $default != null:
return $default(_that.label,_that.priceDeltaCents,_that.isSelectedByDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingExtraRequest implements ListingExtraRequest {
  const _ListingExtraRequest({required this.label, required this.priceDeltaCents, this.isSelectedByDefault});
  factory _ListingExtraRequest.fromJson(Map<String, dynamic> json) => _$ListingExtraRequestFromJson(json);

@override final  String label;
@override final  int priceDeltaCents;
@override final  bool? isSelectedByDefault;

/// Create a copy of ListingExtraRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingExtraRequestCopyWith<_ListingExtraRequest> get copyWith => __$ListingExtraRequestCopyWithImpl<_ListingExtraRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingExtraRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingExtraRequest&&(identical(other.label, label) || other.label == label)&&(identical(other.priceDeltaCents, priceDeltaCents) || other.priceDeltaCents == priceDeltaCents)&&(identical(other.isSelectedByDefault, isSelectedByDefault) || other.isSelectedByDefault == isSelectedByDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,priceDeltaCents,isSelectedByDefault);

@override
String toString() {
  return 'ListingExtraRequest(label: $label, priceDeltaCents: $priceDeltaCents, isSelectedByDefault: $isSelectedByDefault)';
}


}

/// @nodoc
abstract mixin class _$ListingExtraRequestCopyWith<$Res> implements $ListingExtraRequestCopyWith<$Res> {
  factory _$ListingExtraRequestCopyWith(_ListingExtraRequest value, $Res Function(_ListingExtraRequest) _then) = __$ListingExtraRequestCopyWithImpl;
@override @useResult
$Res call({
 String label, int priceDeltaCents, bool? isSelectedByDefault
});




}
/// @nodoc
class __$ListingExtraRequestCopyWithImpl<$Res>
    implements _$ListingExtraRequestCopyWith<$Res> {
  __$ListingExtraRequestCopyWithImpl(this._self, this._then);

  final _ListingExtraRequest _self;
  final $Res Function(_ListingExtraRequest) _then;

/// Create a copy of ListingExtraRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? priceDeltaCents = null,Object? isSelectedByDefault = freezed,}) {
  return _then(_ListingExtraRequest(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,priceDeltaCents: null == priceDeltaCents ? _self.priceDeltaCents : priceDeltaCents // ignore: cast_nullable_to_non_nullable
as int,isSelectedByDefault: freezed == isSelectedByDefault ? _self.isSelectedByDefault : isSelectedByDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
