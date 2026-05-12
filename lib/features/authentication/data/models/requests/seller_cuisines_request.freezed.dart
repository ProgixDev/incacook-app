// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_cuisines_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerCuisinesRequest {

 List<CuisineType> get cuisines; List<DishType> get dishTypes;
/// Create a copy of SellerCuisinesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerCuisinesRequestCopyWith<SellerCuisinesRequest> get copyWith => _$SellerCuisinesRequestCopyWithImpl<SellerCuisinesRequest>(this as SellerCuisinesRequest, _$identity);

  /// Serializes this SellerCuisinesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerCuisinesRequest&&const DeepCollectionEquality().equals(other.cuisines, cuisines)&&const DeepCollectionEquality().equals(other.dishTypes, dishTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cuisines),const DeepCollectionEquality().hash(dishTypes));

@override
String toString() {
  return 'SellerCuisinesRequest(cuisines: $cuisines, dishTypes: $dishTypes)';
}


}

/// @nodoc
abstract mixin class $SellerCuisinesRequestCopyWith<$Res>  {
  factory $SellerCuisinesRequestCopyWith(SellerCuisinesRequest value, $Res Function(SellerCuisinesRequest) _then) = _$SellerCuisinesRequestCopyWithImpl;
@useResult
$Res call({
 List<CuisineType> cuisines, List<DishType> dishTypes
});




}
/// @nodoc
class _$SellerCuisinesRequestCopyWithImpl<$Res>
    implements $SellerCuisinesRequestCopyWith<$Res> {
  _$SellerCuisinesRequestCopyWithImpl(this._self, this._then);

  final SellerCuisinesRequest _self;
  final $Res Function(SellerCuisinesRequest) _then;

/// Create a copy of SellerCuisinesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cuisines = null,Object? dishTypes = null,}) {
  return _then(_self.copyWith(
cuisines: null == cuisines ? _self.cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self.dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerCuisinesRequest].
extension SellerCuisinesRequestPatterns on SellerCuisinesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerCuisinesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerCuisinesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerCuisinesRequest value)  $default,){
final _that = this;
switch (_that) {
case _SellerCuisinesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerCuisinesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SellerCuisinesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CuisineType> cuisines,  List<DishType> dishTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerCuisinesRequest() when $default != null:
return $default(_that.cuisines,_that.dishTypes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CuisineType> cuisines,  List<DishType> dishTypes)  $default,) {final _that = this;
switch (_that) {
case _SellerCuisinesRequest():
return $default(_that.cuisines,_that.dishTypes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CuisineType> cuisines,  List<DishType> dishTypes)?  $default,) {final _that = this;
switch (_that) {
case _SellerCuisinesRequest() when $default != null:
return $default(_that.cuisines,_that.dishTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerCuisinesRequest implements SellerCuisinesRequest {
  const _SellerCuisinesRequest({required final  List<CuisineType> cuisines, required final  List<DishType> dishTypes}): _cuisines = cuisines,_dishTypes = dishTypes;
  factory _SellerCuisinesRequest.fromJson(Map<String, dynamic> json) => _$SellerCuisinesRequestFromJson(json);

 final  List<CuisineType> _cuisines;
@override List<CuisineType> get cuisines {
  if (_cuisines is EqualUnmodifiableListView) return _cuisines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisines);
}

 final  List<DishType> _dishTypes;
@override List<DishType> get dishTypes {
  if (_dishTypes is EqualUnmodifiableListView) return _dishTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishTypes);
}


/// Create a copy of SellerCuisinesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerCuisinesRequestCopyWith<_SellerCuisinesRequest> get copyWith => __$SellerCuisinesRequestCopyWithImpl<_SellerCuisinesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerCuisinesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerCuisinesRequest&&const DeepCollectionEquality().equals(other._cuisines, _cuisines)&&const DeepCollectionEquality().equals(other._dishTypes, _dishTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cuisines),const DeepCollectionEquality().hash(_dishTypes));

@override
String toString() {
  return 'SellerCuisinesRequest(cuisines: $cuisines, dishTypes: $dishTypes)';
}


}

/// @nodoc
abstract mixin class _$SellerCuisinesRequestCopyWith<$Res> implements $SellerCuisinesRequestCopyWith<$Res> {
  factory _$SellerCuisinesRequestCopyWith(_SellerCuisinesRequest value, $Res Function(_SellerCuisinesRequest) _then) = __$SellerCuisinesRequestCopyWithImpl;
@override @useResult
$Res call({
 List<CuisineType> cuisines, List<DishType> dishTypes
});




}
/// @nodoc
class __$SellerCuisinesRequestCopyWithImpl<$Res>
    implements _$SellerCuisinesRequestCopyWith<$Res> {
  __$SellerCuisinesRequestCopyWithImpl(this._self, this._then);

  final _SellerCuisinesRequest _self;
  final $Res Function(_SellerCuisinesRequest) _then;

/// Create a copy of SellerCuisinesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cuisines = null,Object? dishTypes = null,}) {
  return _then(_SellerCuisinesRequest(
cuisines: null == cuisines ? _self._cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self._dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,
  ));
}


}

// dart format on
