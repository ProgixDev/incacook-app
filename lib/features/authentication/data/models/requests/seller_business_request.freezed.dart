// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_business_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SellerBusinessRequest {

 String get businessName; String? get siret; String? get facadeUrl; String? get legalForm; List<OpeningHoursRow> get openingHours;
/// Create a copy of SellerBusinessRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerBusinessRequestCopyWith<SellerBusinessRequest> get copyWith => _$SellerBusinessRequestCopyWithImpl<SellerBusinessRequest>(this as SellerBusinessRequest, _$identity);

  /// Serializes this SellerBusinessRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerBusinessRequest&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.siret, siret) || other.siret == siret)&&(identical(other.facadeUrl, facadeUrl) || other.facadeUrl == facadeUrl)&&(identical(other.legalForm, legalForm) || other.legalForm == legalForm)&&const DeepCollectionEquality().equals(other.openingHours, openingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,siret,facadeUrl,legalForm,const DeepCollectionEquality().hash(openingHours));

@override
String toString() {
  return 'SellerBusinessRequest(businessName: $businessName, siret: $siret, facadeUrl: $facadeUrl, legalForm: $legalForm, openingHours: $openingHours)';
}


}

/// @nodoc
abstract mixin class $SellerBusinessRequestCopyWith<$Res>  {
  factory $SellerBusinessRequestCopyWith(SellerBusinessRequest value, $Res Function(SellerBusinessRequest) _then) = _$SellerBusinessRequestCopyWithImpl;
@useResult
$Res call({
 String businessName, String? siret, String? facadeUrl, String? legalForm, List<OpeningHoursRow> openingHours
});




}
/// @nodoc
class _$SellerBusinessRequestCopyWithImpl<$Res>
    implements $SellerBusinessRequestCopyWith<$Res> {
  _$SellerBusinessRequestCopyWithImpl(this._self, this._then);

  final SellerBusinessRequest _self;
  final $Res Function(SellerBusinessRequest) _then;

/// Create a copy of SellerBusinessRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? siret = freezed,Object? facadeUrl = freezed,Object? legalForm = freezed,Object? openingHours = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,siret: freezed == siret ? _self.siret : siret // ignore: cast_nullable_to_non_nullable
as String?,facadeUrl: freezed == facadeUrl ? _self.facadeUrl : facadeUrl // ignore: cast_nullable_to_non_nullable
as String?,legalForm: freezed == legalForm ? _self.legalForm : legalForm // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHoursRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerBusinessRequest].
extension SellerBusinessRequestPatterns on SellerBusinessRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerBusinessRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerBusinessRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerBusinessRequest value)  $default,){
final _that = this;
switch (_that) {
case _SellerBusinessRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerBusinessRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SellerBusinessRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  String? siret,  String? facadeUrl,  String? legalForm,  List<OpeningHoursRow> openingHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerBusinessRequest() when $default != null:
return $default(_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.openingHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  String? siret,  String? facadeUrl,  String? legalForm,  List<OpeningHoursRow> openingHours)  $default,) {final _that = this;
switch (_that) {
case _SellerBusinessRequest():
return $default(_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.openingHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  String? siret,  String? facadeUrl,  String? legalForm,  List<OpeningHoursRow> openingHours)?  $default,) {final _that = this;
switch (_that) {
case _SellerBusinessRequest() when $default != null:
return $default(_that.businessName,_that.siret,_that.facadeUrl,_that.legalForm,_that.openingHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SellerBusinessRequest implements SellerBusinessRequest {
  const _SellerBusinessRequest({required this.businessName, this.siret, this.facadeUrl, this.legalForm, final  List<OpeningHoursRow> openingHours = const <OpeningHoursRow>[]}): _openingHours = openingHours;
  factory _SellerBusinessRequest.fromJson(Map<String, dynamic> json) => _$SellerBusinessRequestFromJson(json);

@override final  String businessName;
@override final  String? siret;
@override final  String? facadeUrl;
@override final  String? legalForm;
 final  List<OpeningHoursRow> _openingHours;
@override@JsonKey() List<OpeningHoursRow> get openingHours {
  if (_openingHours is EqualUnmodifiableListView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openingHours);
}


/// Create a copy of SellerBusinessRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerBusinessRequestCopyWith<_SellerBusinessRequest> get copyWith => __$SellerBusinessRequestCopyWithImpl<_SellerBusinessRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SellerBusinessRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerBusinessRequest&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.siret, siret) || other.siret == siret)&&(identical(other.facadeUrl, facadeUrl) || other.facadeUrl == facadeUrl)&&(identical(other.legalForm, legalForm) || other.legalForm == legalForm)&&const DeepCollectionEquality().equals(other._openingHours, _openingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,siret,facadeUrl,legalForm,const DeepCollectionEquality().hash(_openingHours));

@override
String toString() {
  return 'SellerBusinessRequest(businessName: $businessName, siret: $siret, facadeUrl: $facadeUrl, legalForm: $legalForm, openingHours: $openingHours)';
}


}

/// @nodoc
abstract mixin class _$SellerBusinessRequestCopyWith<$Res> implements $SellerBusinessRequestCopyWith<$Res> {
  factory _$SellerBusinessRequestCopyWith(_SellerBusinessRequest value, $Res Function(_SellerBusinessRequest) _then) = __$SellerBusinessRequestCopyWithImpl;
@override @useResult
$Res call({
 String businessName, String? siret, String? facadeUrl, String? legalForm, List<OpeningHoursRow> openingHours
});




}
/// @nodoc
class __$SellerBusinessRequestCopyWithImpl<$Res>
    implements _$SellerBusinessRequestCopyWith<$Res> {
  __$SellerBusinessRequestCopyWithImpl(this._self, this._then);

  final _SellerBusinessRequest _self;
  final $Res Function(_SellerBusinessRequest) _then;

/// Create a copy of SellerBusinessRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? siret = freezed,Object? facadeUrl = freezed,Object? legalForm = freezed,Object? openingHours = null,}) {
  return _then(_SellerBusinessRequest(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,siret: freezed == siret ? _self.siret : siret // ignore: cast_nullable_to_non_nullable
as String?,facadeUrl: freezed == facadeUrl ? _self.facadeUrl : facadeUrl // ignore: cast_nullable_to_non_nullable
as String?,legalForm: freezed == legalForm ? _self.legalForm : legalForm // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as List<OpeningHoursRow>,
  ));
}


}

// dart format on
