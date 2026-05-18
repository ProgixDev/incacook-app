// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id; String get sellerId; String get name; String? get description; List<String> get imageUrls; int get priceCents; int? get originalPriceCents; int? get discountPercent;/// null = "cook to order" (restaurant/traiteur). Required + `> 0`
/// for fait_maison.
 int? get portionsLeft; List<CuisineType> get cuisineTypes; List<DishType> get dishTypes; List<DietaryTag> get dietaryTags; List<Allergen> get allergens; String? get otherAllergens; bool get isAvailable; bool get isVeg; String? get menuCategory; SellerCategory get category; Fulfillment get fulfillment; int get prepMinutes;/// null = permanent menu item (restaurant/traiteur). Required for
/// fait_maison.
 DateTime? get expiresAt; DateTime get createdAt; DateTime get updatedAt;/// Per-listing add-ons. Always empty on buyer-feed items — fetch
/// detail via `GET /v1/listings/:id` to load the real extras.
 List<ListingExtra> get extras;//* Buyer-feed-only fields — present on items from `GET /v1/listings`,
//* absent on the detail and seller-dashboard responses.
 String? get sellerName; double? get distanceKm; bool? get inRange; double? get rating; int? get reviewCount;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other.cuisineTypes, cuisineTypes)&&const DeepCollectionEquality().equals(other.dishTypes, dishTypes)&&const DeepCollectionEquality().equals(other.dietaryTags, dietaryTags)&&const DeepCollectionEquality().equals(other.allergens, allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.category, category) || other.category == category)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.extras, extras)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.inRange, inRange) || other.inRange == inRange)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,name,description,const DeepCollectionEquality().hash(imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(cuisineTypes),const DeepCollectionEquality().hash(dishTypes),const DeepCollectionEquality().hash(dietaryTags),const DeepCollectionEquality().hash(allergens),otherAllergens,isAvailable,isVeg,menuCategory,category,fulfillment,prepMinutes,expiresAt,createdAt,updatedAt,const DeepCollectionEquality().hash(extras),sellerName,distanceKm,inRange,rating,reviewCount]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, category: $category, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, extras: $extras, sellerName: $sellerName, distanceKm: $distanceKm, inRange: $inRange, rating: $rating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, String name, String? description, List<String> imageUrls, int priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType> cuisineTypes, List<DishType> dishTypes, List<DietaryTag> dietaryTags, List<Allergen> allergens, String? otherAllergens, bool isAvailable, bool isVeg, String? menuCategory, SellerCategory category, Fulfillment fulfillment, int prepMinutes, DateTime? expiresAt, DateTime createdAt, DateTime updatedAt, List<ListingExtra> extras, String? sellerName, double? distanceKm, bool? inRange, double? rating, int? reviewCount
});




}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? name = null,Object? description = freezed,Object? imageUrls = null,Object? priceCents = null,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = null,Object? dishTypes = null,Object? dietaryTags = null,Object? allergens = null,Object? otherAllergens = freezed,Object? isAvailable = null,Object? isVeg = null,Object? menuCategory = freezed,Object? category = null,Object? fulfillment = null,Object? prepMinutes = null,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? extras = null,Object? sellerName = freezed,Object? distanceKm = freezed,Object? inRange = freezed,Object? rating = freezed,Object? reviewCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
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
as String?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory,fulfillment: null == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment,prepMinutes: null == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,extras: null == extras ? _self.extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtra>,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,inRange: freezed == inRange ? _self.inRange : inRange // ignore: cast_nullable_to_non_nullable
as bool?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool isAvailable,  bool isVeg,  String? menuCategory,  SellerCategory category,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt,  List<ListingExtra> extras,  String? sellerName,  double? distanceKm,  bool? inRange,  double? rating,  int? reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.category,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.extras,_that.sellerName,_that.distanceKm,_that.inRange,_that.rating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool isAvailable,  bool isVeg,  String? menuCategory,  SellerCategory category,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt,  List<ListingExtra> extras,  String? sellerName,  double? distanceKm,  bool? inRange,  double? rating,  int? reviewCount)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.category,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.extras,_that.sellerName,_that.distanceKm,_that.inRange,_that.rating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  String name,  String? description,  List<String> imageUrls,  int priceCents,  int? originalPriceCents,  int? discountPercent,  int? portionsLeft,  List<CuisineType> cuisineTypes,  List<DishType> dishTypes,  List<DietaryTag> dietaryTags,  List<Allergen> allergens,  String? otherAllergens,  bool isAvailable,  bool isVeg,  String? menuCategory,  SellerCategory category,  Fulfillment fulfillment,  int prepMinutes,  DateTime? expiresAt,  DateTime createdAt,  DateTime updatedAt,  List<ListingExtra> extras,  String? sellerName,  double? distanceKm,  bool? inRange,  double? rating,  int? reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.name,_that.description,_that.imageUrls,_that.priceCents,_that.originalPriceCents,_that.discountPercent,_that.portionsLeft,_that.cuisineTypes,_that.dishTypes,_that.dietaryTags,_that.allergens,_that.otherAllergens,_that.isAvailable,_that.isVeg,_that.menuCategory,_that.category,_that.fulfillment,_that.prepMinutes,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.extras,_that.sellerName,_that.distanceKm,_that.inRange,_that.rating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing implements Listing {
  const _Listing({required this.id, required this.sellerId, required this.name, this.description, final  List<String> imageUrls = const <String>[], required this.priceCents, this.originalPriceCents, this.discountPercent, this.portionsLeft, final  List<CuisineType> cuisineTypes = const <CuisineType>[], final  List<DishType> dishTypes = const <DishType>[], final  List<DietaryTag> dietaryTags = const <DietaryTag>[], final  List<Allergen> allergens = const <Allergen>[], this.otherAllergens, this.isAvailable = true, this.isVeg = false, this.menuCategory, required this.category, required this.fulfillment, required this.prepMinutes, this.expiresAt, required this.createdAt, required this.updatedAt, final  List<ListingExtra> extras = const <ListingExtra>[], this.sellerName, this.distanceKm, this.inRange, this.rating, this.reviewCount}): _imageUrls = imageUrls,_cuisineTypes = cuisineTypes,_dishTypes = dishTypes,_dietaryTags = dietaryTags,_allergens = allergens,_extras = extras;
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  String name;
@override final  String? description;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  int priceCents;
@override final  int? originalPriceCents;
@override final  int? discountPercent;
/// null = "cook to order" (restaurant/traiteur). Required + `> 0`
/// for fait_maison.
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
@override@JsonKey() final  bool isAvailable;
@override@JsonKey() final  bool isVeg;
@override final  String? menuCategory;
@override final  SellerCategory category;
@override final  Fulfillment fulfillment;
@override final  int prepMinutes;
/// null = permanent menu item (restaurant/traiteur). Required for
/// fait_maison.
@override final  DateTime? expiresAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Per-listing add-ons. Always empty on buyer-feed items — fetch
/// detail via `GET /v1/listings/:id` to load the real extras.
 final  List<ListingExtra> _extras;
/// Per-listing add-ons. Always empty on buyer-feed items — fetch
/// detail via `GET /v1/listings/:id` to load the real extras.
@override@JsonKey() List<ListingExtra> get extras {
  if (_extras is EqualUnmodifiableListView) return _extras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extras);
}

