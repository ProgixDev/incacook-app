// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_profile_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerProfileRequest {

 SellerCategory get category; String get displayName; String? get bio; String get profilePhotoUrl; String get dateOfBirth;// YYYY-MM-DD
 String? get neighborhood; int? get deliveryRadiusKm; int? get deliveryFeeCents; int? get prepMinMinutes; int? get prepMaxMinutes; bool? get hygieneCommitment; bool? get faitMaisonCommitment;
/// Create a copy of SellerProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerProfileRequestCopyWith<SellerProfileRequest> get copyWith => _$SellerProfileRequestCopyWithImpl<SellerProfileRequest>(this as SellerProfileRequest, _$identity);

  /// Serializes this SellerProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerProfileRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.deliveryRadiusKm, deliveryRadiusKm) || other.deliveryRadiusKm == deliveryRadiusKm)&&(identical(other.deliveryFeeCents, deliveryFeeCents) || other.deliveryFeeCents == deliveryFeeCents)&&(identical(other.prepMinMinutes, prepMinMinutes) || other.prepMinMinutes == prepMinMinutes)&&(identical(other.prepMaxMinutes, prepMaxMinutes) || other.prepMaxMinutes == prepMaxMinutes)&&(identical(other.hygieneCommitment, hygieneCommitment) || other.hygieneCommitment == hygieneCommitment)&&(identical(other.faitMaisonCommitment, faitMaisonCommitment) || other.faitMaisonCommitment == faitMaisonCommitment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,displayName,bio,profilePhotoUrl,dateOfBirth,neighborhood,deliveryRadiusKm,deliveryFeeCents,prepMinMinutes,prepMaxMinutes,hygieneCommitment,faitMaisonCommitment);

@override
String toString() {
  return 'SellerProfileRequest(category: $category, displayName: $displayName, bio: $bio, profilePhotoUrl: $profilePhotoUrl, dateOfBirth: $dateOfBirth, neighborhood: $neighborhood, deliveryRadiusKm: $deliveryRadiusKm, deliveryFeeCents: $deliveryFeeCents, prepMinMinutes: $prepMinMinutes, prepMaxMinutes: $prepMaxMinutes, hygieneCommitment: $hygieneCommitment, faitMaisonCommitment: $faitMaisonCommitment)';
}


}

