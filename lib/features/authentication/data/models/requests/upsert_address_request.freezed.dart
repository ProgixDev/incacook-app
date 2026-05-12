// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upsert_address_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpsertAddressRequest {

 String get fullAddress; String get city; String get postalCode; AddressType? get type; String? get customLabel; String? get apartment; String? get floor; String? get digicode; String? get deliveryNotes; double? get lat; double? get lng;
/// Create a copy of UpsertAddressRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpsertAddressRequestCopyWith<UpsertAddressRequest> get copyWith => _$UpsertAddressRequestCopyWithImpl<UpsertAddressRequest>(this as UpsertAddressRequest, _$identity);

  /// Serializes this UpsertAddressRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpsertAddressRequest&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.customLabel, customLabel) || other.customLabel == customLabel)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.digicode, digicode) || other.digicode == digicode)&&(identical(other.deliveryNotes, deliveryNotes) || other.deliveryNotes == deliveryNotes)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullAddress,city,postalCode,type,customLabel,apartment,floor,digicode,deliveryNotes,lat,lng);

@override
String toString() {
  return 'UpsertAddressRequest(fullAddress: $fullAddress, city: $city, postalCode: $postalCode, type: $type, customLabel: $customLabel, apartment: $apartment, floor: $floor, digicode: $digicode, deliveryNotes: $deliveryNotes, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $UpsertAddressRequestCopyWith<$Res>  {
  factory $UpsertAddressRequestCopyWith(UpsertAddressRequest value, $Res Function(UpsertAddressRequest) _then) = _$UpsertAddressRequestCopyWithImpl;
@useResult
$Res call({
 String fullAddress, String city, String postalCode, AddressType? type, String? customLabel, String? apartment, String? floor, String? digicode, String? deliveryNotes, double? lat, double? lng
});




}
/// @nodoc
class _$UpsertAddressRequestCopyWithImpl<$Res>
    implements $UpsertAddressRequestCopyWith<$Res> {
  _$UpsertAddressRequestCopyWithImpl(this._self, this._then);

  final UpsertAddressRequest _self;
  final $Res Function(UpsertAddressRequest) _then;

/// Create a copy of UpsertAddressRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullAddress = null,Object? city = null,Object? postalCode = null,Object? type = freezed,Object? customLabel = freezed,Object? apartment = freezed,Object? floor = freezed,Object? digicode = freezed,Object? deliveryNotes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_self.copyWith(
fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,digicode: freezed == digicode ? _self.digicode : digicode // ignore: cast_nullable_to_non_nullable
as String?,deliveryNotes: freezed == deliveryNotes ? _self.deliveryNotes : deliveryNotes // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpsertAddressRequest].
extension UpsertAddressRequestPatterns on UpsertAddressRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpsertAddressRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpsertAddressRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpsertAddressRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpsertAddressRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpsertAddressRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpsertAddressRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullAddress,  String city,  String postalCode,  AddressType? type,  String? customLabel,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpsertAddressRequest() when $default != null:
return $default(_that.fullAddress,_that.city,_that.postalCode,_that.type,_that.customLabel,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullAddress,  String city,  String postalCode,  AddressType? type,  String? customLabel,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _UpsertAddressRequest():
return $default(_that.fullAddress,_that.city,_that.postalCode,_that.type,_that.customLabel,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullAddress,  String city,  String postalCode,  AddressType? type,  String? customLabel,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _UpsertAddressRequest() when $default != null:
return $default(_that.fullAddress,_that.city,_that.postalCode,_that.type,_that.customLabel,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpsertAddressRequest implements UpsertAddressRequest {
  const _UpsertAddressRequest({required this.fullAddress, required this.city, required this.postalCode, this.type, this.customLabel, this.apartment, this.floor, this.digicode, this.deliveryNotes, this.lat, this.lng});
  factory _UpsertAddressRequest.fromJson(Map<String, dynamic> json) => _$UpsertAddressRequestFromJson(json);

@override final  String fullAddress;
@override final  String city;
@override final  String postalCode;
@override final  AddressType? type;
@override final  String? customLabel;
@override final  String? apartment;
@override final  String? floor;
@override final  String? digicode;
@override final  String? deliveryNotes;
@override final  double? lat;
@override final  double? lng;

/// Create a copy of UpsertAddressRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpsertAddressRequestCopyWith<_UpsertAddressRequest> get copyWith => __$UpsertAddressRequestCopyWithImpl<_UpsertAddressRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpsertAddressRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpsertAddressRequest&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.customLabel, customLabel) || other.customLabel == customLabel)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.digicode, digicode) || other.digicode == digicode)&&(identical(other.deliveryNotes, deliveryNotes) || other.deliveryNotes == deliveryNotes)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullAddress,city,postalCode,type,customLabel,apartment,floor,digicode,deliveryNotes,lat,lng);

@override
String toString() {
  return 'UpsertAddressRequest(fullAddress: $fullAddress, city: $city, postalCode: $postalCode, type: $type, customLabel: $customLabel, apartment: $apartment, floor: $floor, digicode: $digicode, deliveryNotes: $deliveryNotes, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$UpsertAddressRequestCopyWith<$Res> implements $UpsertAddressRequestCopyWith<$Res> {
  factory _$UpsertAddressRequestCopyWith(_UpsertAddressRequest value, $Res Function(_UpsertAddressRequest) _then) = __$UpsertAddressRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullAddress, String city, String postalCode, AddressType? type, String? customLabel, String? apartment, String? floor, String? digicode, String? deliveryNotes, double? lat, double? lng
});




}
/// @nodoc
class __$UpsertAddressRequestCopyWithImpl<$Res>
    implements _$UpsertAddressRequestCopyWith<$Res> {
  __$UpsertAddressRequestCopyWithImpl(this._self, this._then);

  final _UpsertAddressRequest _self;
  final $Res Function(_UpsertAddressRequest) _then;

/// Create a copy of UpsertAddressRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullAddress = null,Object? city = null,Object? postalCode = null,Object? type = freezed,Object? customLabel = freezed,Object? apartment = freezed,Object? floor = freezed,Object? digicode = freezed,Object? deliveryNotes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_UpsertAddressRequest(
fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,digicode: freezed == digicode ? _self.digicode : digicode // ignore: cast_nullable_to_non_nullable
as String?,deliveryNotes: freezed == deliveryNotes ? _self.deliveryNotes : deliveryNotes // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
