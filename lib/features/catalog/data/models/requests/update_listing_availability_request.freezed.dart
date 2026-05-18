// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_listing_availability_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateListingAvailabilityRequest {

 bool get isAvailable;
/// Create a copy of UpdateListingAvailabilityRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateListingAvailabilityRequestCopyWith<UpdateListingAvailabilityRequest> get copyWith => _$UpdateListingAvailabilityRequestCopyWithImpl<UpdateListingAvailabilityRequest>(this as UpdateListingAvailabilityRequest, _$identity);

  /// Serializes this UpdateListingAvailabilityRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateListingAvailabilityRequest&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAvailable);

@override
String toString() {
  return 'UpdateListingAvailabilityRequest(isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class $UpdateListingAvailabilityRequestCopyWith<$Res>  {
  factory $UpdateListingAvailabilityRequestCopyWith(UpdateListingAvailabilityRequest value, $Res Function(UpdateListingAvailabilityRequest) _then) = _$UpdateListingAvailabilityRequestCopyWithImpl;
@useResult
$Res call({
 bool isAvailable
});




}
/// @nodoc
class _$UpdateListingAvailabilityRequestCopyWithImpl<$Res>
    implements $UpdateListingAvailabilityRequestCopyWith<$Res> {
  _$UpdateListingAvailabilityRequestCopyWithImpl(this._self, this._then);

  final UpdateListingAvailabilityRequest _self;
  final $Res Function(UpdateListingAvailabilityRequest) _then;

/// Create a copy of UpdateListingAvailabilityRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAvailable = null,}) {
  return _then(_self.copyWith(
isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateListingAvailabilityRequest].
extension UpdateListingAvailabilityRequestPatterns on UpdateListingAvailabilityRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateListingAvailabilityRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateListingAvailabilityRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateListingAvailabilityRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest() when $default != null:
return $default(_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest():
return $default(_that.isAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _UpdateListingAvailabilityRequest() when $default != null:
return $default(_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateListingAvailabilityRequest implements UpdateListingAvailabilityRequest {
  const _UpdateListingAvailabilityRequest({required this.isAvailable});
  factory _UpdateListingAvailabilityRequest.fromJson(Map<String, dynamic> json) => _$UpdateListingAvailabilityRequestFromJson(json);

@override final  bool isAvailable;

/// Create a copy of UpdateListingAvailabilityRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateListingAvailabilityRequestCopyWith<_UpdateListingAvailabilityRequest> get copyWith => __$UpdateListingAvailabilityRequestCopyWithImpl<_UpdateListingAvailabilityRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateListingAvailabilityRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateListingAvailabilityRequest&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAvailable);

@override
String toString() {
  return 'UpdateListingAvailabilityRequest(isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$UpdateListingAvailabilityRequestCopyWith<$Res> implements $UpdateListingAvailabilityRequestCopyWith<$Res> {
  factory _$UpdateListingAvailabilityRequestCopyWith(_UpdateListingAvailabilityRequest value, $Res Function(_UpdateListingAvailabilityRequest) _then) = __$UpdateListingAvailabilityRequestCopyWithImpl;
@override @useResult
$Res call({
 bool isAvailable
});




}
/// @nodoc
class __$UpdateListingAvailabilityRequestCopyWithImpl<$Res>
    implements _$UpdateListingAvailabilityRequestCopyWith<$Res> {
  __$UpdateListingAvailabilityRequestCopyWithImpl(this._self, this._then);

  final _UpdateListingAvailabilityRequest _self;
  final $Res Function(_UpdateListingAvailabilityRequest) _then;

/// Create a copy of UpdateListingAvailabilityRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAvailable = null,}) {
  return _then(_UpdateListingAvailabilityRequest(
isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
