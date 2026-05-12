import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/models/auth/address_record.dart';
import 'package:incacook/core/models/auth/charter.dart';
import 'package:incacook/core/models/auth/kyc_document.dart';
import 'package:incacook/core/models/auth/opening_hours.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/models/day_of_week.dart';
import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';
import 'package:incacook/features/authentication/data/models/id_document_type.dart';
import 'package:incacook/features/authentication/data/models/requests/accept_charter_request.dart';
import 'package:incacook/features/authentication/data/models/requests/buyer_preferences_request.dart';
import 'package:incacook/features/authentication/data/models/requests/complete_profile_request.dart';
import 'package:incacook/features/authentication/data/models/requests/create_kyc_document_request.dart';
import 'package:incacook/features/authentication/data/models/requests/driver_vehicle_request.dart';
import 'package:incacook/features/authentication/data/models/requests/driver_zones_request.dart';
import 'package:incacook/features/authentication/data/models/requests/request_otp_request.dart';
import 'package:incacook/features/authentication/data/models/requests/seller_business_request.dart';
import 'package:incacook/features/authentication/data/models/requests/seller_cuisines_request.dart';
import 'package:incacook/features/authentication/data/models/requests/seller_profile_request.dart';
import 'package:incacook/features/authentication/data/models/requests/signup_request.dart';
import 'package:incacook/features/authentication/data/models/requests/upsert_address_request.dart';
import 'package:incacook/features/authentication/data/models/requests/verify_otp_request.dart';
import 'package:incacook/features/authentication/data/models/signup_step.dart';
import 'package:incacook/features/authentication/data/models/time_range.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/charters_repository.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/client/presentation/client_nav_tabs.dart';
import 'package:incacook/features/delivery/presentation/screens/delivery_home.dart';
import 'package:incacook/features/seller/presentation/seller_nav_tabs.dart';

/// Drives the entire CULINEA multi-step signup flow.
///
/// Three responsibilities:
///   1. Hold every piece of state collected across steps (reactive).
///   2. Decide the dynamic ordered list of [SignupStep]s for the chosen
///      role / sub-type / vehicle so pages can be added or skipped.
///   3. Mediate navigation between the [PageController]'s page index and
///      the step list, and answer [canGoNext] for the current step.
class SignupFlowController extends GetxController {
  static SignupFlowController get instance => Get.find();

  SignupFlowController({
    AuthRepository? authRepository,
    UsersRepository? usersRepository,
    ChartersRepository? chartersRepository,
    BuyersRepository? buyersRepository,
    SellersRepository? sellersRepository,
    DriversRepository? driversRepository,
    KycRepository? kycRepository,
  }) : _authRepository = authRepository ?? Get.find<AuthRepository>(),
       _usersRepository = usersRepository ?? Get.find<UsersRepository>(),
       _chartersRepository =
           chartersRepository ?? Get.find<ChartersRepository>(),
       _buyersRepository = buyersRepository ?? Get.find<BuyersRepository>(),
       _sellersRepository = sellersRepository ?? Get.find<SellersRepository>(),
       _driversRepository = driversRepository ?? Get.find<DriversRepository>(),
       _kycRepository = kycRepository ?? Get.find<KycRepository>();

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final ChartersRepository _chartersRepository;
  final BuyersRepository _buyersRepository;
  final SellersRepository _sellersRepository;
  final DriversRepository _driversRepository;
  final KycRepository _kycRepository;

  /// Active charter versions, fetched lazily on first need (CGU on
  /// legal-acceptance, role charters on the charter step).
  ActiveCharters? _activeCharters;

  /// Surfaces a user-visible error from the current step's network call.
  /// Cleared whenever the user advances or navigates back.
  final submitError = ''.obs;

  /// True once `POST /v1/auth/signup` has returned (we have a session).
  /// Guards `submitCompleteProfile` from being called without auth.
  final isSignedUp = false.obs;

  // ---------------------------------------------------------------------------
  // Step 0 — universal info
  // ---------------------------------------------------------------------------
  final email = ''.obs;
  final phone = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;

