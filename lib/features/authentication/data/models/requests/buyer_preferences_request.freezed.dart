// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buyer_preferences_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuyerPreferencesRequest {

 List<DietaryTag> get dietaryTags; List<Allergen> get allergens;
/// Create a copy of BuyerPreferencesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuyerPreferencesRequestCopyWith<BuyerPreferencesRequest> get copyWith => _$BuyerPreferencesRequestCopyWithImpl<BuyerPreferencesRequest>(this as BuyerPreferencesRequest, _$identity);

  /// Serializes this BuyerPreferencesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuyerPreferencesRequest&&const DeepCollectionEquality().equals(other.dietaryTags, dietaryTags)&&const DeepCollectionEquality().equals(other.allergens, allergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dietaryTags),const DeepCollectionEquality().hash(allergens));

@override
String toString() {
  return 'BuyerPreferencesRequest(dietaryTags: $dietaryTags, allergens: $allergens)';
}


}

/// @nodoc
abstract mixin class $BuyerPreferencesRequestCopyWith<$Res>  {
  factory $BuyerPreferencesRequestCopyWith(BuyerPreferencesRequest value, $Res Function(BuyerPreferencesRequest) _then) = _$BuyerPreferencesRequestCopyWithImpl;
@useResult
$Res call({
 List<DietaryTag> dietaryTags, List<Allergen> allergens
});




}
/// @nodoc
class _$BuyerPreferencesRequestCopyWithImpl<$Res>
    implements $BuyerPreferencesRequestCopyWith<$Res> {
  _$BuyerPreferencesRequestCopyWithImpl(this._self, this._then);

  final BuyerPreferencesRequest _self;
  final $Res Function(BuyerPreferencesRequest) _then;

/// Create a copy of BuyerPreferencesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dietaryTags = null,Object? allergens = null,}) {
  return _then(_self.copyWith(
dietaryTags: null == dietaryTags ? _self.dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,
  ));
}

}


/// Adds pattern-matching-related methods to [BuyerPreferencesRequest].
extension BuyerPreferencesRequestPatterns on BuyerPreferencesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuyerPreferencesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuyerPreferencesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuyerPreferencesRequest value)  $default,){
final _that = this;
switch (_that) {
case _BuyerPreferencesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuyerPreferencesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BuyerPreferencesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DietaryTag> dietaryTags,  List<Allergen> allergens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuyerPreferencesRequest() when $default != null:
return $default(_that.dietaryTags,_that.allergens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DietaryTag> dietaryTags,  List<Allergen> allergens)  $default,) {final _that = this;
switch (_that) {
case _BuyerPreferencesRequest():
return $default(_that.dietaryTags,_that.allergens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DietaryTag> dietaryTags,  List<Allergen> allergens)?  $default,) {final _that = this;
switch (_that) {
case _BuyerPreferencesRequest() when $default != null:
return $default(_that.dietaryTags,_that.allergens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuyerPreferencesRequest implements BuyerPreferencesRequest {
  const _BuyerPreferencesRequest({final  List<DietaryTag> dietaryTags = const <DietaryTag>[], final  List<Allergen> allergens = const <Allergen>[]}): _dietaryTags = dietaryTags,_allergens = allergens;
  factory _BuyerPreferencesRequest.fromJson(Map<String, dynamic> json) => _$BuyerPreferencesRequestFromJson(json);

 final  List<DietaryTag> _dietaryTags;
@override@JsonKey() List<DietaryTag> get dietaryTags {
  if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryTags);
}

 final  List<Allergen> _allergens;
@override@JsonKey() List<Allergen> get allergens {
  if (_allergens is EqualUnmodifiableListView) return _allergens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergens);
}


/// Create a copy of BuyerPreferencesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuyerPreferencesRequestCopyWith<_BuyerPreferencesRequest> get copyWith => __$BuyerPreferencesRequestCopyWithImpl<_BuyerPreferencesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuyerPreferencesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuyerPreferencesRequest&&const DeepCollectionEquality().equals(other._dietaryTags, _dietaryTags)&&const DeepCollectionEquality().equals(other._allergens, _allergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dietaryTags),const DeepCollectionEquality().hash(_allergens));

@override
String toString() {
  return 'BuyerPreferencesRequest(dietaryTags: $dietaryTags, allergens: $allergens)';
}


}

/// @nodoc
abstract mixin class _$BuyerPreferencesRequestCopyWith<$Res> implements $BuyerPreferencesRequestCopyWith<$Res> {
  factory _$BuyerPreferencesRequestCopyWith(_BuyerPreferencesRequest value, $Res Function(_BuyerPreferencesRequest) _then) = __$BuyerPreferencesRequestCopyWithImpl;
@override @useResult
$Res call({
 List<DietaryTag> dietaryTags, List<Allergen> allergens
});




}
/// @nodoc
class __$BuyerPreferencesRequestCopyWithImpl<$Res>
    implements _$BuyerPreferencesRequestCopyWith<$Res> {
  __$BuyerPreferencesRequestCopyWithImpl(this._self, this._then);

  final _BuyerPreferencesRequest _self;
  final $Res Function(_BuyerPreferencesRequest) _then;

/// Create a copy of BuyerPreferencesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dietaryTags = null,Object? allergens = null,}) {
  return _then(_BuyerPreferencesRequest(
dietaryTags: null == dietaryTags ? _self._dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,
  ));
}


}

// dart format on
