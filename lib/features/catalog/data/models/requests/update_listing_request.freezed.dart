// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_listing_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateListingRequest {

 String? get name; String? get description; List<String>? get imageUrls; int? get priceCents; int? get originalPriceCents; int? get discountPercent; int? get portionsLeft; List<CuisineType>? get cuisineTypes; List<DishType>? get dishTypes; List<DietaryTag>? get dietaryTags; List<Allergen>? get allergens; String? get otherAllergens; bool? get isAvailable; bool? get isVeg; String? get menuCategory; Fulfillment? get fulfillment; int? get prepMinutes; DateTime? get expiresAt; List<ListingExtraRequest>? get extras;
/// Create a copy of UpdateListingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateListingRequestCopyWith<UpdateListingRequest> get copyWith => _$UpdateListingRequestCopyWithImpl<UpdateListingRequest>(this as UpdateListingRequest, _$identity);

  /// Serializes this UpdateListingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateListingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other.cuisineTypes, cuisineTypes)&&const DeepCollectionEquality().equals(other.dishTypes, dishTypes)&&const DeepCollectionEquality().equals(other.dietaryTags, dietaryTags)&&const DeepCollectionEquality().equals(other.allergens, allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.extras, extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,description,const DeepCollectionEquality().hash(imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(cuisineTypes),const DeepCollectionEquality().hash(dishTypes),const DeepCollectionEquality().hash(dietaryTags),const DeepCollectionEquality().hash(allergens),otherAllergens,isAvailable,isVeg,menuCategory,fulfillment,prepMinutes,expiresAt,const DeepCollectionEquality().hash(extras)]);

