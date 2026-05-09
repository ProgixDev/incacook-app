import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/features/authentication/data/models/day_of_week.dart';
import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';
import 'package:incacook/features/authentication/data/models/id_document_type.dart';
import 'package:incacook/features/authentication/data/models/signup_step.dart';
import 'package:incacook/features/authentication/data/models/time_range.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/signup_repository.dart';
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

  SignupFlowController({SignupRepository? repository})
    : _repository = repository ?? Get.find<SignupRepository>();

  final SignupRepository _repository;

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
  final iban = ''.obs;
  final ibanHolderName = ''.obs;
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
          SignupStep.driverIban,
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

  bool get isIbanValid {
    final v = iban.value.replaceAll(RegExp(r'\s'), '').toUpperCase();
    // Lightweight format check; a strict ISO 13616 mod-97 lives in the API.
    return RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$').hasMatch(v);
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
      case SignupStep.driverIban:
        return isIbanValid && ibanHolderName.value.trim().length >= 2;
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
  void nextPage() {
    if (!canGoNext()) return;
    if (isLastPage) {
      // Last step (seller / driver charter, or the buyer dietary→done
      // transition) — submit and navigate straight to the role's home.
      // The pending-review screens were removed: sellers and drivers
      // now go to their respective home immediately after the charter.
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

  Future<void> _finishSignup() async {
    await submitSignup();
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
  // OTP — stub flow.
  // ---------------------------------------------------------------------------
  Future<void> requestOtp() async {
    otpError.value = '';
    await _repository.sendOtp(phone.value);
    _startResendCountdown();
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
      final ok = await _repository.verifyOtp(phone: phone.value, code: code);
      phoneVerified.value = ok;
      if (ok) {
        // Auto-advance.
        nextPage();
      } else {
        otpError.value = AppTexts.signupOtpInvalid;
      }
    } finally {
      otpVerifying.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Final submission — stub.
  // ---------------------------------------------------------------------------
  Future<void> submitSignup() async {
    isLoading.value = true;
    try {
      await _repository.submitSignup({
        'email': email.value,
        'phone': phone.value,
        'firstName': firstName.value,
        'lastName': lastName.value,
        'role': role.value?.name,
        'sellerCategory': sellerCategory.value?.name,
        'vehicleType': vehicleType.value?.name,
      });
    } finally {
      isLoading.value = false;
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
