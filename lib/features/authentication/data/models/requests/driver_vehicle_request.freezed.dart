// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_vehicle_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverVehicleRequest {

 DriverVehicleType get vehicleType; String? get dateOfBirth;
/// Create a copy of DriverVehicleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverVehicleRequestCopyWith<DriverVehicleRequest> get copyWith => _$DriverVehicleRequestCopyWithImpl<DriverVehicleRequest>(this as DriverVehicleRequest, _$identity);

  /// Serializes this DriverVehicleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverVehicleRequest&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,dateOfBirth);

@override
String toString() {
  return 'DriverVehicleRequest(vehicleType: $vehicleType, dateOfBirth: $dateOfBirth)';
}


}

/// @nodoc
abstract mixin class $DriverVehicleRequestCopyWith<$Res>  {
  factory $DriverVehicleRequestCopyWith(DriverVehicleRequest value, $Res Function(DriverVehicleRequest) _then) = _$DriverVehicleRequestCopyWithImpl;
@useResult
$Res call({
 DriverVehicleType vehicleType, String? dateOfBirth
});




}
/// @nodoc
class _$DriverVehicleRequestCopyWithImpl<$Res>
    implements $DriverVehicleRequestCopyWith<$Res> {
  _$DriverVehicleRequestCopyWithImpl(this._self, this._then);

  final DriverVehicleRequest _self;
  final $Res Function(DriverVehicleRequest) _then;

/// Create a copy of DriverVehicleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleType = null,Object? dateOfBirth = freezed,}) {
  return _then(_self.copyWith(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as DriverVehicleType,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverVehicleRequest].
extension DriverVehicleRequestPatterns on DriverVehicleRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverVehicleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverVehicleRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverVehicleRequest value)  $default,){
final _that = this;
switch (_that) {
case _DriverVehicleRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverVehicleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DriverVehicleRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DriverVehicleType vehicleType,  String? dateOfBirth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverVehicleRequest() when $default != null:
return $default(_that.vehicleType,_that.dateOfBirth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DriverVehicleType vehicleType,  String? dateOfBirth)  $default,) {final _that = this;
switch (_that) {
case _DriverVehicleRequest():
return $default(_that.vehicleType,_that.dateOfBirth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DriverVehicleType vehicleType,  String? dateOfBirth)?  $default,) {final _that = this;
switch (_that) {
case _DriverVehicleRequest() when $default != null:
return $default(_that.vehicleType,_that.dateOfBirth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverVehicleRequest implements DriverVehicleRequest {
  const _DriverVehicleRequest({required this.vehicleType, this.dateOfBirth});
  factory _DriverVehicleRequest.fromJson(Map<String, dynamic> json) => _$DriverVehicleRequestFromJson(json);

@override final  DriverVehicleType vehicleType;
@override final  String? dateOfBirth;

/// Create a copy of DriverVehicleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverVehicleRequestCopyWith<_DriverVehicleRequest> get copyWith => __$DriverVehicleRequestCopyWithImpl<_DriverVehicleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverVehicleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverVehicleRequest&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,dateOfBirth);

@override
String toString() {
  return 'DriverVehicleRequest(vehicleType: $vehicleType, dateOfBirth: $dateOfBirth)';
}


}

/// @nodoc
abstract mixin class _$DriverVehicleRequestCopyWith<$Res> implements $DriverVehicleRequestCopyWith<$Res> {
  factory _$DriverVehicleRequestCopyWith(_DriverVehicleRequest value, $Res Function(_DriverVehicleRequest) _then) = __$DriverVehicleRequestCopyWithImpl;
@override @useResult
$Res call({
 DriverVehicleType vehicleType, String? dateOfBirth
});




}
/// @nodoc
class __$DriverVehicleRequestCopyWithImpl<$Res>
    implements _$DriverVehicleRequestCopyWith<$Res> {
  __$DriverVehicleRequestCopyWithImpl(this._self, this._then);

  final _DriverVehicleRequest _self;
  final $Res Function(_DriverVehicleRequest) _then;

/// Create a copy of DriverVehicleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleType = null,Object? dateOfBirth = freezed,}) {
  return _then(_DriverVehicleRequest(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as DriverVehicleType,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