  // Backing [TextEditingController]s for the basic-info fields. Each one
  // pushes its text back into the corresponding [Rx] above via a listener
  // (registered in [onInit]) so validation rules in [canGoNext] always
  // see the latest typed value.
  late final TextEditingController firstNameTextController;
  late final TextEditingController lastNameTextController;
  late final TextEditingController emailTextController;
  late final TextEditingController phoneTextController;
  late final TextEditingController passwordTextController;
  late final TextEditingController confirmPasswordTextController;

  final phoneVerified = false.obs;
  final emailVerified = false.obs;
  final biometricEnabled = false.obs;
  final acceptedCgu = false.obs;
  final acceptedCgv = false.obs;

  // OTP & resend countdown.
  final otpCode = ''.obs;
  final otpResendSecondsLeft = 0.obs;
  final otpVerifying = false.obs;
  final otpError = ''.obs;
  Timer? _otpTimer;

  // ---------------------------------------------------------------------------
  // Step 1 — role choice
  // ---------------------------------------------------------------------------
  final Rxn<UserRole> role = Rxn<UserRole>();
  final Rxn<SellerCategory> sellerCategory = Rxn<SellerCategory>();
  final Rxn<DriverVehicleType> vehicleType = Rxn<DriverVehicleType>();

  // ---------------------------------------------------------------------------
  // Buyer-specific
  // ---------------------------------------------------------------------------
  final Rxn<Address> deliveryAddress = Rxn<Address>();
  final dietaryPreferences = <DietaryTag>[].obs;
  final allergies = <Allergen>[].obs;

  // ---------------------------------------------------------------------------
  // Seller-specific
  // ---------------------------------------------------------------------------
  final profilePhotoUrl = ''.obs;
  final displayName = ''.obs;
  final bio = ''.obs;
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final Rxn<Address> pickupAddress = Rxn<Address>();
  final businessName = ''.obs;
  final siret = ''.obs;
  final restaurantFacadeUrl = ''.obs;
  final openingHours = <DayOfWeek, DailyTimeRange>{}.obs;
  final cuisineTypes = <CuisineType>[].obs;
  final dishTypes = <DishType>[].obs;
  final Rxn<IdDocumentType> idDocumentType = Rxn<IdDocumentType>();
  final idFrontUrl = ''.obs;
  final idBackUrl = ''.obs;
  final selfieUrl = ''.obs;
  final hygieneCommitmentChecked = false.obs;
  final faitMaisonCommitmentChecked = false.obs;

  // ---------------------------------------------------------------------------
  // Driver-specific
  // ---------------------------------------------------------------------------
  final operatingZones = <String>[].obs;
  final drivingLicenseUrl = ''.obs;
  final carteGriseUrl = ''.obs;
  final driverCharterAccepted = false.obs;
  final driverPunctualityCommitment = false.obs;
  final driverCareCommitment = false.obs;

  // ---------------------------------------------------------------------------
  // Meta — derived from current page index + dynamic step list.
  // ---------------------------------------------------------------------------
  final currentPage = 0.obs;
  final isLoading = false.obs;
  final charterScrolledToBottom = false.obs;
  late final PageController pageController = PageController();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    // Whenever role / sub-type / vehicle changes, the steps list shifts —
    // re-emit currentPage so anything bound to `totalPages` repaints.
    ever<UserRole?>(role, (_) => currentPage.refresh());
    ever<SellerCategory?>(sellerCategory, (_) => currentPage.refresh());
    ever<DriverVehicleType?>(vehicleType, (_) => currentPage.refresh());

    // In debug builds, prefill the basic-info form with random sample
    // data so the validation gate passes without manual typing on every
    // hot reload. Release builds start with empty fields.
    final seed = kDebugMode ? _DevSeed.random() : _DevSeed.empty();
    firstName.value = seed.firstName;
    lastName.value = seed.lastName;
    email.value = seed.email;
    phone.value = seed.phone;
    password.value = seed.password;
    confirmPassword.value = seed.password;

