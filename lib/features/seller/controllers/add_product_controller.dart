import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homemade/core/enums/food_enums.dart';

/// Owns every piece of state for the [AddProductSheet] form. The sheet
/// itself stays stateless — sections read/write through this controller
/// and rebuild via [Obx] where needed.
class AddProductController extends GetxController {
  AddProductController({this.sellerCategory = SellerCategory.faitMaison});

  final SellerCategory sellerCategory;

  static const int maxPhotos = 4;
  static const double faitMaisonPriceCap = 4.5;

  //* Text fields — listeners drive reactive validation via [_textVersion].
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final portionsController = TextEditingController();
  final otherAllergenController = TextEditingController();

  //* Reactive state.
  late final RxList<String?> photos = RxList<String?>(
    List<String?>.filled(maxPhotos, null),
  );
  final RxSet<CuisineType> cuisines = <CuisineType>{}.obs;
  final RxSet<DietaryTag> diets = <DietaryTag>{}.obs;
  final RxSet<DishType> dishTypes = <DishType>{}.obs;
  final RxSet<Allergen> allergens = <Allergen>{}.obs;
  final Rxn<TimeOfDay> pickupStart = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> pickupEnd = Rxn<TimeOfDay>();
  final RxBool onSite = true.obs;
  final RxBool delivery = false.obs;

  /// Bumped on every text change so [canSubmit] re-evaluates inside Obx.
  final RxInt _textVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(_onTextChanged);
    descriptionController.addListener(_onTextChanged);
    priceController.addListener(_onTextChanged);
    portionsController.addListener(_onTextChanged);
    otherAllergenController.addListener(_onTextChanged);
  }

  void _onTextChanged() => _textVersion.value++;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    portionsController.dispose();
    otherAllergenController.dispose();
    super.onClose();
  }

  bool get isFaitMaison => sellerCategory == SellerCategory.faitMaison;

  List<DishType> get dishOptions => DishType.valuesFor(sellerCategory);

  /// Form gating. Reads the relevant Rx values so an enclosing Obx
  /// re-evaluates as the user fills the form.
  bool get canSubmit {
    //? touch the reactives so Obx subscribes to them.
    _textVersion.value;
    allergens.length;
    onSite.value;
    delivery.value;

    if (titleController.text.trim().isEmpty) return false;
    if (descriptionController.text.trim().isEmpty) return false;
    final price = double.tryParse(
      priceController.text.replaceAll(',', '.'),
    );
    if (price == null || price <= 0) return false;
    if (isFaitMaison && price > faitMaisonPriceCap) return false;
    final portions = int.tryParse(portionsController.text);
    if (portions == null || portions <= 0) return false;
    if (allergens.isEmpty) return false;
    if (allergens.contains(Allergen.autres) &&
        otherAllergenController.text.trim().isEmpty) {
      return false;
    }
    if (!onSite.value && !delivery.value) return false;
    return true;
  }

  void toggleCuisine(CuisineType c) {
    if (!cuisines.add(c)) cuisines.remove(c);
  }

  void toggleDiet(DietaryTag d) {
    if (!diets.add(d)) diets.remove(d);
  }

  void toggleDishType(DishType d) {
    if (!dishTypes.add(d)) dishTypes.remove(d);
  }

  /// "Aucun" is exclusive — picking it clears everything else; picking
  /// anything else removes "Aucun".
  void toggleAllergen(Allergen a) {
    if (a.isExclusive) {
      if (allergens.contains(a)) {
        allergens.remove(a);
      } else {
        allergens
          ..clear()
          ..add(a);
      }
    } else {
      allergens.remove(Allergen.aucun);
      if (!allergens.add(a)) allergens.remove(a);
    }
  }

  void setPickupStart(TimeOfDay v) => pickupStart.value = v;
  void setPickupEnd(TimeOfDay v) => pickupEnd.value = v;
  void setOnSite(bool v) => onSite.value = v;
  void setDelivery(bool v) => delivery.value = v;

  void addPhoto(int index) {
    photos[index] = 'placeholder://$index';
    photos.refresh();
  }

  void removePhoto(int index) {
    photos[index] = null;
    photos.refresh();
  }
}
