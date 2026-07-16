// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerAccount {

 SellerCategory? get category; String? get displayName; String? get bio; String? get profilePhotoUrl; String? get dateOfBirth; String? get neighborhood; int? get deliveryRadiusKm; int? get deliveryFeeCents; int? get prepMinMinutes; int? get prepMaxMinutes; bool? get hygieneCommitment; bool? get faitMaisonCommitment;// Business slice (§3.15) — null for fait-maison sellers.
 SellerBusinessRecord? get business;// Cuisine slice (§3.16).
 List<CuisineType> get cuisines; List<DishType> get dishTypes;// Server-derived gate. True once profile + addresses + cuisines +
// charter are complete AND `kycStatus == APPROVED`.
 bool get canList;// Mandatory platform subscription ($4/mo). `subscriptionActive` is the
// gate the app uses to unlock seller features; status + renewal date
// drive the dashboard / paywall copy. Mirrors SellerProfileResponseDto.
 String get subscriptionStatus; bool get subscriptionActive; String? get subscriptionCurrentPeriodEnd;// Stripe Connect payout gate. Mirrors SellerProfileResponseDto and is
// refreshed by /v1/users/me after hosted onboarding returns to the app.
 bool get stripeOnboardingCompleted;// Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
// send them" stays distinguishable from an explicit false — readiness
// then falls back to [stripeOnboardingCompleted]. Derivation lives in
// `payout_readiness.dart` ([SellerPayoutReadiness]).
 bool? get detailsSubmitted; bool? get chargesEnabled; bool? get payoutsEnabled;
/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerAccountCopyWith<SellerAccount> get copyWith => _$SellerAccountCopyWithImpl<SellerAccount>(this as SellerAccount, _$identity);

  /// Serializes this SellerAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerAccount&&(identical(other.category, category) || other.category == category)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.deliveryRadiusKm, deliveryRadiusKm) || other.deliveryRadiusKm == deliveryRadiusKm)&&(identical(other.deliveryFeeCents, deliveryFeeCents) || other.deliveryFeeCents == deliveryFeeCents)&&(identical(other.prepMinMinutes, prepMinMinutes) || other.prepMinMinutes == prepMinMinutes)&&(identical(other.prepMaxMinutes, prepMaxMinutes) || other.prepMaxMinutes == prepMaxMinutes)&&(identical(other.hygieneCommitment, hygieneCommitment) || other.hygieneCommitment == hygieneCommitment)&&(identical(other.faitMaisonCommitment, faitMaisonCommitment) || other.faitMaisonCommitment == faitMaisonCommitment)&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other.cuisines, cuisines)&&const DeepCollectionEquality().equals(other.dishTypes, dishTypes)&&(identical(other.canList, canList) || other.canList == canList)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.subscriptionActive, subscriptionActive) || other.subscriptionActive == subscriptionActive)&&(identical(other.subscriptionCurrentPeriodEnd, subscriptionCurrentPeriodEnd) || other.subscriptionCurrentPeriodEnd == subscriptionCurrentPeriodEnd)&&(identical(other.stripeOnboardingCompleted, stripeOnboardingCompleted) || other.stripeOnboardingCompleted == stripeOnboardingCompleted)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,displayName,bio,profilePhotoUrl,dateOfBirth,neighborhood,deliveryRadiusKm,deliveryFeeCents,prepMinMinutes,prepMaxMinutes,hygieneCommitment,faitMaisonCommitment,business,const DeepCollectionEquality().hash(cuisines),const DeepCollectionEquality().hash(dishTypes),canList,subscriptionStatus,subscriptionActive,subscriptionCurrentPeriodEnd,stripeOnboardingCompleted,detailsSubmitted,chargesEnabled,payoutsEnabled]);

