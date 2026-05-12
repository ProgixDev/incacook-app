// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_zones_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverZonesRequest {

 List<String> get zones;
/// Create a copy of DriverZonesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverZonesRequestCopyWith<DriverZonesRequest> get copyWith => _$DriverZonesRequestCopyWithImpl<DriverZonesRequest>(this as DriverZonesRequest, _$identity);

  /// Serializes this DriverZonesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverZonesRequest&&const DeepCollectionEquality().equals(other.zones, zones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(zones));

@override
String toString() {
  return 'DriverZonesRequest(zones: $zones)';
}


}

/// @nodoc
abstract mixin class $DriverZonesRequestCopyWith<$Res>  {
  factory $DriverZonesRequestCopyWith(DriverZonesRequest value, $Res Function(DriverZonesRequest) _then) = _$DriverZonesRequestCopyWithImpl;
@useResult
$Res call({
 List<String> zones
});




}
/// @nodoc
class _$DriverZonesRequestCopyWithImpl<$Res>
    implements $DriverZonesRequestCopyWith<$Res> {
  _$DriverZonesRequestCopyWithImpl(this._self, this._then);

  final DriverZonesRequest _self;
  final $Res Function(DriverZonesRequest) _then;

/// Create a copy of DriverZonesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zones = null,}) {
  return _then(_self.copyWith(
zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverZonesRequest].
extension DriverZonesRequestPatterns on DriverZonesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverZonesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverZonesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverZonesRequest value)  $default,){
final _that = this;
switch (_that) {
case _DriverZonesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverZonesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DriverZonesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> zones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverZonesRequest() when $default != null:
return $default(_that.zones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> zones)  $default,) {final _that = this;
switch (_that) {
case _DriverZonesRequest():
return $default(_that.zones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> zones)?  $default,) {final _that = this;
switch (_that) {
case _DriverZonesRequest() when $default != null:
return $default(_that.zones);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverZonesRequest implements DriverZonesRequest {
  const _DriverZonesRequest({required final  List<String> zones}): _zones = zones;
  factory _DriverZonesRequest.fromJson(Map<String, dynamic> json) => _$DriverZonesRequestFromJson(json);

 final  List<String> _zones;
@override List<String> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}


/// Create a copy of DriverZonesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverZonesRequestCopyWith<_DriverZonesRequest> get copyWith => __$DriverZonesRequestCopyWithImpl<_DriverZonesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverZonesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverZonesRequest&&const DeepCollectionEquality().equals(other._zones, _zones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_zones));

@override
String toString() {
  return 'DriverZonesRequest(zones: $zones)';
}


}

/// @nodoc
abstract mixin class _$DriverZonesRequestCopyWith<$Res> implements $DriverZonesRequestCopyWith<$Res> {
  factory _$DriverZonesRequestCopyWith(_DriverZonesRequest value, $Res Function(_DriverZonesRequest) _then) = __$DriverZonesRequestCopyWithImpl;
@override @useResult
$Res call({
 List<String> zones
});




}
/// @nodoc
class __$DriverZonesRequestCopyWithImpl<$Res>
    implements _$DriverZonesRequestCopyWith<$Res> {
  __$DriverZonesRequestCopyWithImpl(this._self, this._then);

  final _DriverZonesRequest _self;
  final $Res Function(_DriverZonesRequest) _then;

/// Create a copy of DriverZonesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zones = null,}) {
  return _then(_DriverZonesRequest(
zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