@override
String toString() {
  return 'UpdateListingRequest(name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class $UpdateListingRequestCopyWith<$Res>  {
  factory $UpdateListingRequestCopyWith(UpdateListingRequest value, $Res Function(UpdateListingRequest) _then) = _$UpdateListingRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? description, List<String>? imageUrls, int? priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType>? cuisineTypes, List<DishType>? dishTypes, List<DietaryTag>? dietaryTags, List<Allergen>? allergens, String? otherAllergens, bool? isAvailable, bool? isVeg, String? menuCategory, Fulfillment? fulfillment, int? prepMinutes, DateTime? expiresAt, List<ListingExtraRequest>? extras
});




}
/// @nodoc
class _$UpdateListingRequestCopyWithImpl<$Res>
    implements $UpdateListingRequestCopyWith<$Res> {
  _$UpdateListingRequestCopyWithImpl(this._self, this._then);

  final UpdateListingRequest _self;
  final $Res Function(UpdateListingRequest) _then;

/// Create a copy of UpdateListingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,Object? imageUrls = freezed,Object? priceCents = freezed,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = freezed,Object? dishTypes = freezed,Object? dietaryTags = freezed,Object? allergens = freezed,Object? otherAllergens = freezed,Object? isAvailable = freezed,Object? isVeg = freezed,Object? menuCategory = freezed,Object? fulfillment = freezed,Object? prepMinutes = freezed,Object? expiresAt = freezed,Object? extras = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: freezed == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int?,portionsLeft: freezed == portionsLeft ? _self.portionsLeft : portionsLeft // ignore: cast_nullable_to_non_nullable
as int?,cuisineTypes: freezed == cuisineTypes ? _self.cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<CuisineType>?,dishTypes: freezed == dishTypes ? _self.dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>?,dietaryTags: freezed == dietaryTags ? _self.dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>?,allergens: freezed == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>?,otherAllergens: freezed == otherAllergens ? _self.otherAllergens : otherAllergens // ignore: cast_nullable_to_non_nullable
as String?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,isVeg: freezed == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool?,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,fulfillment: freezed == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment?,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,extras: freezed == extras ? _self.extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtraRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateListingRequest].
extension UpdateListingRequestPatterns on UpdateListingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateListingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateListingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateListingRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateListingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateListingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateListingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description,  List<String>? imageUrls,  int? priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType>? cuisineTypes,  List<DishType>? dishTypes,  List<DietaryTag>? dietaryTags,  List<Allergen>? allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment? fulfillment,  int? prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest>? extras)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateListingRequest() when $default != null:
return $default(_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.extras);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description,  List<String>? imageUrls,  int? priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType>? cuisineTypes,  List<DishType>? dishTypes,  List<DietaryTag>? dietaryTags,  List<Allergen>? allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment? fulfillment,  int? prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest>? extras)  $default,) {final _that = this;
switch (_that) {
case _UpdateListingRequest():
return $default(_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.extras);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description,  List<String>? imageUrls,  int? priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType>? cuisineTypes,  List<DishType>? dishTypes,  List<DietaryTag>? dietaryTags,  List<Allergen>? allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment? fulfillment,  int? prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest>? extras)?  $default,) {final _that = this;
switch (_that) {
case _UpdateListingRequest() when $default != null:
return $default(_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.extras);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateListingRequest implements UpdateListingRequest {
  const _UpdateListingRequest({this.name, this.description, final  List<String>? imageUrls, this.priceCents, this.originalPriceCents, this.discountPercent, this.portionsLeft, final  List<CuisineType>? cuisineTypes, final  List<DishType>? dishTypes, final  List<DietaryTag>? dietaryTags, final  List<Allergen>? allergens, this.otherAllergens, this.isAvailable, this.isVeg, this.menuCategory, this.fulfillment, this.prepMinutes, this.expiresAt, final  List<ListingExtraRequest>? extras}): _imageUrls = imageUrls,_cuisineTypes = cuisineTypes,_dishTypes = dishTypes,_dietaryTags = dietaryTags,_allergens = allergens,_extras = extras;
  factory _UpdateListingRequest.fromJson(Map<String, dynamic> json) => _$UpdateListingRequestFromJson(json);

@override final  String? name;
@override final  String? description;
 final  List<String>? _imageUrls;
@override List<String>? get imageUrls {
  final value = _imageUrls;
  if (value == null) return null;
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? priceCents;
@override final  int? originalPriceCents;
@override final  int? discountPercent;
@override final  int? portionsLeft;
 final  List<CuisineType>? _cuisineTypes;
@override List<CuisineType>? get cuisineTypes {
  final value = _cuisineTypes;
  if (value == null) return null;
  if (_cuisineTypes is EqualUnmodifiableListView) return _cuisineTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<DishType>? _dishTypes;
@override List<DishType>? get dishTypes {
  final value = _dishTypes;
  if (value == null) return null;
  if (_dishTypes is EqualUnmodifiableListView) return _dishTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<DietaryTag>? _dietaryTags;
@override List<DietaryTag>? get dietaryTags {
  final value = _dietaryTags;
  if (value == null) return null;
  if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Allergen>? _allergens;
@override List<Allergen>? get allergens {
  final value = _allergens;
  if (value == null) return null;
  if (_allergens is EqualUnmodifiableListView) return _allergens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? otherAllergens;
@override final  bool? isAvailable;
@override final  bool? isVeg;
@override final  String? menuCategory;
@override final  Fulfillment? fulfillment;
@override final  int? prepMinutes;
@override final  DateTime? expiresAt;
 final  List<ListingExtraRequest>? _extras;
@override List<ListingExtraRequest>? get extras {
  final value = _extras;
  if (value == null) return null;
  if (_extras is EqualUnmodifiableListView) return _extras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateListingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateListingRequestCopyWith<_UpdateListingRequest> get copyWith => __$UpdateListingRequestCopyWithImpl<_UpdateListingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateListingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateListingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other._cuisineTypes, _cuisineTypes)&&const DeepCollectionEquality().equals(other._dishTypes, _dishTypes)&&const DeepCollectionEquality().equals(other._dietaryTags, _dietaryTags)&&const DeepCollectionEquality().equals(other._allergens, _allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._extras, _extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,description,const DeepCollectionEquality().hash(_imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(_cuisineTypes),const DeepCollectionEquality().hash(_dishTypes),const DeepCollectionEquality().hash(_dietaryTags),const DeepCollectionEquality().hash(_allergens),otherAllergens,isAvailable,isVeg,menuCategory,fulfillment,prepMinutes,expiresAt,const DeepCollectionEquality().hash(_extras)]);

@override
String toString() {
  return 'UpdateListingRequest(name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class _$UpdateListingRequestCopyWith<$Res> implements $UpdateListingRequestCopyWith<$Res> {
  factory _$UpdateListingRequestCopyWith(_UpdateListingRequest value, $Res Function(_UpdateListingRequest) _then) = __$UpdateListingRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description, List<String>? imageUrls, int? priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType>? cuisineTypes, List<DishType>? dishTypes, List<DietaryTag>? dietaryTags, List<Allergen>? allergens, String? otherAllergens, bool? isAvailable, bool? isVeg, String? menuCategory, Fulfillment? fulfillment, int? prepMinutes, DateTime? expiresAt, List<ListingExtraRequest>? extras
});




}
/// @nodoc
class __$UpdateListingRequestCopyWithImpl<$Res>
    implements _$UpdateListingRequestCopyWith<$Res> {
  __$UpdateListingRequestCopyWithImpl(this._self, this._then);

  final _UpdateListingRequest _self;
  final $Res Function(_UpdateListingRequest) _then;

/// Create a copy of UpdateListingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,Object? imageUrls = freezed,Object? priceCents = freezed,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = freezed,Object? dishTypes = freezed,Object? dietaryTags = freezed,Object? allergens = freezed,Object? otherAllergens = freezed,Object? isAvailable = freezed,Object? isVeg = freezed,Object? menuCategory = freezed,Object? fulfillment = freezed,Object? prepMinutes = freezed,Object? expiresAt = freezed,Object? extras = freezed,}) {
  return _then(_UpdateListingRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: freezed == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int?,portionsLeft: freezed == portionsLeft ? _self.portionsLeft : portionsLeft // ignore: cast_nullable_to_non_nullable
as int?,cuisineTypes: freezed == cuisineTypes ? _self._cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<CuisineType>?,dishTypes: freezed == dishTypes ? _self._dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>?,dietaryTags: freezed == dietaryTags ? _self._dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>?,allergens: freezed == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>?,otherAllergens: freezed == otherAllergens ? _self.otherAllergens : otherAllergens // ignore: cast_nullable_to_non_nullable
as String?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,isVeg: freezed == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool?,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,fulfillment: freezed == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment?,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,extras: freezed == extras ? _self._extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtraRequest>?,
  ));
}


}

// dart format on
