// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_listing_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateListingRequest {

 String get name; String? get description; List<String> get imageUrls; int get priceCents; int? get originalPriceCents; int? get discountPercent; int? get portionsLeft; List<CuisineType> get cuisineTypes; List<DishType> get dishTypes; List<DietaryTag> get dietaryTags; List<Allergen> get allergens; String? get otherAllergens; bool? get isAvailable; bool? get isVeg; String? get menuCategory; Fulfillment get fulfillment; int get prepMinutes; DateTime? get expiresAt; List<ListingExtraRequest> get extras;
/// Create a copy of CreateListingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateListingRequestCopyWith<CreateListingRequest> get copyWith => _$CreateListingRequestCopyWithImpl<CreateListingRequest>(this as CreateListingRequest, _$identity);

  /// Serializes this CreateListingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateListingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other.cuisineTypes, cuisineTypes)&&const DeepCollectionEquality().equals(other.dishTypes, dishTypes)&&const DeepCollectionEquality().equals(other.dietaryTags, dietaryTags)&&const DeepCollectionEquality().equals(other.allergens, allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.extras, extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,description,const DeepCollectionEquality().hash(imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(cuisineTypes),const DeepCollectionEquality().hash(dishTypes),const DeepCollectionEquality().hash(dietaryTags),const DeepCollectionEquality().hash(allergens),otherAllergens,isAvailable,isVeg,menuCategory,fulfillment,prepMinutes,expiresAt,const DeepCollectionEquality().hash(extras)]);

@override
String toString() {
  return 'CreateListingRequest(name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class $CreateListingRequestCopyWith<$Res>  {
  factory $CreateListingRequestCopyWith(CreateListingRequest value, $Res Function(CreateListingRequest) _then) = _$CreateListingRequestCopyWithImpl;
@useResult
$Res call({
 String name, String? description, List<String> imageUrls, int priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType> cuisineTypes, List<DishType> dishTypes, List<DietaryTag> dietaryTags, List<Allergen> allergens, String? otherAllergens, bool? isAvailable, bool? isVeg, String? menuCategory, Fulfillment fulfillment, int prepMinutes, DateTime? expiresAt, List<ListingExtraRequest> extras
});




}
/// @nodoc
class _$CreateListingRequestCopyWithImpl<$Res>
    implements $CreateListingRequestCopyWith<$Res> {
  _$CreateListingRequestCopyWithImpl(this._self, this._then);

  final CreateListingRequest _self;
  final $Res Function(CreateListingRequest) _then;

/// Create a copy of CreateListingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? imageUrls = null,Object? priceCents = null,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = null,Object? dishTypes = null,Object? dietaryTags = null,Object? allergens = null,Object? otherAllergens = freezed,Object? isAvailable = freezed,Object? isVeg = freezed,Object? menuCategory = freezed,Object? fulfillment = null,Object? prepMinutes = null,Object? expiresAt = freezed,Object? extras = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int?,portionsLeft: freezed == portionsLeft ? _self.portionsLeft : portionsLeft // ignore: cast_nullable_to_non_nullable
as int?,cuisineTypes: null == cuisineTypes ? _self.cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self.dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,dietaryTags: null == dietaryTags ? _self.dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,otherAllergens: freezed == otherAllergens ? _self.otherAllergens : otherAllergens // ignore: cast_nullable_to_non_nullable
as String?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,isVeg: freezed == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool?,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,fulfillment: null == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment,prepMinutes: null == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,extras: null == extras ? _self.extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtraRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateListingRequest].
extension CreateListingRequestPatterns on CreateListingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateListingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateListingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateListingRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateListingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateListingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateListingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest> extras)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateListingRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest> extras)  $default,) {final _that = this;
switch (_that) {
case _CreateListingRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool? isAvailable,  bool? isVeg,  String? menuCategory,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  List<ListingExtraRequest> extras)?  $default,) {final _that = this;
switch (_that) {
case _CreateListingRequest() when $default != null:
return $default(_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.extras);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateListingRequest implements CreateListingRequest {
  const _CreateListingRequest({required this.name, this.description, required final  List<String> imageUrls, required this.priceCents, this.originalPriceCents, this.discountPercent, this.portionsLeft, final  List<CuisineType> cuisineTypes = const <CuisineType>[], final  List<DishType> dishTypes = const <DishType>[], final  List<DietaryTag> dietaryTags = const <DietaryTag>[], final  List<Allergen> allergens = const <Allergen>[], this.otherAllergens, this.isAvailable, this.isVeg, this.menuCategory, required this.fulfillment, required this.prepMinutes, this.expiresAt, final  List<ListingExtraRequest> extras = const <ListingExtraRequest>[]}): _imageUrls = imageUrls,_cuisineTypes = cuisineTypes,_dishTypes = dishTypes,_dietaryTags = dietaryTags,_allergens = allergens,_extras = extras;
  factory _CreateListingRequest.fromJson(Map<String, dynamic> json) => _$CreateListingRequestFromJson(json);

@override final  String name;
@override final  String? description;
 final  List<String> _imageUrls;
@override List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  int priceCents;
@override final  int? originalPriceCents;
@override final  int? discountPercent;
@override final  int? portionsLeft;
 final  List<CuisineType> _cuisineTypes;
@override@JsonKey() List<CuisineType> get cuisineTypes {
  if (_cuisineTypes is EqualUnmodifiableListView) return _cuisineTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisineTypes);
}

 final  List<DishType> _dishTypes;
@override@JsonKey() List<DishType> get dishTypes {
  if (_dishTypes is EqualUnmodifiableListView) return _dishTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishTypes);
}

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

@override final  String? otherAllergens;
@override final  bool? isAvailable;
@override final  bool? isVeg;
@override final  String? menuCategory;
@override final  Fulfillment fulfillment;
@override final  int prepMinutes;
@override final  DateTime? expiresAt;
 final  List<ListingExtraRequest> _extras;
@override@JsonKey() List<ListingExtraRequest> get extras {
  if (_extras is EqualUnmodifiableListView) return _extras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extras);
}