/// @nodoc
abstract mixin class $SellerProfileRequestCopyWith<$Res>  {
  factory $SellerProfileRequestCopyWith(SellerProfileRequest value, $Res Function(SellerProfileRequest) _then) = _$SellerProfileRequestCopyWithImpl;
@useResult
$Res call({
 SellerCategory category, String displayName, String? bio, String profilePhotoUrl, String dateOfBirth, String? neighborhood, int? deliveryRadiusKm, int? deliveryFeeCents, int? prepMinMinutes, int? prepMaxMinutes, bool? hygieneCommitment, bool? faitMaisonCommitment
});




}
/// @nodoc
class _$SellerProfileRequestCopyWithImpl<$Res>
    implements $SellerProfileRequestCopyWith<$Res> {
  _$SellerProfileRequestCopyWithImpl(this._self, this._then);

  final SellerProfileRequest _self;
  final $Res Function(SellerProfileRequest) _then;

/// Create a copy of SellerProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? displayName = null,Object? bio = freezed,Object? profilePhotoUrl = null,Object? dateOfBirth = null,Object? neighborhood = freezed,Object? deliveryRadiusKm = freezed,Object? deliveryFeeCents = freezed,Object? prepMinMinutes = freezed,Object? prepMaxMinutes = freezed,Object? hygieneCommitment = freezed,Object? faitMaisonCommitment = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: null == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,deliveryRadiusKm: freezed == deliveryRadiusKm ? _self.deliveryRadiusKm : deliveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,deliveryFeeCents: freezed == deliveryFeeCents ? _self.deliveryFeeCents : deliveryFeeCents // ignore: cast_nullable_to_non_nullable
as int?,prepMinMinutes: freezed == prepMinMinutes ? _self.prepMinMinutes : prepMinMinutes // ignore: cast_nullable_to_non_nullable
as int?,prepMaxMinutes: freezed == prepMaxMinutes ? _self.prepMaxMinutes : prepMaxMinutes // ignore: cast_nullable_to_non_nullable
as int?,hygieneCommitment: freezed == hygieneCommitment ? _self.hygieneCommitment : hygieneCommitment // ignore: cast_nullable_to_non_nullable
as bool?,faitMaisonCommitment: freezed == faitMaisonCommitment ? _self.faitMaisonCommitment : faitMaisonCommitment // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerProfileRequest].
extension SellerProfileRequestPatterns on SellerProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _SellerProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SellerProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SellerCategory category,  String displayName,  String? bio,  String profilePhotoUrl,  String dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerProfileRequest() when $default != null:
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SellerCategory category,  String displayName,  String? bio,  String profilePhotoUrl,  String dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment)  $default,) {final _that = this;
switch (_that) {
case _SellerProfileRequest():
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SellerCategory category,  String displayName,  String? bio,  String profilePhotoUrl,  String dateOfBirth,  String? neighborhood,  int? deliveryRadiusKm,  int? deliveryFeeCents,  int? prepMinMinutes,  int? prepMaxMinutes,  bool? hygieneCommitment,  bool? faitMaisonCommitment)?  $default,) {final _that = this;
switch (_that) {
case _SellerProfileRequest() when $default != null:
return $default(_that.category,_that.displayName,_that.bio,_that.profilePhotoUrl,_that.dateOfBirth,_that.neighborhood,_that.deliveryRadiusKm,_that.deliveryFeeCents,_that.prepMinMinutes,_that.prepMaxMinutes,_that.hygieneCommitment,_that.faitMaisonCommitment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerProfileRequest implements SellerProfileRequest {
  const _SellerProfileRequest({required this.category, required this.displayName, this.bio, required this.profilePhotoUrl, required this.dateOfBirth, this.neighborhood, this.deliveryRadiusKm, this.deliveryFeeCents, this.prepMinMinutes, this.prepMaxMinutes, this.hygieneCommitment, this.faitMaisonCommitment});
  factory _SellerProfileRequest.fromJson(Map<String, dynamic> json) => _$SellerProfileRequestFromJson(json);

@override final  SellerCategory category;
@override final  String displayName;
@override final  String? bio;
@override final  String profilePhotoUrl;
@override final  String dateOfBirth;
// YYYY-MM-DD
@override final  String? neighborhood;
@override final  int? deliveryRadiusKm;
@override final  int? deliveryFeeCents;
@override final  int? prepMinMinutes;
@override final  int? prepMaxMinutes;
@override final  bool? hygieneCommitment;
@override final  bool? faitMaisonCommitment;

/// Create a copy of SellerProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerProfileRequestCopyWith<_SellerProfileRequest> get copyWith => __$SellerProfileRequestCopyWithImpl<_SellerProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerProfileRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.deliveryRadiusKm, deliveryRadiusKm) || other.deliveryRadiusKm == deliveryRadiusKm)&&(identical(other.deliveryFeeCents, deliveryFeeCents) || other.deliveryFeeCents == deliveryFeeCents)&&(identical(other.prepMinMinutes, prepMinMinutes) || other.prepMinMinutes == prepMinMinutes)&&(identical(other.prepMaxMinutes, prepMaxMinutes) || other.prepMaxMinutes == prepMaxMinutes)&&(identical(other.hygieneCommitment, hygieneCommitment) || other.hygieneCommitment == hygieneCommitment)&&(identical(other.faitMaisonCommitment, faitMaisonCommitment) || other.faitMaisonCommitment == faitMaisonCommitment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,displayName,bio,profilePhotoUrl,dateOfBirth,neighborhood,deliveryRadiusKm,deliveryFeeCents,prepMinMinutes,prepMaxMinutes,hygieneCommitment,faitMaisonCommitment);

@override
String toString() {
  return 'SellerProfileRequest(category: $category, displayName: $displayName, bio: $bio, profilePhotoUrl: $profilePhotoUrl, dateOfBirth: $dateOfBirth, neighborhood: $neighborhood, deliveryRadiusKm: $deliveryRadiusKm, deliveryFeeCents: $deliveryFeeCents, prepMinMinutes: $prepMinMinutes, prepMaxMinutes: $prepMaxMinutes, hygieneCommitment: $hygieneCommitment, faitMaisonCommitment: $faitMaisonCommitment)';
}


}

/// @nodoc
abstract mixin class _$SellerProfileRequestCopyWith<$Res> implements $SellerProfileRequestCopyWith<$Res> {
  factory _$SellerProfileRequestCopyWith(_SellerProfileRequest value, $Res Function(_SellerProfileRequest) _then) = __$SellerProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 SellerCategory category, String displayName, String? bio, String profilePhotoUrl, String dateOfBirth, String? neighborhood, int? deliveryRadiusKm, int? deliveryFeeCents, int? prepMinMinutes, int? prepMaxMinutes, bool? hygieneCommitment, bool? faitMaisonCommitment
});




}
/// @nodoc
class __$SellerProfileRequestCopyWithImpl<$Res>
    implements _$SellerProfileRequestCopyWith<$Res> {
  __$SellerProfileRequestCopyWithImpl(this._self, this._then);

  final _SellerProfileRequest _self;
  final $Res Function(_SellerProfileRequest) _then;

/// Create a copy of SellerProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? displayName = null,Object? bio = freezed,Object? profilePhotoUrl = null,Object? dateOfBirth = null,Object? neighborhood = freezed,Object? deliveryRadiusKm = freezed,Object? deliveryFeeCents = freezed,Object? prepMinMinutes = freezed,Object? prepMaxMinutes = freezed,Object? hygieneCommitment = freezed,Object? faitMaisonCommitment = freezed,}) {
  return _then(_SellerProfileRequest(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: null == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,deliveryRadiusKm: freezed == deliveryRadiusKm ? _self.deliveryRadiusKm : deliveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int?,deliveryFeeCents: freezed == deliveryFeeCents ? _self.deliveryFeeCents : deliveryFeeCents // ignore: cast_nullable_to_non_nullable
as int?,prepMinMinutes: freezed == prepMinMinutes ? _self.prepMinMinutes : prepMinMinutes // ignore: cast_nullable_to_non_nullable
as int?,prepMaxMinutes: freezed == prepMaxMinutes ? _self.prepMaxMinutes : prepMaxMinutes // ignore: cast_nullable_to_non_nullable
as int?,hygieneCommitment: freezed == hygieneCommitment ? _self.hygieneCommitment : hygieneCommitment // ignore: cast_nullable_to_non_nullable
as bool?,faitMaisonCommitment: freezed == faitMaisonCommitment ? _self.faitMaisonCommitment : faitMaisonCommitment // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
