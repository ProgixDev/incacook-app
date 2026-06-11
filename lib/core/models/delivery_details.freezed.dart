// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryDetails {

 Address get address; String get instructions; DeliveryTiming get timing; DateTime? get scheduledAt;/// Buyer's display name — shown to the driver as the recipient at
/// the dropoff. Null when not resolved (e.g. buyer-side views).
 String? get recipientName;
/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDetailsCopyWith<DeliveryDetails> get copyWith => _$DeliveryDetailsCopyWithImpl<DeliveryDetails>(this as DeliveryDetails, _$identity);

  /// Serializes this DeliveryDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDetails&&(identical(other.address, address) || other.address == address)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.timing, timing) || other.timing == timing)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,instructions,timing,scheduledAt,recipientName);

@override
String toString() {
  return 'DeliveryDetails(address: $address, instructions: $instructions, timing: $timing, scheduledAt: $scheduledAt, recipientName: $recipientName)';
}


}

/// @nodoc
abstract mixin class $DeliveryDetailsCopyWith<$Res>  {
  factory $DeliveryDetailsCopyWith(DeliveryDetails value, $Res Function(DeliveryDetails) _then) = _$DeliveryDetailsCopyWithImpl;
@useResult
$Res call({
 Address address, String instructions, DeliveryTiming timing, DateTime? scheduledAt, String? recipientName
});


$AddressCopyWith<$Res> get address;

}
/// @nodoc
class _$DeliveryDetailsCopyWithImpl<$Res>
    implements $DeliveryDetailsCopyWith<$Res> {
  _$DeliveryDetailsCopyWithImpl(this._self, this._then);

  final DeliveryDetails _self;
  final $Res Function(DeliveryDetails) _then;

/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? instructions = null,Object? timing = null,Object? scheduledAt = freezed,Object? recipientName = freezed,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,timing: null == timing ? _self.timing : timing // ignore: cast_nullable_to_non_nullable
as DeliveryTiming,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeliveryDetails].
extension DeliveryDetailsPatterns on DeliveryDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryDetails value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryDetails value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Address address,  String instructions,  DeliveryTiming timing,  DateTime? scheduledAt,  String? recipientName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryDetails() when $default != null:
return $default(_that.address,_that.instructions,_that.timing,_that.scheduledAt,_that.recipientName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Address address,  String instructions,  DeliveryTiming timing,  DateTime? scheduledAt,  String? recipientName)  $default,) {final _that = this;
switch (_that) {
case _DeliveryDetails():
return $default(_that.address,_that.instructions,_that.timing,_that.scheduledAt,_that.recipientName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Address address,  String instructions,  DeliveryTiming timing,  DateTime? scheduledAt,  String? recipientName)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryDetails() when $default != null:
return $default(_that.address,_that.instructions,_that.timing,_that.scheduledAt,_that.recipientName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryDetails implements DeliveryDetails {
  const _DeliveryDetails({required this.address, required this.instructions, required this.timing, this.scheduledAt, this.recipientName});
  factory _DeliveryDetails.fromJson(Map<String, dynamic> json) => _$DeliveryDetailsFromJson(json);

@override final  Address address;
@override final  String instructions;
@override final  DeliveryTiming timing;
@override final  DateTime? scheduledAt;
/// Buyer's display name — shown to the driver as the recipient at
/// the dropoff. Null when not resolved (e.g. buyer-side views).
@override final  String? recipientName;

/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDetailsCopyWith<_DeliveryDetails> get copyWith => __$DeliveryDetailsCopyWithImpl<_DeliveryDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDetails&&(identical(other.address, address) || other.address == address)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.timing, timing) || other.timing == timing)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,instructions,timing,scheduledAt,recipientName);

@override
String toString() {
  return 'DeliveryDetails(address: $address, instructions: $instructions, timing: $timing, scheduledAt: $scheduledAt, recipientName: $recipientName)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDetailsCopyWith<$Res> implements $DeliveryDetailsCopyWith<$Res> {
  factory _$DeliveryDetailsCopyWith(_DeliveryDetails value, $Res Function(_DeliveryDetails) _then) = __$DeliveryDetailsCopyWithImpl;
@override @useResult
$Res call({
 Address address, String instructions, DeliveryTiming timing, DateTime? scheduledAt, String? recipientName
});


@override $AddressCopyWith<$Res> get address;

}
/// @nodoc
class __$DeliveryDetailsCopyWithImpl<$Res>
    implements _$DeliveryDetailsCopyWith<$Res> {
  __$DeliveryDetailsCopyWithImpl(this._self, this._then);

  final _DeliveryDetails _self;
  final $Res Function(_DeliveryDetails) _then;

/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? instructions = null,Object? timing = null,Object? scheduledAt = freezed,Object? recipientName = freezed,}) {
  return _then(_DeliveryDetails(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,timing: null == timing ? _self.timing : timing // ignore: cast_nullable_to_non_nullable
as DeliveryTiming,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DeliveryDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}

// dart format on