/// Create a copy of CreateListingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateListingRequestCopyWith<_CreateListingRequest> get copyWith => __$CreateListingRequestCopyWithImpl<_CreateListingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateListingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateListingRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other._cuisineTypes, _cuisineTypes)&&const DeepCollectionEquality().equals(other._dishTypes, _dishTypes)&&const DeepCollectionEquality().equals(other._dietaryTags, _dietaryTags)&&const DeepCollectionEquality().equals(other._allergens, _allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._extras, _extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,description,const DeepCollectionEquality().hash(_imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(_cuisineTypes),const DeepCollectionEquality().hash(_dishTypes),const DeepCollectionEquality().hash(_dietaryTags),const DeepCollectionEquality().hash(_allergens),otherAllergens,isAvailable,isVeg,menuCategory,fulfillment,prepMinutes,expiresAt,const DeepCollectionEquality().hash(_extras)]);

@override
String toString() {
  return 'CreateListingRequest(name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class _$CreateListingRequestCopyWith<$Res> implements $CreateListingRequestCopyWith<$Res> {
  factory _$CreateListingRequestCopyWith(_CreateListingRequest value, $Res Function(_CreateListingRequest) _then) = __$CreateListingRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, List<String> imageUrls, int priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType> cuisineTypes, List<DishType> dishTypes, List<DietaryTag> dietaryTags, List<Allergen> allergens, String? otherAllergens, bool? isAvailable, bool? isVeg, String? menuCategory, Fulfillment fulfillment, int prepMinutes, DateTime? expiresAt, List<ListingExtraRequest> extras
});




}
/// @nodoc
class __$CreateListingRequestCopyWithImpl<$Res>
    implements _$CreateListingRequestCopyWith<$Res> {
  __$CreateListingRequestCopyWithImpl(this._self, this._then);

  final _CreateListingRequest _self;
  final $Res Function(_CreateListingRequest) _then;

/// Create a copy of CreateListingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? imageUrls = null,Object? priceCents = null,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = null,Object? dishTypes = null,Object? dietaryTags = null,Object? allergens = null,Object? otherAllergens = freezed,Object? isAvailable = freezed,Object? isVeg = freezed,Object? menuCategory = freezed,Object? fulfillment = null,Object? prepMinutes = null,Object? expiresAt = freezed,Object? extras = null,}) {
  return _then(_CreateListingRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,originalPriceCents: freezed == originalPriceCents ? _self.originalPriceCents : originalPriceCents // ignore: cast_nullable_to_non_nullable
as int?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int?,portionsLeft: freezed == portionsLeft ? _self.portionsLeft : portionsLeft // ignore: cast_nullable_to_non_nullable
as int?,cuisineTypes: null == cuisineTypes ? _self._cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<CuisineType>,dishTypes: null == dishTypes ? _self._dishTypes : dishTypes // ignore: cast_nullable_to_non_nullable
as List<DishType>,dietaryTags: null == dietaryTags ? _self._dietaryTags : dietaryTags // ignore: cast_nullable_to_non_nullable
as List<DietaryTag>,allergens: null == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<Allergen>,otherAllergens: freezed == otherAllergens ? _self.otherAllergens : otherAllergens // ignore: cast_nullable_to_non_nullable
as String?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,isVeg: freezed == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool?,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,fulfillment: null == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment,prepMinutes: null == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,extras: null == extras ? _self._extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtraRequest>,
  ));
}


}

// dart format on
