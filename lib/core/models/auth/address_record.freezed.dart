// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressRecord {

 String get id; AddressType? get type; String? get customLabel; String get fullAddress; String get city; String get postalCode; String? get apartment; String? get floor; String? get digicode; String? get deliveryNotes; double? get lat; double? get lng;
/// Create a copy of AddressRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressRecordCopyWith<AddressRecord> get copyWith => _$AddressRecordCopyWithImpl<AddressRecord>(this as AddressRecord, _$identity);

  /// Serializes this AddressRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.customLabel, customLabel) || other.customLabel == customLabel)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.digicode, digicode) || other.digicode == digicode)&&(identical(other.deliveryNotes, deliveryNotes) || other.deliveryNotes == deliveryNotes)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,customLabel,fullAddress,city,postalCode,apartment,floor,digicode,deliveryNotes,lat,lng);

@override
String toString() {
  return 'AddressRecord(id: $id, type: $type, customLabel: $customLabel, fullAddress: $fullAddress, city: $city, postalCode: $postalCode, apartment: $apartment, floor: $floor, digicode: $digicode, deliveryNotes: $deliveryNotes, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $AddressRecordCopyWith<$Res>  {
  factory $AddressRecordCopyWith(AddressRecord value, $Res Function(AddressRecord) _then) = _$AddressRecordCopyWithImpl;
@useResult
$Res call({
 String id, AddressType? type, String? customLabel, String fullAddress, String city, String postalCode, String? apartment, String? floor, String? digicode, String? deliveryNotes, double? lat, double? lng
});




}
/// @nodoc
class _$AddressRecordCopyWithImpl<$Res>
    implements $AddressRecordCopyWith<$Res> {
  _$AddressRecordCopyWithImpl(this._self, this._then);

  final AddressRecord _self;
  final $Res Function(AddressRecord) _then;

/// Create a copy of AddressRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = freezed,Object? customLabel = freezed,Object? fullAddress = null,Object? city = null,Object? postalCode = null,Object? apartment = freezed,Object? floor = freezed,Object? digicode = freezed,Object? deliveryNotes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,digicode: freezed == digicode ? _self.digicode : digicode // ignore: cast_nullable_to_non_nullable
as String?,deliveryNotes: freezed == deliveryNotes ? _self.deliveryNotes : deliveryNotes // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressRecord].
extension AddressRecordPatterns on AddressRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressRecord value)  $default,){
final _that = this;
switch (_that) {
case _AddressRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AddressRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AddressType? type,  String? customLabel,  String fullAddress,  String city,  String postalCode,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressRecord() when $default != null:
return $default(_that.id,_that.type,_that.customLabel,_that.fullAddress,_that.city,_that.postalCode,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AddressType? type,  String? customLabel,  String fullAddress,  String city,  String postalCode,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _AddressRecord():
return $default(_that.id,_that.type,_that.customLabel,_that.fullAddress,_that.city,_that.postalCode,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AddressType? type,  String? customLabel,  String fullAddress,  String city,  String postalCode,  String? apartment,  String? floor,  String? digicode,  String? deliveryNotes,  double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _AddressRecord() when $default != null:
return $default(_that.id,_that.type,_that.customLabel,_that.fullAddress,_that.city,_that.postalCode,_that.apartment,_that.floor,_that.digicode,_that.deliveryNotes,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressRecord implements AddressRecord {
  const _AddressRecord({required this.id, this.type, this.customLabel, required this.fullAddress, required this.city, required this.postalCode, this.apartment, this.floor, this.digicode, this.deliveryNotes, this.lat, this.lng});
  factory _AddressRecord.fromJson(Map<String, dynamic> json) => _$AddressRecordFromJson(json);

@override final  String id;
@override final  AddressType? type;
@override final  String? customLabel;
@override final  String fullAddress;
@override final  String city;
@override final  String postalCode;
@override final  String? apartment;
@override final  String? floor;
@override final  String? digicode;
@override final  String? deliveryNotes;
@override final  double? lat;
@override final  double? lng;

/// Create a copy of AddressRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressRecordCopyWith<_AddressRecord> get copyWith => __$AddressRecordCopyWithImpl<_AddressRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.customLabel, customLabel) || other.customLabel == customLabel)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.digicode, digicode) || other.digicode == digicode)&&(identical(other.deliveryNotes, deliveryNotes) || other.deliveryNotes == deliveryNotes)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,customLabel,fullAddress,city,postalCode,apartment,floor,digicode,deliveryNotes,lat,lng);

@override
String toString() {
  return 'AddressRecord(id: $id, type: $type, customLabel: $customLabel, fullAddress: $fullAddress, city: $city, postalCode: $postalCode, apartment: $apartment, floor: $floor, digicode: $digicode, deliveryNotes: $deliveryNotes, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$AddressRecordCopyWith<$Res> implements $AddressRecordCopyWith<$Res> {
  factory _$AddressRecordCopyWith(_AddressRecord value, $Res Function(_AddressRecord) _then) = __$AddressRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, AddressType? type, String? customLabel, String fullAddress, String city, String postalCode, String? apartment, String? floor, String? digicode, String? deliveryNotes, double? lat, double? lng
});




}
/// @nodoc
class __$AddressRecordCopyWithImpl<$Res>
    implements _$AddressRecordCopyWith<$Res> {
  __$AddressRecordCopyWithImpl(this._self, this._then);

  final _AddressRecord _self;
  final $Res Function(_AddressRecord) _then;

/// Create a copy of AddressRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = freezed,Object? customLabel = freezed,Object? fullAddress = null,Object? city = null,Object? postalCode = null,Object? apartment = freezed,Object? floor = freezed,Object? digicode = freezed,Object? deliveryNotes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_AddressRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,customLabel: freezed == customLabel ? _self.customLabel : customLabel // ignore: cast_nullable_to_non_nullable
as String?,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
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