    firstNameTextController = TextEditingController(text: seed.firstName)
      ..addListener(() => firstName.value = firstNameTextController.text);
    lastNameTextController = TextEditingController(text: seed.lastName)
      ..addListener(() => lastName.value = lastNameTextController.text);
    emailTextController = TextEditingController(text: seed.email)
      ..addListener(() => email.value = emailTextController.text.trim());
    phoneTextController = TextEditingController(text: seed.phone)
      ..addListener(() => phone.value = phoneTextController.text);
    passwordTextController = TextEditingController(text: seed.password)
      ..addListener(() => password.value = passwordTextController.text);
    confirmPasswordTextController =
        TextEditingController(text: seed.password)
          ..addListener(
            () => confirmPassword.value = confirmPasswordTextController.text,
          );
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    pageController.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    emailTextController.dispose();
    phoneTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Step list — the source of truth for page ordering.
  // ---------------------------------------------------------------------------
  List<SignupStep> get steps {
    final list = <SignupStep>[
      SignupStep.basicInfo,
      SignupStep.phoneVerification,
      SignupStep.biometricSetup,
      SignupStep.legalAcceptance,
      SignupStep.roleSelection,
    ];

    switch (role.value) {
      case UserRole.buyer:
        list.addAll([
          SignupStep.buyerAddress,
          SignupStep.buyerDietary,
          SignupStep.buyerDone,
        ]);
      case UserRole.seller:
        list.add(SignupStep.sellerProfile);
        list.add(SignupStep.sellerDobAddress);
        // The sub-type picker was removed from signup. Until the field
        // is set elsewhere (admin tooling, preference screen), it stays
        // null — which means the business-info step is skipped and the
        // seller is treated as a generic professional downstream
        // (auto-approval and SIRET collection both off).
        if (sellerCategory.value != null &&
            sellerCategory.value != SellerCategory.faitMaison) {
          list.add(SignupStep.sellerBusinessInfo);
        }
        list.add(SignupStep.sellerCuisine);
        list.add(SignupStep.sellerKycId);
        list.add(SignupStep.sellerKycSelfie);
        list.add(SignupStep.sellerCharter);
      case UserRole.driver:
        list.addAll([
          SignupStep.driverDobAddress,
          SignupStep.driverVehicle,
          SignupStep.driverKycId,
          SignupStep.driverKycSelfie,
        ]);
        if (vehicleType.value?.requiresMotorizedDocs ?? false) {
          list.add(SignupStep.driverDocuments);
        }
        list.addAll([
          SignupStep.driverZone,
          SignupStep.driverCharter,
        ]);
      case null:
        break;
    }
    return list;
  }

  int get totalPages => steps.length;

  SignupStep get currentStep => steps[currentPage.value.clamp(0, steps.length - 1)];

  bool get isFirstPage => currentPage.value == 0;

  bool get isLastPage => currentPage.value >= steps.length - 1;