//* Buyer-feed-only fields — present on items from `GET /v1/listings`,
//* absent on the detail and seller-dashboard responses.
@override final  String? sellerName;
@override final  double? distanceKm;
@override final  bool? inRange;
@override final  double? rating;
@override final  int? reviewCount;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.originalPriceCents, originalPriceCents) || other.originalPriceCents == originalPriceCents)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.portionsLeft, portionsLeft) || other.portionsLeft == portionsLeft)&&const DeepCollectionEquality().equals(other._cuisineTypes, _cuisineTypes)&&const DeepCollectionEquality().equals(other._dishTypes, _dishTypes)&&const DeepCollectionEquality().equals(other._dietaryTags, _dietaryTags)&&const DeepCollectionEquality().equals(other._allergens, _allergens)&&(identical(other.otherAllergens, otherAllergens) || other.otherAllergens == otherAllergens)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.menuCategory, menuCategory) || other.menuCategory == menuCategory)&&(identical(other.category, category) || other.category == category)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._extras, _extras)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.inRange, inRange) || other.inRange == inRange)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,name,description,const DeepCollectionEquality().hash(_imageUrls),priceCents,originalPriceCents,discountPercent,portionsLeft,const DeepCollectionEquality().hash(_cuisineTypes),const DeepCollectionEquality().hash(_dishTypes),const DeepCollectionEquality().hash(_dietaryTags),const DeepCollectionEquality().hash(_allergens),otherAllergens,isAvailable,isVeg,menuCategory,category,fulfillment,prepMinutes,expiresAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_extras),sellerName,distanceKm,inRange,rating,reviewCount]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, name: $name, description: $description, imageUrls: $imageUrls, priceCents: $priceCents, originalPriceCents: $originalPriceCents, discountPercent: $discountPercent, portionsLeft: $portionsLeft, cuisineTypes: $cuisineTypes, dishTypes: $dishTypes, dietaryTags: $dietaryTags, allergens: $allergens, otherAllergens: $otherAllergens, isAvailable: $isAvailable, isVeg: $isVeg, menuCategory: $menuCategory, category: $category, fulfillment: $fulfillment, prepMinutes: $prepMinutes, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, extras: $extras, sellerName: $sellerName, distanceKm: $distanceKm, inRange: $inRange, rating: $rating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, String name, String? description, List<String> imageUrls, int priceCents, int? originalPriceCents, int? discountPercent, int? portionsLeft, List<CuisineType> cuisineTypes, List<DishType> dishTypes, List<DietaryTag> dietaryTags, List<Allergen> allergens, String? otherAllergens, bool isAvailable, bool isVeg, String? menuCategory, SellerCategory category, Fulfillment fulfillment, int prepMinutes, DateTime? expiresAt, DateTime createdAt, DateTime updatedAt, List<ListingExtra> extras, String? sellerName, double? distanceKm, bool? inRange, double? rating, int? reviewCount
});




}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? name = null,Object? description = freezed,Object? imageUrls = null,Object? priceCents = null,Object? originalPriceCents = freezed,Object? discountPercent = freezed,Object? portionsLeft = freezed,Object? cuisineTypes = null,Object? dishTypes = null,Object? dietaryTags = null,Object? allergens = null,Object? otherAllergens = freezed,Object? isAvailable = null,Object? isVeg = null,Object? menuCategory = freezed,Object? category = null,Object? fulfillment = null,Object? prepMinutes = null,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? extras = null,Object? sellerName = freezed,Object? distanceKm = freezed,Object? inRange = freezed,Object? rating = freezed,Object? reviewCount = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
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
as String?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,menuCategory: freezed == menuCategory ? _self.menuCategory : menuCategory // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SellerCategory,fulfillment: null == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as Fulfillment,prepMinutes: null == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,extras: null == extras ? _self._extras : extras // ignore: cast_nullable_to_non_nullable
as List<ListingExtra>,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,inRange: freezed == inRange ? _self.inRange : inRange // ignore: cast_nullable_to_non_nullable
as bool?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
