import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/auth/kyc_document.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';
import 'package:incacook/features/catalog/data/models/requests/create_listing_request.dart';
import 'package:incacook/features/catalog/data/models/requests/update_listing_request.dart';
import 'package:incacook/features/catalog/data/repositories/listings_repository.dart';

/// Owns every piece of state for the [AddProductSheet] form. The sheet
/// itself stays stateless — sections read/write through this controller
/// and rebuild via [Obx] where needed.
///
/// Pass [existing] to open the sheet in **edit mode**: the form is
/// pre-filled from that listing and [submit] PATCHes it instead of
/// creating a new one.
class AddProductController extends GetxController {
  AddProductController({
    SellerCategory sellerCategory = SellerCategory.faitMaison,
    Listing? existing,
    ListingsRepository? listingsRepository,
  }) : sellerCategory = existing?.category ?? sellerCategory,
       _existing = existing,
       _listings = listingsRepository ?? ListingsRepository();

  final SellerCategory sellerCategory;
  final Listing? _existing;
  final ListingsRepository _listings;

  bool get isEditing => _existing != null;

  /// Create/update-in-flight flag — drives the publish button's spinner.
  final RxBool isSubmitting = false.obs;

  static const int maxPhotos = 4;
  static const double faitMaisonPriceCap = 4.5;

  //* Text fields — listeners drive reactive validation via [_textVersion].
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final portionsController = TextEditingController();
  final prepMinutesController = TextEditingController();
  final otherAllergenController = TextEditingController();

  //* Reactive state. One slot per allowed photo; each tracks its own
  //* upload lifecycle (local preview file + committed storage path).
  late final RxList<ProductPhoto> photos = RxList<ProductPhoto>(
    List<ProductPhoto>.generate(maxPhotos, (_) => ProductPhoto()),
  );
  final RxSet<CuisineType> cuisines = <CuisineType>{}.obs;
  final RxSet<DietaryTag> diets = <DietaryTag>{}.obs;
  final RxSet<DishType> dishTypes = <DishType>{}.obs;
  final RxSet<Allergen> allergens = <Allergen>{}.obs;

  /// Explicit "Aucun" (no allergens). Mutually exclusive with the real
  /// allergens and "Autres".
  final RxBool noAllergens = false.obs;

  /// "Autres" chip — when on, [otherAllergenController] text is required.
  final RxBool otherSelected = false.obs;