@override
String toString() {
  return 'SellerAccount(category: $category, displayName: $displayName, bio: $bio, profilePhotoUrl: $profilePhotoUrl, dateOfBirth: $dateOfBirth, neighborhood: $neighborhood, deliveryRadiusKm: $deliveryRadiusKm, deliveryFeeCents: $deliveryFeeCents, prepMinMinutes: $prepMinMinutes, prepMaxMinutes: $prepMaxMinutes, hygieneCommitment: $hygieneCommitment, faitMaisonCommitment: $faitMaisonCommitment, business: $business, cuisines: $cuisines, dishTypes: $dishTypes, canList: $canList, subscriptionStatus: $subscriptionStatus, subscriptionActive: $subscriptionActive, subscriptionCurrentPeriodEnd: $subscriptionCurrentPeriodEnd, stripeOnboardingCompleted: $stripeOnboardingCompleted, detailsSubmitted: $detailsSubmitted, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled)';
}


}

/// @nodoc
abstract mixin class $SellerAccountCopyWith<$Res>  {
  factory $SellerAccountCopyWith(SellerAccount value, $Res Function(SellerAccount) _then) = _$SellerAccountCopyWithImpl;
@useResult
$Res call({
 SellerCategory? category, String? displayName, String? bio, String? profilePhotoUrl, String? dateOfBirth, String? neighborhood, int? deliveryRadiusKm, int? deliveryFeeCents, int? prepMinMinutes, int? prepMaxMinutes, bool? hygieneCommitment, bool? faitMaisonCommitment, SellerBusinessRecord? business, List<CuisineType> cuisines, List<DishType> dishTypes, bool canList, String subscriptionStatus, bool subscriptionActive, String? subscriptionCurrentPeriodEnd, bool stripeOnboardingCompleted, bool? detailsSubmitted, bool? chargesEnabled, bool? payoutsEnabled
});


$SellerBusinessRecordCopyWith<$Res>? get business;

}
/// @nodoc
class _$SellerAccountCopyWithImpl<$Res>
    implements $SellerAccountCopyWith<$Res> {
  _$SellerAccountCopyWithImpl(this._self, this._then);

  final SellerAccount _self;
  final $Res Function(SellerAccount) _then;

/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = freezed,Object? displayName = freezed,Object? bio = freezed,Object? profilePhotoUrl = freezed,Object? dateOfBirth = freezed,Object? neighborhood = freezed,Object? deliveryRadiusKm = freezed,Object? deliveryFeeCents = freezed,Object? prepMinMinutes = freezed,Object? prepMaxMinutes = freezed,Object? hygieneCommitment = freezed,Object? faitMaisonCommitment = freezed,Object? business = freezed,Object? cuisines = null,Object? dishTypes = null,Object? canList = null,Object? subscriptionStatus = null,Object? subscriptionActive = null,Object? subscriptionCurrentPeriodEnd = freezed,Object? stripeOnboardingCompleted = null,Object? detailsSubmitted = freezed,Object? chargesEnabled = freezed,Object? payoutsEnabled = freezed,}) {
  return _then(_self.copyWith(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,deliveryRadiusKm: freezed == deliveryRadiusKm ? _self.deliveryRadiusKm : deliveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,deliveryFeeCents: freezed == deliveryFeeCents ? _self.deliveryFeeCents : deliveryFeeCents // ignore: cast_nullable_to_non_nullable
as int?,prepMinMinutes: freezed == prepMinMinutes ? _self.prepMinMinutes : prepMinMinutes // ignore: cast_nullable_to_non_nullable
as int?,prepMaxMinutes: freezed == prepMaxMinutes ? _self.prepMaxMinutes : prepMaxMinutes // ignore: cast_nullable_to_non_nullable
as int?,hygieneCommitment: freezed == hygieneCommitment ? _self.hygieneCommitment : hygieneCommitment // ignore: cast_nullable_to_non_nullable
as bool?,faitMaisonCommitment: freezed == faitMaisonCommitment ? _self.faitMaisonCommitment : faitMaisonCommitment // ignore: cast_nullable_to_non_nullable
as bool?,business: freezed == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as SellerBusinessRecord?,cuisines: null == cuisines ? _self.cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self.dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,canList: null == canList ? _self.canList : canList // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,subscriptionActive: null == subscriptionActive ? _self.subscriptionActive : subscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionCurrentPeriodEnd: freezed == subscriptionCurrentPeriodEnd ? _self.subscriptionCurrentPeriodEnd : subscriptionCurrentPeriodEnd // ignore: cast_nullable_to_non_nullable
as String?,stripeOnboardingCompleted: null == stripeOnboardingCompleted ? _self.stripeOnboardingCompleted : stripeOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: freezed == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool?,chargesEnabled: freezed == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool?,payoutsEnabled: freezed == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SellerBusinessRecordCopyWith<$Res>? get business {
    if (_self.business == null) {
    return null;
  }

  return $SellerBusinessRecordCopyWith<$Res>(_self.business!, (value) {
    return _then(_self.copyWith(business: value));
  });
}
}


/// Adds pattern-matching-related methods to [SellerAccount].
extension SellerAccountPatterns on SellerAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerAccount value)  $default,){
final _that = this;
switch (_that) {
case _SellerAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerAccount value)?  $default,){
final _that = this;
switch (_that) {
case _SellerAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SellerCategory? category,  String? displayName,  String? bio,  String? profilePhotoUrl,  String? dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment,  SellerBusinessRecord? business,  List<CuisineType> cuisines,  List<DishType> dishTypes,  bool canList,  String subscriptionStatus,  bool subscriptionActive,  String? subscriptionCurrentPeriodEnd,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerAccount() when $default != null:
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment,_that.business,_that.cuisines,_that.dishTypes,_that.canList,_that.subscriptionStatus,_that.subscriptionActive,_that.subscriptionCurrentPeriodEnd,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SellerCategory? category,  String? displayName,  String? bio,  String? profilePhotoUrl,  String? dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment,  SellerBusinessRecord? business,  List<CuisineType> cuisines,  List<DishType> dishTypes,  bool canList,  String subscriptionStatus,  bool subscriptionActive,  String? subscriptionCurrentPeriodEnd,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled)  $default,) {final _that = this;
switch (_that) {
case _SellerAccount():
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment,_that.business,_that.cuisines,_that.dishTypes,_that.canList,_that.subscriptionStatus,_that.subscriptionActive,_that.subscriptionCurrentPeriodEnd,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SellerCategory? category,  String? displayName,  String? bio,  String? profilePhotoUrl,  String? dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment,  SellerBusinessRecord? business,  List<CuisineType> cuisines,  List<DishType> dishTypes,  bool canList,  String subscriptionStatus,  bool subscriptionActive,  String? subscriptionCurrentPeriodEnd,  bool stripeOnboardingCompleted,  bool? detailsSubmitted,  bool? chargesEnabled,  bool? payoutsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _SellerAccount() when $default != null:
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment,_that.business,_that.cuisines,_that.dishTypes,_that.canList,_that.subscriptionStatus,_that.subscriptionActive,_that.subscriptionCurrentPeriodEnd,_that.stripeOnboardingCompleted,_that.detailsSubmitted,_that.chargesEnabled,_that.payoutsEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerAccount implements SellerAccount {
  const _SellerAccount({this.category, this.displayName, this.bio, this.profilePhotoUrl, this.dateOfBirth, this.neighborhood, this.deliveryRadiusKm, this.deliveryFeeCents, this.prepMinMinutes, this.prepMaxMinutes, this.hygieneCommitment, this.faitMaisonCommitment, this.business, final  List<CuisineType> cuisines = const <CuisineType>[], final  List<DishType> dishTypes = const <DishType>[], this.canList = false, this.subscriptionStatus = 'NONE', this.subscriptionActive = false, this.subscriptionCurrentPeriodEnd, this.stripeOnboardingCompleted = false, this.detailsSubmitted, this.chargesEnabled, this.payoutsEnabled}): _cuisines = cuisines,_dishTypes = dishTypes;
  factory _SellerAccount.fromJson(Map<String, dynamic> json) => _$SellerAccountFromJson(json);

@override final  SellerCategory? category;
@override final  String? displayName;
@override final  String? bio;
@override final  String? profilePhotoUrl;
@override final  String? dateOfBirth;
@override final  String? neighborhood;
@override final  int? deliveryRadiusKm;
@override final  int? deliveryFeeCents;
@override final  int? prepMinMinutes;
@override final  int? prepMaxMinutes;
@override final  bool? hygieneCommitment;
@override final  bool? faitMaisonCommitment;
// Business slice (§3.15) — null for fait-maison sellers.
@override final  SellerBusinessRecord? business;
// Cuisine slice (§3.16).
 final  List<CuisineType> _cuisines;
// Cuisine slice (§3.16).
@override@JsonKey() List<CuisineType> get cuisines {
  if (_cuisines is EqualUnmodifiableListView) return _cuisines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisines);
}

 final  List<DishType> _dishTypes;
@override@JsonKey() List<DishType> get dishTypes {
  if (_dishTypes is EqualUnmodifiableListView) return _dishTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishTypes);
}

// Server-derived gate. True once profile + addresses + cuisines +
// charter are complete AND `kycStatus == APPROVED`.
@override@JsonKey() final  bool canList;
// Mandatory platform subscription ($4/mo). `subscriptionActive` is the
// gate the app uses to unlock seller features; status + renewal date
// drive the dashboard / paywall copy. Mirrors SellerProfileResponseDto.
@override@JsonKey() final  String subscriptionStatus;
@override@JsonKey() final  bool subscriptionActive;
@override final  String? subscriptionCurrentPeriodEnd;
// Stripe Connect payout gate. Mirrors SellerProfileResponseDto and is
// refreshed by /v1/users/me after hosted onboarding returns to the app.
@override@JsonKey() final  bool stripeOnboardingCompleted;
// Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
// send them" stays distinguishable from an explicit false — readiness
// then falls back to [stripeOnboardingCompleted]. Derivation lives in
// `payout_readiness.dart` ([SellerPayoutReadiness]).
@override final  bool? detailsSubmitted;
@override final  bool? chargesEnabled;
@override final  bool? payoutsEnabled;

/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerAccountCopyWith<_SellerAccount> get copyWith => __$SellerAccountCopyWithImpl<_SellerAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerAccount&&(identical(other.category, category) || other.category == category)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.deliveryRadiusKm, deliveryRadiusKm) || other.deliveryRadiusKm == deliveryRadiusKm)&&(identical(other.deliveryFeeCents, deliveryFeeCents) || other.deliveryFeeCents == deliveryFeeCents)&&(identical(other.prepMinMinutes, prepMinMinutes) || other.prepMinMinutes == prepMinMinutes)&&(identical(other.prepMaxMinutes, prepMaxMinutes) || other.prepMaxMinutes == prepMaxMinutes)&&(identical(other.hygieneCommitment, hygieneCommitment) || other.hygieneCommitment == hygieneCommitment)&&(identical(other.faitMaisonCommitment, faitMaisonCommitment) || other.faitMaisonCommitment == faitMaisonCommitment)&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other._cuisines, _cuisines)&&const DeepCollectionEquality().equals(other._dishTypes, _dishTypes)&&(identical(other.canList, canList) || other.canList == canList)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.subscriptionActive, subscriptionActive) || other.subscriptionActive == subscriptionActive)&&(identical(other.subscriptionCurrentPeriodEnd, subscriptionCurrentPeriodEnd) || other.subscriptionCurrentPeriodEnd == subscriptionCurrentPeriodEnd)&&(identical(other.stripeOnboardingCompleted, stripeOnboardingCompleted) || other.stripeOnboardingCompleted == stripeOnboardingCompleted)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,displayName,bio,profilePhotoUrl,dateOfBirth,neighborhood,deliveryRadiusKm,deliveryFeeCents,prepMinMinutes,prepMaxMinutes,hygieneCommitment,faitMaisonCommitment,business,const DeepCollectionEquality().hash(_cuisines),const DeepCollectionEquality().hash(_dishTypes),canList,subscriptionStatus,subscriptionActive,subscriptionCurrentPeriodEnd,stripeOnboardingCompleted,detailsSubmitted,chargesEnabled,payoutsEnabled]);