  // ---------------------------------------------------------------------------
  // Validators (the per-step rules the bottom-bar checks).
  // ---------------------------------------------------------------------------
  bool get isEmailValid {
    final v = email.value;
    if (v.isEmpty) return false;
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v);
  }

  bool get isPhoneValid {
    final digits = phone.value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 9;
  }

  bool get isPasswordValid {
    final v = password.value;
    return v.length >= 8 &&
        v.contains(RegExp(r'[A-Z]')) &&
        v.contains(RegExp(r'\d'));
  }

  /// 0..4 — used by the strength meter on the basic info page.
  int get passwordStrength {
    final v = password.value;
    if (v.isEmpty) return 0;
    var score = 0;
    if (v.length >= 8) score++;
    if (v.contains(RegExp(r'[A-Z]'))) score++;
    if (v.contains(RegExp(r'\d'))) score++;
    if (v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  bool get isPasswordConfirmed =>
      confirmPassword.value.isNotEmpty &&
      confirmPassword.value == password.value;

  bool _isValidName(String v) {
    if (v.length < 2) return false;
    return RegExp(r"^[a-zA-ZÀ-ÿ' \-]+$").hasMatch(v);
  }

  bool get isBasicInfoComplete =>
      isEmailValid &&
      isPhoneValid &&
      isPasswordValid &&
      isPasswordConfirmed &&
      _isValidName(firstName.value) &&
      _isValidName(lastName.value);

  bool get isAdult {
    final dob = dateOfBirth.value;
    if (dob == null) return false;
    final now = DateTime.now();
    final age = now.year -
        dob.year -
        ((now.month < dob.month ||
                (now.month == dob.month && now.day < dob.day))
            ? 1
            : 0);
    return age >= 18;
  }

  /// SIRET must be 14 digits and pass the Luhn check.
  bool get isSiretValid {
    final digits = siret.value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{14}$').hasMatch(digits)) return false;
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var d = int.parse(digits[i]);
      // SIRET Luhn: positions 0,2,4,6,8,10,12 doubled (0-indexed even).
      if (i.isEven) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0;
  }

  /// Returns whether the Continue button should be enabled for the current
  /// step. A step that needs no validation (purely informational) returns
  /// true unconditionally.
  bool canGoNext() {
    switch (currentStep) {
      case SignupStep.basicInfo:
        return isBasicInfoComplete;
      case SignupStep.phoneVerification:
        return phoneVerified.value;
      case SignupStep.biometricSetup:
        return true;
      case SignupStep.legalAcceptance:
        return acceptedCgu.value && acceptedCgv.value;
      case SignupStep.roleSelection:
        return role.value != null;
      case SignupStep.buyerAddress:
        return deliveryAddress.value != null;
      case SignupStep.buyerDietary:
        return true; // skippable
      case SignupStep.buyerDone:
        return true;
      case SignupStep.sellerProfile:
        return profilePhotoUrl.value.isNotEmpty &&
            displayName.value.trim().length >= 2;
      case SignupStep.sellerDobAddress:
        return isAdult && pickupAddress.value != null;
      case SignupStep.sellerBusinessInfo:
        final base =
            businessName.value.trim().length >= 2 && isSiretValid;
        if (sellerCategory.value == SellerCategory.restaurant) {
          return base &&
              restaurantFacadeUrl.value.isNotEmpty &&
              openingHours.values.any(
                (range) => range.start != range.end,
              );
        }
        return base;
      case SignupStep.sellerCuisine:
        if (cuisineTypes.isEmpty) return false;
        if (sellerCategory.value != SellerCategory.faitMaison) {
          return dishTypes.isNotEmpty;
        }
        return true;
      case SignupStep.sellerKycId:
        if (idDocumentType.value == null) return false;
        if (idDocumentType.value!.requiresVerso) {
          return idFrontUrl.value.isNotEmpty && idBackUrl.value.isNotEmpty;
        }
        return idFrontUrl.value.isNotEmpty;
      case SignupStep.sellerKycSelfie:
        return selfieUrl.value.isNotEmpty;
      case SignupStep.sellerCharter:
        return hygieneCommitmentChecked.value &&
            faitMaisonCommitmentChecked.value;
      case SignupStep.driverDobAddress:
        return isAdult && pickupAddress.value != null;
      case SignupStep.driverVehicle:
        return vehicleType.value != null;
      case SignupStep.driverKycId:
        if (idDocumentType.value == null) return false;
        if (idDocumentType.value!.requiresVerso) {
          return idFrontUrl.value.isNotEmpty && idBackUrl.value.isNotEmpty;
        }
        return idFrontUrl.value.isNotEmpty;
      case SignupStep.driverKycSelfie:
        return selfieUrl.value.isNotEmpty;
      case SignupStep.driverDocuments:
        return drivingLicenseUrl.value.isNotEmpty &&
            carteGriseUrl.value.isNotEmpty;
      case SignupStep.driverZone:
        return operatingZones.isNotEmpty;
      case SignupStep.driverCharter:
        return driverPunctualityCommitment.value &&
            driverCareCommitment.value;
    }
  }

  /// Steps where the bottom bar should also show a "Passer" (Skip) button.
  bool get canSkipCurrent {
    switch (currentStep) {
      case SignupStep.biometricSetup:
      case SignupStep.buyerDietary:
        return true;
      default:
        return false;
    }
  }

  bool get hideBottomBar {
    switch (currentStep) {
      case SignupStep.buyerDone:
        return true;
      default:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------
  Future<void> nextPage() async {
    if (!canGoNext()) return;
    if (isLoading.value) return;

    // Step-gated network calls. Each gate has to succeed before the page
    // advances; on failure, `submitError` is set and the bottom bar
    // re-enables for retry.
    submitError.value = '';
    final gateOk = await _runGateForCurrentStep();
    if (!gateOk) return;

    if (isLastPage) {
      _finishSignup();
      return;
    }
    final next = currentPage.value + 1;
    currentPage.value = next;
    if (pageController.hasClients) {
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Reset per-page transient state.
    charterScrolledToBottom.value = false;
  }

  /// Gate hook — returns false if the step's backend call(s) failed
  /// (and `submitError` is set). Successful gates either return
  /// immediately or, in the case of phoneVerification, are already
  /// satisfied by [verifyOtp]'s side effect on `phoneVerified`.
  ///
  /// Endpoints fired per step are documented in `docs/signup-flow.md`.
  /// Idempotency is on the server side: PUTs upsert, the POST gates
  /// (signup, users, kyc documents) carry an `Idempotency-Key` ULID
  /// auto-issued by [ApiClient].
  Future<bool> _runGateForCurrentStep() async {
    switch (currentStep) {
      case SignupStep.basicInfo:
        return _submitBasicInfoSignup();
      case SignupStep.phoneVerification:
        // verifyOtp already fired POST /auth/phone/verify when the user
        // typed the 6th digit — phoneVerified is true by the time we
        // reach the bottom bar's Continue.
        return true;
      case SignupStep.biometricSetup:
        return true;
      case SignupStep.legalAcceptance:
        // CGU/CGV are sent as flat booleans in Gate 2's body — no
        // separate call here.
        return true;
      case SignupStep.roleSelection:
        return _submitCompleteProfile();

      // Buyer
      case SignupStep.buyerAddress:
        return _putAddress(AddressKind.buyerDelivery);
      case SignupStep.buyerDietary:
        return _putBuyerPreferences();
      case SignupStep.buyerDone:
        return true;

      // Seller
      case SignupStep.sellerProfile:
        // DOB is collected on the next screen; the profile PUT requires
        // it, so we defer firing until sellerDobAddress.
        return true;
      case SignupStep.sellerDobAddress:
        if (!await _putSellerProfile()) return false;
        return _putAddress(AddressKind.sellerPickup);
      case SignupStep.sellerBusinessInfo:
        return _putSellerBusiness();
      case SignupStep.sellerCuisine:
        return _putSellerCuisines();
      case SignupStep.sellerKycId:
        return _submitKycIdSlots();
      case SignupStep.sellerKycSelfie:
        return _submitKycSelfie();
      case SignupStep.sellerCharter:
        return _acceptSellerCharters();

      // Driver
      case SignupStep.driverDobAddress:
        // DOB rides along on the next screen's vehicle PUT (vehicleType
        // is required, so we can't fire setVehicle here).
        return _putAddress(AddressKind.driverHome);
      case SignupStep.driverVehicle:
        return _putDriverVehicle();
      case SignupStep.driverKycId:
        return _submitKycIdSlots();
      case SignupStep.driverKycSelfie:
        return _submitKycSelfie();
      case SignupStep.driverDocuments:
        return _submitDriverDocuments();
      case SignupStep.driverZone:
        return _putDriverZones();
      case SignupStep.driverCharter:
        return _acceptDriverCharters();
    }
  }

  // ---------------------------------------------------------------------------
  // Per-step gate implementations.
  // ---------------------------------------------------------------------------

  Future<bool> _putAddress(AddressKind kind) async {
    final ui = (kind == AddressKind.buyerDelivery
        ? deliveryAddress.value
        : pickupAddress.value);
    if (ui == null) return false;
    return _runApiCall(() async {
      await _usersRepository.upsertAddress(
        kind: kind,
        req: _addressRequestFromUi(ui),
      );
    });
  }

  Future<bool> _putBuyerPreferences() async {
    return _runApiCall(() async {
      await _buyersRepository.setPreferences(
        BuyerPreferencesRequest(
          dietaryTags: dietaryPreferences.toList(),
          allergens: allergies.toList(),
        ),
      );
    });
  }

  Future<bool> _putSellerProfile() async {
    final category = sellerCategory.value;
    final dob = dateOfBirth.value;
    if (category == null || dob == null) {
      submitError.value = 'Champs requis manquants';
      return false;
    }
    return _runApiCall(() async {
      await _sellersRepository.setProfile(
        SellerProfileRequest(
          category: category,
          displayName: displayName.value,
          bio: bio.value.isEmpty ? null : bio.value,
          profilePhotoUrl: profilePhotoUrl.value,
          dateOfBirth: _formatDob(dob),
          hygieneCommitment: hygieneCommitmentChecked.value,
          faitMaisonCommitment: faitMaisonCommitmentChecked.value,
        ),
      );
    });
  }

  Future<bool> _putSellerBusiness() async {
    return _runApiCall(() async {
      await _sellersRepository.setBusiness(
        SellerBusinessRequest(
          businessName: businessName.value,
          siret: siret.value.replaceAll(RegExp(r'\s'), ''),
          facadeUrl: restaurantFacadeUrl.value.isEmpty
              ? null
              : restaurantFacadeUrl.value,
          openingHours: _openingHoursFromUi(),
        ),
      );
    });
  }

  Future<bool> _putSellerCuisines() async {
    return _runApiCall(() async {
      await _sellersRepository.setCuisines(
        SellerCuisinesRequest(
          cuisines: cuisineTypes.toList(),
          dishTypes: dishTypes.toList(),
        ),
      );
    });
  }

  Future<bool> _submitKycIdSlots() async {
    final docType = idDocumentType.value;
    if (docType == null) {
      submitError.value = 'Champs requis manquants';
      return false;
    }
    return _runApiCall(() async {
      await _kycRepository.submitDocument(
        CreateKycDocumentRequest(
          type: KycDocumentType.idFront,
          fileUrl: idFrontUrl.value,
          idDocumentType: docType,
        ),
      );
      if (docType.requiresVerso) {
        await _kycRepository.submitDocument(
          CreateKycDocumentRequest(
            type: KycDocumentType.idBack,
            fileUrl: idBackUrl.value,
            idDocumentType: docType,
          ),
        );
      }
    });
  }

  Future<bool> _submitKycSelfie() async {
    return _runApiCall(() async {
      await _kycRepository.submitDocument(
        CreateKycDocumentRequest(
          type: KycDocumentType.selfie,
          fileUrl: selfieUrl.value,
        ),
      );
    });
  }

  Future<bool> _putDriverVehicle() async {
    final type = vehicleType.value;
    if (type == null) return false;
    final dob = dateOfBirth.value;
    return _runApiCall(() async {
      await _driversRepository.setVehicle(
        DriverVehicleRequest(
          vehicleType: type,
          dateOfBirth: dob == null ? null : _formatDob(dob),
        ),
      );
    });
  }

  Future<bool> _submitDriverDocuments() async {
    return _runApiCall(() async {
      await _kycRepository.submitDocument(
        CreateKycDocumentRequest(
          type: KycDocumentType.drivingLicense,
          fileUrl: drivingLicenseUrl.value,
        ),
      );
      await _kycRepository.submitDocument(
        CreateKycDocumentRequest(
          type: KycDocumentType.carteGrise,
          fileUrl: carteGriseUrl.value,
        ),
      );
    });
  }

  Future<bool> _putDriverZones() async {
    return _runApiCall(() async {
      await _driversRepository.setZones(
        DriverZonesRequest(zones: operatingZones.toList()),
      );
    });
  }

  Future<bool> _acceptSellerCharters() async {
    return _runApiCall(() async {
      final versions = await _ensureActiveCharters();
      // §4.3: HYGIENE is always required for sellers; FAIT_MAISON only
      // for fait-maison sellers. The wizard's UI collects both flags
      // regardless, so we post both when present — extra acceptances
      // don't hurt and keep us forward-compatible if the category
      // changes later.
      await _usersRepository.acceptCharter(AcceptCharterRequest(
        charter: Charter.hygiene,
        version: versions.versionFor(Charter.hygiene) ?? 'v1.0',
      ));
      if (sellerCategory.value == SellerCategory.faitMaison ||
          faitMaisonCommitmentChecked.value) {
        await _usersRepository.acceptCharter(AcceptCharterRequest(
          charter: Charter.faitMaison,
          version: versions.versionFor(Charter.faitMaison) ?? 'v1.0',
        ));
      }
    });
  }

  Future<bool> _acceptDriverCharters() async {
    return _runApiCall(() async {
      final versions = await _ensureActiveCharters();
      await _usersRepository.acceptCharter(AcceptCharterRequest(
        charter: Charter.punctuality,
        version: versions.versionFor(Charter.punctuality) ?? 'v1.0',
      ));
      await _usersRepository.acceptCharter(AcceptCharterRequest(
        charter: Charter.care,
        version: versions.versionFor(Charter.care) ?? 'v1.0',
      ));
    });
  }

  // ---------------------------------------------------------------------------
  // Shared gate plumbing.
  // ---------------------------------------------------------------------------

  /// Wraps a gate's API call(s) in the standard loading + error flow.
  /// Returns true on success, false on [ApiFailure] (with submitError set).
  Future<bool> _runApiCall(Future<void> Function() body) async {
    isLoading.value = true;
    try {
      await body();
      return true;
    } on ApiFailure catch (e) {
      submitError.value = e.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ActiveCharters> _ensureActiveCharters() async {
    return _activeCharters ??= await _chartersRepository.getActive();
  }

  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  UpsertAddressRequest _addressRequestFromUi(Address ui) {
    return UpsertAddressRequest(
      fullAddress: ui.fullAddress,
      city: ui.city,
      postalCode: ui.postalCode,
      type: _mapAddressType(ui.type),
      customLabel: ui.customLabel,
      apartment: ui.apartment,
      floor: ui.floor,
      digicode: ui.digicode,
      deliveryNotes: ui.deliveryNotes,
      lat: ui.coordinate?.lat,
      lng: ui.coordinate?.lng,
    );
  }

  AddressType? _mapAddressType(SavedAddressType? t) => switch (t) {
        SavedAddressType.home => AddressType.home,
        SavedAddressType.work => AddressType.work,
        SavedAddressType.other => AddressType.other,
        null => null,
      };

  List<OpeningHoursRow> _openingHoursFromUi() {
    return openingHours.entries
        .where((e) => e.value.start != e.value.end)
        .map((e) => OpeningHoursRow(
              dayOfWeek: e.key,
              startTime: _formatTime(e.value.start),
              endTime: _formatTime(e.value.end),
            ))
        .toList();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  Future<bool> _submitBasicInfoSignup() async {
    if (isSignedUp.value) return true; // idempotent: don't re-call /signup
    isLoading.value = true;
    try {
      await _authRepository.signup(
        SignupRequest(email: email.value, password: password.value),
      );
      isSignedUp.value = true;
      return true;
    } on ApiFailure catch (e) {
      submitError.value = e.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _submitCompleteProfile() async {
    final selectedRole = role.value;
    if (selectedRole == null) return false;
    isLoading.value = true;
    try {
      await _usersRepository.completeProfile(
        CompleteProfileRequest(
          firstName: firstName.value,
          lastName: lastName.value,
          role: selectedRole,
          acceptedCgu: acceptedCgu.value,
          acceptedCgv: acceptedCgv.value,
        ),
      );
      return true;
    } on ApiFailure catch (e) {
      submitError.value = e.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _finishSignup() {
    // Phase 4 will wire role-specific finalizers (KYC, business info,
    // vehicle, etc.) at each Continue press. For now, just navigate
    // to the role's home — the auth account + profile row are already
    // persisted from the two earlier gates.
    final dest = _homeForRole();
    if (dest != null) {
      Get.offAll<void>(() => dest);
    }
  }

  Widget? _homeForRole() {
    switch (role.value) {
      case UserRole.buyer:
        return const NavigationMenu(tabs: kClientNavTabs);
      case UserRole.seller:
        return const NavigationMenu(tabs: kSellerNavTabs);
      case UserRole.driver:
        return DeliveryHomeScreen();
      case null:
        return null;
    }
  }

  void previousPage() {
    if (currentPage.value == 0) return;
    final prev = currentPage.value - 1;
    currentPage.value = prev;
    if (pageController.hasClients) {
      pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    charterScrolledToBottom.value = false;
  }

  void onPageChanged(int page) => currentPage.value = page;

  void selectRole(UserRole r) {
    role.value = r;
    // Clear forward-looking state from a previously chosen role so
    // switching choices doesn't leak validation state into the new
    // branch of the page list.
    sellerCategory.value = null;
    vehicleType.value = null;
    // No auto-advance — the role selection page uses the bottom bar
    // Continue button as its navigation, mirroring the existing
    // UserTypeSelectionScreen pattern.
  }

  void selectVehicle(DriverVehicleType v) {
    // No auto-advance — the page shows the chosen vehicle's subtitle at
    // the bottom and the user commits via the bottom-bar Continue,
    // matching the role selection page's pattern.
    vehicleType.value = v;
  }

  // ---------------------------------------------------------------------------
  // OTP — backed by /v1/auth/phone/{request-otp,verify} (§3.8, §3.9).
  // ---------------------------------------------------------------------------

  /// French national 9-digit phone → E.164. The wizard's validator
  /// enforces 9 digits; we prepend `+33` here so we never send invalid
  /// formats to the backend (which rejects with 400).
  String get _phoneE164 =>
      '+33${phone.value.replaceAll(RegExp(r'\D'), '')}';

  Future<void> requestOtp() async {
    otpError.value = '';
    try {
      await _authRepository.requestPhoneOtp(
        RequestOtpRequest(phone: _phoneE164),
      );
      _startResendCountdown();
    } on ApiFailure catch (e) {
      otpError.value = e.message;
    }
  }

  void _startResendCountdown() {
    _otpTimer?.cancel();
    otpResendSecondsLeft.value = 30;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (otpResendSecondsLeft.value <= 1) {
        otpResendSecondsLeft.value = 0;
        t.cancel();
      } else {
        otpResendSecondsLeft.value--;
      }
    });
  }

  Future<void> verifyOtp(String code) async {
    if (code.length != 6) return;
    otpVerifying.value = true;
    otpError.value = '';
    try {
      // §3.9: the verify returns a fresh session with phoneConfirmedAt
      // populated. AuthRepository swaps the tokens in flutter_secure_storage
      // before returning, so subsequent requests carry the new bearer.
      await _authRepository.verifyPhoneOtp(
        VerifyOtpRequest(phone: _phoneE164, code: code),
      );
      phoneVerified.value = true;
      nextPage();
    } on ApiFailure catch (e) {
      phoneVerified.value = false;
      // 401 = wrong / expired code; show the wizard's localized copy.
      // Anything else: surface the backend message verbatim.
      otpError.value =
          e.statusCode == 401 ? AppTexts.signupOtpInvalid : e.message;
    } finally {
      otpVerifying.value = false;
    }
  }
}

/// Sample data used to prefill the basic-info form in debug builds so
/// the validation gate passes without manual typing on every hot reload.
class _DevSeed {
  _DevSeed({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  factory _DevSeed.empty() => _DevSeed(
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        password: '',
      );

  factory _DevSeed.random() {
    const firstNames = [
      'Camille', 'Hugo', 'Manon', 'Theo', 'Sarah',
      'Antoine', 'Marie', 'Lucas', 'Chloe', 'Nathan',
    ];
    const lastNames = [
      'Dupont', 'Martin', 'Bernard', 'Moreau', 'Dubois',
      'Laurent', 'Petit', 'Roux', 'David', 'Garnier',
    ];
    final rnd = Random();
    final first = firstNames[rnd.nextInt(firstNames.length)];
    final last = lastNames[rnd.nextInt(lastNames.length)];
    final phone = '6${List.generate(8, (_) => rnd.nextInt(10)).join()}';
    return _DevSeed(
      firstName: first,
      lastName: last,
      email: '${first.toLowerCase()}.${last.toLowerCase()}@exemple.fr',
      phone: phone,
      password: 'Secret123!',
    );
  }
}
