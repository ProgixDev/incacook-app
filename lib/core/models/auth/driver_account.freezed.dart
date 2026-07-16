// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverAccount {

 DriverVehicleType? get vehicleType; String? get dateOfBirth; List<String> get zones; bool get canDeliver;// Payout/identity gate fields (mirror DriverProfileResponseDto). Drive the
// delivery-claim gate: a driver can only claim once KYC is APPROVED and
// Stripe Connect payout onboarding is complete.
 String get kycStatus; bool get stripeOnboardingCompleted;// Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
// send them" stays distinguishable from an explicit false — readiness
// then falls back to [stripeOnboardingCompleted]. Derivation lives in
// `payout_readiness.dart` ([DriverPayoutReadiness]).
 bool? get detailsSubmitted; bool? get chargesEnabled; bool? get payoutsEnabled;// Server-side online flag (mirrors DriverProfile.isOnline). Read on
// relaunch to restore the driver's online session — the local toggle
// otherwise always boots to offline. See DeliveryDriverController.
 bool get isOnline;
/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverAccountCopyWith<DriverAccount> get copyWith => _$DriverAccountCopyWithImpl<DriverAccount>(this as DriverAccount, _$identity);

  /// Serializes this DriverAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverAccount&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&const DeepCollectionEquality().equals(other.zones, zones)&&(identical(other.canDeliver, canDeliver) || other.canDeliver == canDeliver)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.stripeOnboardingCompleted, stripeOnboardingCompleted) || other.stripeOnboardingCompleted == stripeOnboardingCompleted)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,dateOfBirth,const DeepCollectionEquality().hash(zones),canDeliver,kycStatus,stripeOnboardingCompleted,detailsSubmitted,chargesEnabled,payoutsEnabled,isOnline);