@override
String toString() {
  return 'SellerAccount(category: $category, displayName: $displayName, bio: $bio, profilePhotoUrl: $profilePhotoUrl, dateOfBirth: $dateOfBirth, neighborhood: $neighborhood, deliveryRadiusKm: $deliveryRadiusKm, deliveryFeeCents: $deliveryFeeCents, prepMinMinutes: $prepMinMinutes, prepMaxMinutes: $prepMaxMinutes, hygieneCommitment: $hygieneCommitment, faitMaisonCommitment: $faitMaisonCommitment, business: $business, cuisines: $cuisines, dishTypes: $dishTypes, canList: $canList, subscriptionStatus: $subscriptionStatus, subscriptionActive: $subscriptionActive, subscriptionCurrentPeriodEnd: $subscriptionCurrentPeriodEnd, stripeOnboardingCompleted: $stripeOnboardingCompleted, detailsSubmitted: $detailsSubmitted, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled)';
}


}

/// @nodoc
abstract mixin class _$SellerAccountCopyWith<$Res> implements $SellerAccountCopyWith<$Res> {
  factory _$SellerAccountCopyWith(_SellerAccount value, $Res Function(_SellerAccount) _then) = __$SellerAccountCopyWithImpl;
@override @useResult
$Res call({
 SellerCategory? category, String? displayName, String? bio, String? profilePhotoUrl, String? dateOfBirth, String? neighborhood, int? deliveryRadiusKm, int? deliveryFeeCents, int? prepMinMinutes, int? prepMaxMinutes, bool? hygieneCommitment, bool? faitMaisonCommitment, SellerBusinessRecord? business, List<CuisineType> cuisines, List<DishType> dishTypes, bool canList, String subscriptionStatus, bool subscriptionActive, String? subscriptionCurrentPeriodEnd, bool stripeOnboardingCompleted, bool? detailsSubmitted, bool? chargesEnabled, bool? payoutsEnabled
});


@override $SellerBusinessRecordCopyWith<$Res>? get business;

}
/// @nodoc
class __$SellerAccountCopyWithImpl<$Res>
    implements _$SellerAccountCopyWith<$Res> {
  __$SellerAccountCopyWithImpl(this._self, this._then);

  final _SellerAccount _self;
  final $Res Function(_SellerAccount) _then;

/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = freezed,Object? displayName = freezed,Object? bio = freezed,Object? profilePhotoUrl = freezed,Object? dateOfBirth = freezed,Object? neighborhood = freezed,Object? deliveryRadiusKm = freezed,Object? deliveryFeeCents = freezed,Object? prepMinMinutes = freezed,Object? prepMaxMinutes = freezed,Object? hygieneCommitment = freezed,Object? faitMaisonCommitment = freezed,Object? business = freezed,Object? cuisines = null,Object? dishTypes = null,Object? canList = null,Object? subscriptionStatus = null,Object? subscriptionActive = null,Object? subscriptionCurrentPeriodEnd = freezed,Object? stripeOnboardingCompleted = null,Object? detailsSubmitted = freezed,Object? chargesEnabled = freezed,Object? payoutsEnabled = freezed,}) {
  return _then(_SellerAccount(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,deliveryRadiusKm: freezed == deliveryRadiusKm ? _self.deliveryRadiusKm : deliveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,deliveryFeeCents: freezed == deliveryFeeCents ? _self.deliveryFeeCents : deliveryFeeCents // ignore: cast_nullable_to_non_nullable
as int?,prepMinMinutes: freezed == prepMinMinutes ? _self.prepMinMinutes : prepMinMinutes // ignore: cast_nullable_to_non_nullable
as int?,prepMaxMinutes: freezed == prepMaxMinutes ? _self.prepMaxMinutes : prepMaxMinutes // ignore: cast_nullable_to_non_nullable
as int?,hygieneCommitment: freezed == hygieneCommitment ? _self.hygieneCommitment : hygieneCommitment // ignore: cast_nullable_to_non_nullable
as bool?,faitMaisonCommitment: freezed == faitMaisonCommitment ? _self.faitMaisonCommitment : faitMaisonCommitment // ignore: cast_nullable_to_non_nullable
as bool?,business: freezed == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as SellerBusinessRecord?,cuisines: null == cuisines ? _self._cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self._dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,canList: null == canList ? _self.canList : canList // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,subscriptionActive: null == subscriptionActive ? _self.subscriptionActive : subscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionCurrentPeriodEnd: freezed == subscriptionCurrentPeriodEnd ? _self.subscriptionCurrentPeriodEnd : subscriptionCurrentPeriodEnd // ignore: cast_nullable_to_non_nullable
as String?,stripeOnboardingCompleted: null == stripeOnboardingCompleted ? _self.stripeOnboardingCompleted : stripeOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: freezed == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool?,chargesEnabled: freezed == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool?,payoutsEnabled: freezed == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of SellerAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SellerBusinessRecordCopyWith<$Res>? get business {
    if (_self.business == null) {
    return null;
  }

  return $SellerBusinessRecordCopyWith<$Res>(_self.business!, (value) {
    return _then(_self.copyWith(business: value));
  });
}
}


/// @nodoc
mixin _$SellerBusinessRecord {

 String get userId; String get businessName; String get siret; String? get facadeUrl; String? get legalForm; String? get createdAt; String? get updatedAt; List<OpeningHoursRow> get openingHours;
/// Create a copy of SellerBusinessRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerBusinessRecordCopyWith<SellerBusinessRecord> get copyWith => _$SellerBusinessRecordCopyWithImpl<SellerBusinessRecord>(this as SellerBusinessRecord, _$identity);

  /// Serializes this SellerBusinessRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerBusinessRecord&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.siret, siret) || other.siret == siret)&&(identical(other.facadeUrl, facadeUrl) || other.facadeUrl == facadeUrl)&&(identical(other.legalForm, legalForm) || other.legalForm == legalForm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.openingHours, openingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,businessName,siret,facadeUrl,legalForm,createdAt,updatedAt,const DeepCollectionEquality().hash(openingHours));

@override
String toString() {
  return 'SellerBusinessRecord(userId: $userId, businessName: $businessName, siret: $siret, facadeUrl: $facadeUrl, legalForm: $legalForm, createdAt: $createdAt, updatedAt: $updatedAt, openingHours: $openingHours)';
}


}

/// @nodoc
abstract mixin class $SellerBusinessRecordCopyWith<$Res>  {
  factory $SellerBusinessRecordCopyWith(SellerBusinessRecord value, $Res Function(SellerBusinessRecord) _then) = _$SellerBusinessRecordCopyWithImpl;
@useResult
$Res call({
 String userId, String businessName, String siret, String? facadeUrl, String? legalForm, String? createdAt, String? updatedAt, List<OpeningHoursRow> openingHours
});




}
/// @nodoc
class _$SellerBusinessRecordCopyWithImpl<$Res>
    implements $SellerBusinessRecordCopyWith<$Res> {
  _$SellerBusinessRecordCopyWithImpl(this._self, this._then);

  final SellerBusinessRecord _self;
  final $Res Function(SellerBusinessRecord) _then;

/// Create a copy of SellerBusinessRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? businessName = null,Object? siret = null,Object? facadeUrl = freezed,Object? legalForm = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? openingHours = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,siret: null == siret ? _self.siret : siret // ignore: cast_nullable_to_non_nullable
as String,facadeUrl: freezed == facadeUrl ? _self.facadeUrl : facadeUrl // ignore: cast_nullable_to_non_nullable
as String?,legalForm: freezed == legalForm ? _self.legalForm : legalForm // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHoursRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerBusinessRecord].
extension SellerBusinessRecordPatterns on SellerBusinessRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerBusinessRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerBusinessRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerBusinessRecord value)  $default,){
final _that = this;
switch (_that) {
case _SellerBusinessRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerBusinessRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SellerBusinessRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String businessName,  String siret,  String? facadeUrl,  String? legalForm,  String? createdAt,  String? updatedAt,  List<OpeningHoursRow> openingHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerBusinessRecord() when $default != null:
return $default(_that.userId,_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.createdAt,_that.updatedAt,_that.openingHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String businessName,  String siret,  String? facadeUrl,  String? legalForm,  String? createdAt,  String? updatedAt,  List<OpeningHoursRow> openingHours)  $default,) {final _that = this;
switch (_that) {
case _SellerBusinessRecord():
return $default(_that.userId,_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.createdAt,_that.updatedAt,_that.openingHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String businessName,  String siret,  String? facadeUrl,  String? legalForm,  String? createdAt,  String? updatedAt,  List<OpeningHoursRow> openingHours)?  $default,) {final _that = this;
switch (_that) {
case _SellerBusinessRecord() when $default != null:
return $default(_that.userId,_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.createdAt,_that.updatedAt,_that.openingHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerBusinessRecord implements SellerBusinessRecord {
  const _SellerBusinessRecord({required this.userId, required this.businessName, required this.siret, this.facadeUrl, this.legalForm, this.createdAt, this.updatedAt, final  List<OpeningHoursRow> openingHours = const <OpeningHoursRow>[]}): _openingHours = openingHours;
  factory _SellerBusinessRecord.fromJson(Map<String, dynamic> json) => _$SellerBusinessRecordFromJson(json);

@override final  String userId;
@override final  String businessName;
@override final  String siret;
@override final  String? facadeUrl;
@override final  String? legalForm;
@override final  String? createdAt;
@override final  String? updatedAt;
 final  List<OpeningHoursRow> _openingHours;
@override@JsonKey() List<OpeningHoursRow> get openingHours {
  if (_openingHours is EqualUnmodifiableListView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openingHours);
}


/// Create a copy of SellerBusinessRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerBusinessRecordCopyWith<_SellerBusinessRecord> get copyWith => __$SellerBusinessRecordCopyWithImpl<_SellerBusinessRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerBusinessRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerBusinessRecord&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.siret, siret) || other.siret == siret)&&(identical(other.facadeUrl, facadeUrl) || other.facadeUrl == facadeUrl)&&(identical(other.legalForm, legalForm) || other.legalForm == legalForm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._openingHours, _openingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,businessName,siret,facadeUrl,legalForm,createdAt,updatedAt,const DeepCollectionEquality().hash(_openingHours));

@override
String toString() {
  return 'SellerBusinessRecord(userId: $userId, businessName: $businessName, siret: $siret, facadeUrl: $facadeUrl, legalForm: $legalForm, createdAt: $createdAt, updatedAt: $updatedAt, openingHours: $openingHours)';
}


}

/// @nodoc
abstract mixin class _$SellerBusinessRecordCopyWith<$Res> implements $SellerBusinessRecordCopyWith<$Res> {
  factory _$SellerBusinessRecordCopyWith(_SellerBusinessRecord value, $Res Function(_SellerBusinessRecord) _then) = __$SellerBusinessRecordCopyWithImpl;
@override @useResult
$Res call({
 String userId, String businessName, String siret, String? facadeUrl, String? legalForm, String? createdAt, String? updatedAt, List<OpeningHoursRow> openingHours
});




}
/// @nodoc
class __$SellerBusinessRecordCopyWithImpl<$Res>
    implements _$SellerBusinessRecordCopyWith<$Res> {
  __$SellerBusinessRecordCopyWithImpl(this._self, this._then);

  final _SellerBusinessRecord _self;
  final $Res Function(_SellerBusinessRecord) _then;

/// Create a copy of SellerBusinessRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? businessName = null,Object? siret = null,Object? facadeUrl = freezed,Object? legalForm = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? openingHours = null,}) {
  return _then(_SellerBusinessRecord(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,siret: null == siret ? _self.siret : siret // ignore: cast_nullable_to_non_nullable
as String,facadeUrl: freezed == facadeUrl ? _self.facadeUrl : facadeUrl // ignore: cast_nullable_to_non_nullable
as String?,legalForm: freezed == legalForm ? _self.legalForm : legalForm // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHoursRow>,
  ));
}


}

// dart format on