  /// Seller's CGU/CGV consent. Required at publication (create) only — the
  /// publish button stays disabled until checked. Not required when editing.
  final RxBool termsAccepted = false.obs;
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
    prepMinutesController.addListener(_onTextChanged);
    otherAllergenController.addListener(_onTextChanged);
    if (_existing != null) _prefillFromExisting(_existing);
  }

  void _prefillFromExisting(Listing e) {
    titleController.text = e.name;
    descriptionController.text = e.description ?? '';
    priceController.text = (e.priceCents / 100).toStringAsFixed(2);
    portionsController.text = (e.portionsLeft ?? 0).toString();
    prepMinutesController.text = e.prepMinutes.toString();
    otherAllergenController.text = e.otherAllergens ?? '';

    cuisines
      ..clear()
      ..addAll(e.cuisineTypes);
    diets
      ..clear()
      ..addAll(e.dietaryTags);
    dishTypes
      ..clear()
      ..addAll(e.dishTypes);
    allergens
      ..clear()
      ..addAll(e.allergens);
    final hasOther =
        e.otherAllergens != null && e.otherAllergens!.trim().isNotEmpty;
    otherSelected.value = hasOther;
    // An existing listing with no allergens + no "Autres" text reads back as
    // an explicit "Aucun".
    noAllergens.value = e.allergens.isEmpty && !hasOther;

    // Reverse-map [Fulfillment] back into the two switches.
    switch (e.fulfillment) {
      case Fulfillment.pickup:
        onSite.value = true;
        delivery.value = false;
      case Fulfillment.delivery:
        onSite.value = false;
        delivery.value = true;
      case Fulfillment.both:
        onSite.value = true;
        delivery.value = true;
    }

    // expiresAt → pickupEnd time so [_expiresAt] can rebuild it on save.
    final exp = e.expiresAt;
    if (exp != null) {
      pickupEnd.value = TimeOfDay(hour: exp.hour, minute: exp.minute);
    }

    // Existing image paths populate the photo slots as "already uploaded"
    // — no local file, just the committed storage path so they survive
    // [uploadedImagePaths] without re-uploading.
    for (var i = 0; i < photos.length && i < e.imageUrls.length; i++) {
      photos[i] = ProductPhoto(path: e.imageUrls[i]);
    }
    photos.refresh();
  }

  void _onTextChanged() => _textVersion.value++;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    portionsController.dispose();
    prepMinutesController.dispose();
    otherAllergenController.dispose();
    super.onClose();
  }

  bool get isFaitMaison => sellerCategory == SellerCategory.faitMaison;

  List<DishType> get dishOptions => DishType.valuesFor(sellerCategory);

  /// Enables the publish button once the core fields are filled. The
  /// fait-maison price cap is deliberately NOT checked here — instead it
  /// surfaces a visible message ([priceCapExceeded] + the submit guard) so
  /// the button is never silently disabled for it. Reads the relevant Rx
  /// values so an enclosing Obx re-evaluates as the user fills the form.
  bool get canSubmit {
    //? touch the reactives so Obx subscribes to them.
    _textVersion.value;
    allergens.length;
    noAllergens.value;
    otherSelected.value;
    onSite.value;
    delivery.value;
    termsAccepted.value;

    if (titleController.text.trim().isEmpty) return false;
    if (descriptionController.text.trim().isEmpty) return false;
    final price = double.tryParse(
      priceController.text.replaceAll(',', '.'),
    );
    if (price == null || price <= 0) return false;
    final portions = int.tryParse(portionsController.text);
    if (portions == null || portions <= 0) return false;
    final prepMinutes = int.tryParse(prepMinutesController.text);
    if (prepMinutes == null || prepMinutes < 0) return false;
    if (!onSite.value && !delivery.value) return false;
    // Allergen declaration is mandatory (food-safety): ≥1 allergen,
    // "Autres" + text, or explicit "Aucun".
    if (!hasAllergenDeclaration || otherAllergenMissingText) return false;
    // CGU/CGV must be accepted to publish a new dish (not when editing).
    if (!isEditing && !termsAccepted.value) return false;
    return true;
  }

  /// True when a fait-maison product is priced above the €4.50 cap. Drives
  /// the inline price error so the rule is explained rather than silently
  /// blocking the button.
  bool get priceCapExceeded {
    _textVersion.value;
    if (!isFaitMaison) return false;
    final price = double.tryParse(priceController.text.replaceAll(',', '.'));
    return price != null && price > faitMaisonPriceCap;
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

  void toggleAllergen(Allergen a) {
    // Selecting a real allergen exits the exclusive "Aucun" state.
    noAllergens.value = false;
    if (!allergens.add(a)) allergens.remove(a);
  }

  /// Toggles the "Autres" chip. Off → clears the free text. On → exits "Aucun".
  void toggleOtherAllergen() {
    otherSelected.value = !otherSelected.value;
    if (otherSelected.value) {
      noAllergens.value = false;
    } else {
      otherAllergenController.clear();
    }
  }

  /// Toggles "Aucun". On → clears every other allergen choice (exclusive).
  void toggleNoAllergens() {
    noAllergens.value = !noAllergens.value;
    if (noAllergens.value) {
      allergens.clear();
      otherSelected.value = false;
      otherAllergenController.clear();
    }
  }

  /// Valid allergen declaration: ≥1 allergen, "Autres" with text, or "Aucun".
  bool get hasAllergenDeclaration {
    if (noAllergens.value) return true;
    if (allergens.isNotEmpty) return true;
    return otherSelected.value &&
        otherAllergenController.text.trim().isNotEmpty;
  }

  /// "Autres" toggled but its text is still empty.
  bool get otherAllergenMissingText =>
      otherSelected.value && otherAllergenController.text.trim().isEmpty;

  void setPickupStart(TimeOfDay v) => pickupStart.value = v;
  void setPickupEnd(TimeOfDay v) => pickupEnd.value = v;
  void setOnSite(bool v) => onSite.value = v;
  void setDelivery(bool v) => delivery.value = v;

  /// Committed storage paths for the slots that finished uploading, in
  /// slot order. This is what `imageUrls` on `POST /v1/listings` expects.
  List<String> get uploadedImagePaths =>
      photos.where((p) => p.path != null).map((p) => p.path!).toList();

  /// True while any slot is still uploading — used to keep the seller from
  /// submitting before every image has a committed path.
  bool get isUploadingPhotos => photos.any((p) => p.uploading);

  /// Pick one image into [index] and run the §3.19 two-step upload
  /// (`POST /v1/uploads` → PUT bytes to Supabase). The returned storage
  /// path is what we later send in `imageUrls`.
  Future<void> pickPhoto(int index, ImageSource source) async {
    final slot = photos[index];
    slot
      ..uploading = true
      ..error = null;
    photos.refresh();
    try {
      final result = await pickAndUploadImage(
        source: source,
        purpose: UploadPurpose.listingImage,
      );
      if (result == null) {
        // User cancelled the system picker — leave the slot as it was.
        slot.uploading = false;
        photos.refresh();
        return;
      }
      slot
        ..file = result.file
        ..path = result.path
        ..uploading = false;
      photos.refresh();
    } on ApiFailure catch (e) {
      slot
        ..uploading = false
        ..error = e.message;
      photos.refresh();
    } catch (e) {
      slot
        ..uploading = false
        ..error = e.toString();
      photos.refresh();
    }
  }

  void removePhoto(int index) {
    photos[index] = ProductPhoto();
    photos.refresh();
  }

  /// Returns the first user-facing reason the form can't be published yet,
  /// or null when it's ready. Covers the soft rules that [canSubmit] leaves
  /// off the button (price cap, photos, fait-maison expiry) so the user
  /// gets a clear message instead of a mystery.
  String? validationError() {
    if (titleController.text.trim().isEmpty) return 'Ajoute un titre.';
    if (descriptionController.text.trim().isEmpty) {
      return 'Ajoute une description.';
    }
    final price = double.tryParse(priceController.text.replaceAll(',', '.'));
    if (price == null || price <= 0) return 'Indique un prix valide.';
    if (isFaitMaison && price > faitMaisonPriceCap) {
      return AppTexts.addProductPriceCapError;
    }
    final portions = int.tryParse(portionsController.text);
    if (portions == null || portions <= 0) {
      return 'Indique le nombre de portions.';
    }
    final prep = int.tryParse(prepMinutesController.text);
    if (prep == null || prep < 0) return 'Indique le temps de préparation.';
    if (!onSite.value && !delivery.value) {
      return 'Choisis au moins un mode de récupération.';
    }
    if (isUploadingPhotos) return 'Attends la fin du téléversement des photos.';
    if (uploadedImagePaths.isEmpty) return 'Ajoute au moins une photo.';
    if (isFaitMaison && _expiresAt() == null) {
      return "Indique l'heure limite de retrait (disponibilité).";
    }
    if (otherAllergenMissingText) {
      return 'Précise l\'allergène « Autres ».';
    }
    if (!hasAllergenDeclaration) {
      return 'Déclare au moins un allergène (ou « Aucun »).';
    }
    if (!isEditing && !termsAccepted.value) {
      return 'Accepte les CGU/CGV avant de publier.';
    }
    return null;
  }

  /// Validates, builds the `POST /v1/listings` body, and creates the
  /// listing. Returns true on success (caller closes the sheet); shows a
  /// snackbar and returns false on any validation or API error.
  Future<bool> submit() async {
    final error = validationError();
    if (error != null) {
      CustomLoaders.warningSnackBar(title: 'Champ manquant', message: error);
      return false;
    }
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      if (isEditing) {
        await _listings.update(_existing!.id, _buildUpdateRequest());
      } else {
        await _listings.create(_buildRequest());
      }
      CustomLoaders.successSnackBar(
        title: isEditing ? 'Produit mis à jour' : 'Produit publié',
        message: isEditing
            ? AppTexts.addProductUpdateSuccess
            : AppTexts.addProductPublishSuccess,
      );
      return true;
    } on ApiFailure catch (e) {
      // The backend's pro-seller gate throws a raw "KYC_NOT_APPROVED" — never
      // surface that. Show a clear French status message (pending vs rejected)
      // and keep publish blocked until an admin approves.
      if (_isKycNotApproved(e)) {
        CustomLoaders.warningSnackBar(
          title: 'Validation requise',
          message: await _kycStatusMessage(),
        );
      } else {
        CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
      }
      return false;
    } catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _isKycNotApproved(ApiFailure e) =>
      e.code == 'KYC_NOT_APPROVED' || e.message.contains('KYC_NOT_APPROVED');

  /// Clean French KYC message. Distinguishes pending vs rejected from the
  /// seller's own documents (`GET /v1/kyc/documents/me`); best-effort, falls
  /// back to the pending wording if that lookup fails.
  Future<String> _kycStatusMessage() async {
    try {
      final docs = await KycRepository().listMyDocuments();
      final rejected =
          docs.any((d) => d.reviewState == KycReviewState.rejected);
      if (rejected) return AppTexts.kycRejectedMessage;
    } catch (_) {
      // best-effort — fall through to the pending message.
    }
    return AppTexts.kycPendingMessage;
  }

  /// Edit-mode body — same shape as create, but every field is optional
  /// on the wire. We send the full set so the form is the single source
  /// of truth for the listing (`existing ⊕ dto` ≡ dto here).
  UpdateListingRequest _buildUpdateRequest() {
    final price = double.parse(priceController.text.replaceAll(',', '.'));
    final fulfillment = onSite.value && delivery.value
        ? Fulfillment.both
        : (delivery.value ? Fulfillment.delivery : Fulfillment.pickup);
    final description = descriptionController.text.trim();
    final other = otherAllergenController.text.trim();
    return UpdateListingRequest(
      name: titleController.text.trim(),
      description: description.isEmpty ? null : description,
      imageUrls: uploadedImagePaths,
      priceCents: (price * 100).round(),
      portionsLeft: int.parse(portionsController.text),
      cuisineTypes: cuisines.toList(),
      dishTypes: isFaitMaison ? const <DishType>[] : dishTypes.toList(),
      dietaryTags: diets.toList(),
      allergens: noAllergens.value ? const <Allergen>[] : allergens.toList(),
      otherAllergens:
          (!noAllergens.value && otherSelected.value && other.isNotEmpty)
          ? other
          : null,
      declaresNoAllergens: noAllergens.value,
      isAvailable: true,
      fulfillment: fulfillment,
      prepMinutes: int.parse(prepMinutesController.text),
      expiresAt: _expiresAt(),
    );
  }

  CreateListingRequest _buildRequest() {
    final price = double.parse(priceController.text.replaceAll(',', '.'));
    final fulfillment = onSite.value && delivery.value
        ? Fulfillment.both
        : (delivery.value ? Fulfillment.delivery : Fulfillment.pickup);
    final description = descriptionController.text.trim();
    final other = otherAllergenController.text.trim();
    return CreateListingRequest(
      name: titleController.text.trim(),
      description: description.isEmpty ? null : description,
      imageUrls: uploadedImagePaths,
      priceCents: (price * 100).round(),
      portionsLeft: int.parse(portionsController.text),
      cuisineTypes: cuisines.toList(),
      // §4: fait-maison must send an empty dishTypes; the picker already
      // hides them for that category, but enforce it here too.
      dishTypes: isFaitMaison ? const <DishType>[] : dishTypes.toList(),
      dietaryTags: diets.toList(),
      allergens: noAllergens.value ? const <Allergen>[] : allergens.toList(),
      otherAllergens:
          (!noAllergens.value && otherSelected.value && other.isNotEmpty)
          ? other
          : null,
      declaresNoAllergens: noAllergens.value,
      isAvailable: true,
      fulfillment: fulfillment,
      prepMinutes: int.parse(prepMinutesController.text),
      expiresAt: _expiresAt(),
      termsAccepted: termsAccepted.value,
    );
  }

  /// Maps the pickup-end time to a concrete expiry instant: today at that
  /// time, rolled to tomorrow if it's already past. Null when no end time
  /// is set (allowed for restaurant/traiteur; required for fait-maison —
  /// guarded in [validationError]).
  DateTime? _expiresAt() {
    final end = pickupEnd.value;
    if (end == null) return null;
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    if (!dt.isAfter(now)) dt = dt.add(const Duration(days: 1));
    return dt;
  }
}

/// One photo slot in the add-product grid, tracking its own upload state.
class ProductPhoto {
  ProductPhoto({this.file, this.path, this.uploading = false, this.error});

  /// Local file for instant preview; null until the user picks one.
  File? file;

  /// Committed Supabase Storage path returned by `POST /v1/uploads`.
  String? path;

  /// Upload-in-flight flag — drives the per-tile spinner.
  bool uploading;

  /// Last upload error for this slot, if any.
  String? error;

  bool get isEmpty => file == null && path == null && !uploading && error == null;
}