@override
String toString() {
  return 'DriverAccount(vehicleType: $vehicleType, dateOfBirth: $dateOfBirth, zones: $zones, canDeliver: $canDeliver, kycStatus: $kycStatus, stripeOnboardingCompleted: $stripeOnboardingCompleted, detailsSubmitted: $detailsSubmitted, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class $DriverAccountCopyWith<$Res>  {
  factory $DriverAccountCopyWith(DriverAccount value, $Res Function(DriverAccount) _then) = _$DriverAccountCopyWithImpl;
@useResult
$Res call({
 DriverVehicleType? vehicleType, String? dateOfBirth, List<String> zones, bool canDeliver, String kycStatus, bool stripeOnboardingCompleted, bool? detailsSubmitted, bool? chargesEnabled, bool? payoutsEnabled, bool isOnline
});




}
/// @nodoc
class _$DriverAccountCopyWithImpl<$Res>
    implements $DriverAccountCopyWith<$Res> {
  _$DriverAccountCopyWithImpl(this._self, this._then);

  final DriverAccount _self;
  final $Res Function(DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleType = freezed,Object? dateOfBirth = freezed,Object? zones = null,Object? canDeliver = null,Object? kycStatus = null,Object? stripeOnboardingCompleted = null,Object? detailsSubmitted = freezed,Object? chargesEnabled = freezed,Object? payoutsEnabled = freezed,Object? isOnline = null,}) {
  return _then(_self.copyWith(
vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as DriverVehicleType?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<String>,canDeliver: null == canDeliver ? _self.canDeliver : canDeliver // ignore: cast_nullable_to_non_nullable
as bool,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,stripeOnboardingCompleted: null == stripeOnboardingCompleted ? _self.stripeOnboardingCompleted : stripeOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: freezed == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool?,chargesEnabled: freezed == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool?,payoutsEnabled: freezed == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverAccount].
extension DriverAccountPatterns on DriverAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverAccount value)  $default,){
final _that = this;
switch (_that) {
case _DriverAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DriverVehicleType? vehicleType,  String? dateOfBirth,  List<String> zones,  bool canDeliver,  String kycStatus,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.vehicleType,_that.dateOfBirth,_that.zones,_that.canDeliver,_that.kycStatus,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DriverVehicleType? vehicleType,  String? dateOfBirth,  List<String> zones,  bool canDeliver,  String kycStatus,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _DriverAccount():
return $default(_that.vehicleType,_that.dateOfBirth,_that.zones,_that.canDeliver,_that.kycStatus,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled,_that.isOnline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DriverVehicleType? vehicleType,  String? dateOfBirth,  List<String> zones,  bool canDeliver,  String kycStatus,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.vehicleType,_that.dateOfBirth,_that.zones,_that.canDeliver,_that.kycStatus,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverAccount implements DriverAccount {
  const _DriverAccount({this.vehicleType, this.dateOfBirth, final  List<String> zones = const <String>[], this.canDeliver = false, this.kycStatus = 'PENDING', this.stripeOnboardingCompleted = false, this.detailsSubmitted, this.chargesEnabled, this.payoutsEnabled, this.isOnline = false}): _zones = zones;
  factory _DriverAccount.fromJson(Map<String, dynamic> json) => _$DriverAccountFromJson(json);

@override final  DriverVehicleType? vehicleType;
@override final  String? dateOfBirth;
 final  List<String> _zones;
@override@JsonKey() List<String> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

@override@JsonKey() final  bool canDeliver;
// Payout/identity gate fields (mirror DriverProfileResponseDto). Drive the
// delivery-claim gate: a driver can only claim once KYC is APPROVED and
// Stripe Connect payout onboarding is complete.
@override@JsonKey() final  String kycStatus;
@override@JsonKey() final  bool stripeOnboardingCompleted;
// Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
// send them" stays distinguishable from an explicit false — readiness
// then falls back to [stripeOnboardingCompleted]. Derivation lives in
// `payout_readiness.dart` ([DriverPayoutReadiness]).
@override final  bool? detailsSubmitted;
@override final  bool? chargesEnabled;
@override final  bool? payoutsEnabled;
// Server-side online flag (mirrors DriverProfile.isOnline). Read on
// relaunch to restore the driver's online session — the local toggle
// otherwise always boots to offline. See DeliveryDriverController.
@override@JsonKey() final  bool isOnline;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverAccountCopyWith<_DriverAccount> get copyWith => __$DriverAccountCopyWithImpl<_DriverAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverAccount&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&const DeepCollectionEquality().equals(other._zones, _zones)&&(identical(other.canDeliver, canDeliver) || other.canDeliver == canDeliver)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.stripeOnboardingCompleted, stripeOnboardingCompleted) || other.stripeOnboardingCompleted == stripeOnboardingCompleted)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,dateOfBirth,const DeepCollectionEquality().hash(_zones),canDeliver,kycStatus,stripeOnboardingCompleted,detailsSubmitted,chargesEnabled,payoutsEnabled,isOnline);

@override
String toString() {
  return 'DriverAccount(vehicleType: $vehicleType, dateOfBirth: $dateOfBirth, zones: $zones, canDeliver: $canDeliver, kycStatus: $kycStatus, stripeOnboardingCompleted: $stripeOnboardingCompleted, detailsSubmitted: $detailsSubmitted, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$DriverAccountCopyWith<$Res> implements $DriverAccountCopyWith<$Res> {
  factory _$DriverAccountCopyWith(_DriverAccount value, $Res Function(_DriverAccount) _then) = __$DriverAccountCopyWithImpl;
@override @useResult
$Res call({
 DriverVehicleType? vehicleType, String? dateOfBirth, List<String> zones, bool canDeliver, String kycStatus, bool stripeOnboardingCompleted, bool? detailsSubmitted, bool? chargesEnabled, bool? payoutsEnabled, bool isOnline
});




}
/// @nodoc
class __$DriverAccountCopyWithImpl<$Res>
    implements _$DriverAccountCopyWith<$Res> {
  __$DriverAccountCopyWithImpl(this._self, this._then);

  final _DriverAccount _self;
  final $Res Function(_DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleType = freezed,Object? dateOfBirth = freezed,Object? zones = null,Object? canDeliver = null,Object? kycStatus = null,Object? stripeOnboardingCompleted = null,Object? detailsSubmitted = freezed,Object? chargesEnabled = freezed,Object? payoutsEnabled = freezed,Object? isOnline = null,}) {
  return _then(_DriverAccount(
vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as DriverVehicleType?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<String>,canDeliver: null == canDeliver ? _self.canDeliver : canDeliver // ignore: cast_nullable_to_non_nullable
as bool,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as String,stripeOnboardingCompleted: null == stripeOnboardingCompleted ? _self.stripeOnboardingCompleted : stripeOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: freezed == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool?,chargesEnabled: freezed == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool?,payoutsEnabled: freezed == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
