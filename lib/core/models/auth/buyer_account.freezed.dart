// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buyer_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuyerAccount {

 AddressRecord? get defaultAddress; List<DietaryTag> get dietaryTags; List<Allergen> get allergens;
/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuyerAccountCopyWith<BuyerAccount> get copyWith => _$BuyerAccountCopyWithImpl<BuyerAccount>(this as BuyerAccount, _$identity);

  /// Serializes this BuyerAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuyerAccount&&(identical(other.defaultAddress, defaultAddress) || other.defaultAddress == defaultAddress)&&const DeepCollectionEquality().equals(other.dietaryTags, dietaryTags)&&const DeepCollectionEquality().equals(other.allergens, allergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultAddress,const DeepCollectionEquality().hash(dietaryTags),const DeepCollectionEquality().hash(allergens));

@override
String toString() {
  return 'BuyerAccount(defaultAddress: $defaultAddress, dietaryTags: $dietaryTags, allergens: $allergens)';
}


}

/// @nodoc
abstract mixin class $BuyerAccountCopyWith<$Res>  {
  factory $BuyerAccountCopyWith(BuyerAccount value, $Res Function(BuyerAccount) _then) = _$BuyerAccountCopyWithImpl;
@useResult
$Res call({
 AddressRecord? defaultAddress, List<DietaryTag> dietaryTags, List<Allergen> allergens
});


$AddressRecordCopyWith<$Res>? get defaultAddress;

}
/// @nodoc
class _$BuyerAccountCopyWithImpl<$Res>
    implements $BuyerAccountCopyWith<$Res> {
  _$BuyerAccountCopyWithImpl(this._self, this._then);

  final BuyerAccount _self;
  final $Res Function(BuyerAccount) _then;

/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultAddress = freezed,Object? dietaryTags = null,Object? allergens = null,}) {
  return _then(_self.copyWith(
defaultAddress: freezed == defaultAddress ? _self.defaultAddress : defaultAddress // ignore: cast_nullable_to_non_nullable
as AddressRecord?,dietaryTags: null == dietaryTags ? _self.dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,
  ));
}
/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressRecordCopyWith<$Res>? get defaultAddress {
    if (_self.defaultAddress == null) {
    return null;
  }

  return $AddressRecordCopyWith<$Res>(_self.defaultAddress!, (value) {
    return _then(_self.copyWith(defaultAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [BuyerAccount].
extension BuyerAccountPatterns on BuyerAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuyerAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuyerAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuyerAccount value)  $default,){
final _that = this;
switch (_that) {
case _BuyerAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuyerAccount value)?  $default,){
final _that = this;
switch (_that) {
case _BuyerAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AddressRecord? defaultAddress,  List<DietaryTag> dietaryTags,  List<Allergen> allergens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuyerAccount() when $default != null:
return $default(_that.defaultAddress,_that.dietaryTags,_that.allergens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AddressRecord? defaultAddress,  List<DietaryTag> dietaryTags,  List<Allergen> allergens)  $default,) {final _that = this;
switch (_that) {
case _BuyerAccount():
return $default(_that.defaultAddress,_that.dietaryTags,_that.allergens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AddressRecord? defaultAddress,  List<DietaryTag> dietaryTags,  List<Allergen> allergens)?  $default,) {final _that = this;
switch (_that) {
case _BuyerAccount() when $default != null:
return $default(_that.defaultAddress,_that.dietaryTags,_that.allergens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuyerAccount implements BuyerAccount {
  const _BuyerAccount({this.defaultAddress, final  List<DietaryTag> dietaryTags = const <DietaryTag>[], final  List<Allergen> allergens = const <Allergen>[]}): _dietaryTags = dietaryTags,_allergens = allergens;
  factory _BuyerAccount.fromJson(Map<String, dynamic> json) => _$BuyerAccountFromJson(json);

@override final  AddressRecord? defaultAddress;
 final  List<DietaryTag> _dietaryTags;
@override@JsonKey() List<DietaryTag> get dietaryTags {
  if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryTags);
}

 final  List<Allergen> _allergens;
@override@JsonKey() List<Allergen> get allergens {
  if (_allergens is EqualUnmodifiableListView) return _allergens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergens);
}


/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuyerAccountCopyWith<_BuyerAccount> get copyWith => __$BuyerAccountCopyWithImpl<_BuyerAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuyerAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuyerAccount&&(identical(other.defaultAddress, defaultAddress) || other.defaultAddress == defaultAddress)&&const DeepCollectionEquality().equals(other._dietaryTags, _dietaryTags)&&const DeepCollectionEquality().equals(other._allergens, _allergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultAddress,const DeepCollectionEquality().hash(_dietaryTags),const DeepCollectionEquality().hash(_allergens));

@override
String toString() {
  return 'BuyerAccount(defaultAddress: $defaultAddress, dietaryTags: $dietaryTags, allergens: $allergens)';
}


}

/// @nodoc
abstract mixin class _$BuyerAccountCopyWith<$Res> implements $BuyerAccountCopyWith<$Res> {
  factory _$BuyerAccountCopyWith(_BuyerAccount value, $Res Function(_BuyerAccount) _then) = __$BuyerAccountCopyWithImpl;
@override @useResult
$Res call({
 AddressRecord? defaultAddress, List<DietaryTag> dietaryTags, List<Allergen> allergens
});


@override $AddressRecordCopyWith<$Res>? get defaultAddress;

}
/// @nodoc
class __$BuyerAccountCopyWithImpl<$Res>
    implements _$BuyerAccountCopyWith<$Res> {
  __$BuyerAccountCopyWithImpl(this._self, this._then);

  final _BuyerAccount _self;
  final $Res Function(_BuyerAccount) _then;

/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultAddress = freezed,Object? dietaryTags = null,Object? allergens = null,}) {
  return _then(_BuyerAccount(
defaultAddress: freezed == defaultAddress ? _self.defaultAddress : defaultAddress // ignore: cast_nullable_to_non_nullable
as AddressRecord?,dietaryTags: null == dietaryTags ? _self._dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,
  ));
}

/// Create a copy of BuyerAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressRecordCopyWith<$Res>? get defaultAddress {
    if (_self.defaultAddress == null) {
    return null;
  }

  return $AddressRecordCopyWith<$Res>(_self.defaultAddress!, (value) {
    return _then(_self.copyWith(defaultAddress: value));
  });
}
}

// dart format on
