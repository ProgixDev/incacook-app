import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/config/feature_flags.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
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
import 'package:incacook/core/utils/log.dart';

/// Drives the entire IncaCook multi-step signup flow.
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
  ///
  /// This flips mid-flow on the fresh-signup path, so it must NOT drive
  /// the [steps] preamble — use [startedSignedUp] for that. See its doc.
  final isSignedUp = false.obs;

  /// True when the wizard was *entered* already holding a session but
  /// without a committed `User` row — the `PostAuthNoProfile` / resume
  /// paths. Set once by [seedAsSignedIn] / [seedForResume] before the
  /// first build, and never again.
  ///
  /// [steps] keys the preamble on this (not [isSignedUp]) so the page
  /// list stays stable across the basicInfo signup gate. Using
  /// [isSignedUp] there collapsed the list the instant signup succeeded
  /// — dropping `basicInfo` from index 0 while `nextPage` advanced by
  /// `currentPage + 1`, which silently skipped the phone/email
  /// verification step.
  final startedSignedUp = false.obs;

  /// When `true`, [steps] omits the universal preamble (basicInfo through
  /// roleSelection). Set by [seedForResume] for users who abandoned the
  /// wizard after Gate 2 — those rows are already committed server-side
  /// and replaying them would 409 or overwrite. See `docs/signup-flow.md`
  /// §4.5 for the cold-start resume contract.
  final isResumeMode = false.obs;

  // ---------------------------------------------------------------------------
  // Step 0 — universal info
  // ---------------------------------------------------------------------------
  final email = ''.obs;
  final phone = ''.obs;
  // Selected country dial code for the phone field — defaults to France, but
  // the country selector updates it so non-FR numbers (e.g. Algeria +213)
  // compose the right E.164. The `phone` field holds the national number only.
  final dialCode = '+33'.obs;
  final countryFlag = '🇫🇷'.obs;
  final countryIso = 'FR'.obs;
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
  // True once Gate 2 (`POST /v1/users`) has committed the User row. From that
  // point the wizard is forward-only (re-running Gate 2 would 409). Replaces
  // the old OTP-success lock now that phone verification can be skipped.
  final profileCommitted = false.obs;
  final emailVerified = false.obs;
  final biometricEnabled = false.obs;
  final acceptedCgu = false.obs;
  final acceptedCgv = false.obs;

  // OTP & resend countdown.
  final otpCode = ''.obs;
  final otpResendSecondsLeft = 0.obs;
  final otpVerifying = false.obs;
  final otpError = ''.obs;
  // True once a code has been requested for the current destination — drives
  // the phone-verification page's two-phase UI (collect number → enter code).
  // The email/password path arrives here with a number already captured on
  // basicInfo, so the page flips this straight away; the Google/NoProfile path
  // (basicInfo skipped) leaves it false until the user types a number and taps
  // "Envoyer le code".
  final otpRequested = false.obs;
  // True when the backend reports the phone is already linked to another
  // account (`INCACOOK_PHONE_ALREADY_USED` / 409). While set: the red error
  // stays, the success snackbar is suppressed, and "Renvoyer le code" is
  // disabled in favour of a "Changer de numéro" action. Reset when the user
  // edits the number (see the phone listener and [editPhoneNumber]).
  final phoneAlreadyUsed = false.obs;
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

  // Profile avatar for buyer + driver (optional). Sellers use
  // [profilePhotoUrl], which goes to the seller profile; buyer/driver
  // avatars persist to the User row via PATCH /v1/users/me. Holds the
  // storage object key from the upload flow; empty = no photo picked.
  final avatarPath = ''.obs;

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
  // `late final` so [seedForResume] gets to write [currentPage] before
  // the PageController materializes — that way the PageView opens
  // directly on the resumed step instead of animating through page 0.
  late final PageController pageController = PageController(
    initialPage: currentPage.value,
  );

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

    // Text controllers are initialized from the current Rx values only.
    // Resume/social-auth paths may pre-seed real values before onInit; fresh
    // email/password signups stay blank in every build mode.

    firstNameTextController = TextEditingController(text: firstName.value)
      ..addListener(() => firstName.value = firstNameTextController.text);
    lastNameTextController = TextEditingController(text: lastName.value)
      ..addListener(() => lastName.value = lastNameTextController.text);
    emailTextController = TextEditingController(text: email.value)
      ..addListener(() => email.value = emailTextController.text.trim());
    phoneTextController = TextEditingController(text: phone.value)
      ..addListener(() {
        phone.value = phoneTextController.text;
        // Editing the number clears a previous "already used" rejection so the
        // user can request a code for the new number.
        if (phoneAlreadyUsed.value) {
          phoneAlreadyUsed.value = false;
          otpError.value = '';
        }
      });
    passwordTextController = TextEditingController(text: password.value)
      ..addListener(() => password.value = passwordTextController.text);
    confirmPasswordTextController =
        TextEditingController(text: confirmPassword.value)..addListener(
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
    final list = <SignupStep>[];
    // Universal preamble. Skipped when resuming a mid-signup user since
    // those rows (auth.users, User, charters) are already committed.
    // When [startedSignedUp] is true (PostAuthNoProfile case — auth row
    // exists but Gate 2 was never reached), basicInfo is dropped so the
    // user doesn't re-enter Gate 1 data, but OTP/biometric/legal/role
    // remain because Gate 2 still needs them.
    //
    // Keyed on [startedSignedUp], NOT the live [isSignedUp]: the latter
    // flips during the fresh-signup basicInfo gate, which would collapse
    // this list mid-`nextPage` and skip phoneVerification.
    if (!isResumeMode.value) {
      if (!startedSignedUp.value) {
        list.add(SignupStep.basicInfo);
      }
      // Phone verification is skipped when [FeatureFlags.skipPhoneVerification]
      // is on — the number is collected on basicInfo and saved unverified via
      // Gate 2, with no SMS / OTP step.
      if (!FeatureFlags.skipPhoneVerification) {
        list.add(SignupStep.phoneVerification);
      }
      list.addAll([SignupStep.biometricSetup, SignupStep.legalAcceptance]);
      // NoProfile path: basicInfo was skipped so the wizard hasn't
      // seen a name yet. The JWT pre-fill may be incomplete (single-
      // word Google accounts don't ship `family_name`), so we always
      // confirm before Gate 2 fires.
      if (startedSignedUp.value) {
        list.add(SignupStep.completeName);
      }
      list.add(SignupStep.roleSelection);
    }

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
        // Category is picked on the seller-profile page; null defaults to
        // fait-maison (see [_putSellerProfile]). For fait-maison — explicit
        // or defaulted — both `business` and the two KYC steps are skipped
        // server-side (§4.3), and the upload endpoint hard-rejects KYC
        // purposes with 403 "Fait-maison sellers do not submit KYC". Mirror
        // that here so the wizard never asks for documents it can't upload.
        if (_isFaitMaisonSeller) {
          list.add(SignupStep.sellerCuisine);
        } else {
          list.add(SignupStep.sellerBusinessInfo);
          list.add(SignupStep.sellerCuisine);
          list.add(SignupStep.sellerKycId);
          list.add(SignupStep.sellerKycSelfie);
        }
        list.add(SignupStep.sellerCharter);
        // The seller subscription is intentionally NOT a signup step. The seller
        // finishes onboarding here and lands on the seller area; the monthly
        // subscription is taken later via the [SubscriptionGate] paywall (same
        // RevenueCat flow) the first time they open a gated tab
        // (Accueil / Commandes / Catalogue). This shortens signup and lets them
        // reach their account without paying up front.
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
          // Optional payout setup (Stripe Connect) — last, skippable.
          SignupStep.payoutSetup,
        ]);
      case null:
        break;
    }
    return list;
  }

  /// True when the seller is — or defaults to — fait-maison. Keep this
  /// in sync with [_putSellerProfile]'s null-default: the steps list,
  /// the upload gate, and the server's KYC bypass all key off it.
  bool get _isFaitMaisonSeller {
    final c = sellerCategory.value;
    return c == null || c == SellerCategory.faitMaison;
  }

  int get totalPages => steps.length;

  /// Safely returns the current step, or throws a clear error if steps is empty.
  /// This guards against initialization timing edge cases where [steps] might
  /// temporarily be empty before [role] or [isResumeMode] are set.
  SignupStep get currentStep {
    final list = steps;
    if (list.isEmpty) {
      throw StateError(
        'SignupStep list is empty — ensure role is set before accessing currentStep. '
        'This can happen during initialization if roleSelection hasn\'t completed.',
      );
    }
    return list[currentPage.value.clamp(0, list.length - 1)];
  }

  bool get isFirstPage => currentPage.value == 0;

  bool get isLastPage => currentPage.value >= steps.length - 1;

  /// True when the user can navigate back from the current step.
  ///
  /// Locked once the OTP step succeeds. After that every earlier gate
  /// has already committed something server-side and going back to the
  /// OTP page would re-trigger a new code send — so the wizard becomes
  /// strictly forward-only. The shell uses this to hide the appbar's
  /// back arrow; the PopScope intercepts the system back gesture too.
  bool get canGoBack => !phoneVerified.value && !profileCommitted.value;

  // ---------------------------------------------------------------------------
  // Validators (the per-step rules the bottom-bar checks).
  // ---------------------------------------------------------------------------
  bool get isEmailValid {
    final v = email.value;
    if (v.isEmpty) return false;
    // `+` allows sub-addressing (e.g. qa+driver-paris@incacook.fr).
    return RegExp(r'^[\w+\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v);
  }

  bool get isPhoneValid {
    if (phone.value.trim().isEmpty) return false;
    // Validate the fully-composed E.164 (selected dial code + national number)
    // against the backend's `^\+[1-9]\d{6,14}$` rule — works for any country.
    return RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(_phoneE164);
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

  /// True when the phone field can be left blank. During the
  /// [FeatureFlags.useEmailOtpBypass] window we keep the field visible
  /// but don't gate Continue on it — the OTP is sent to the user's
  /// email instead and no phone number is captured server-side.
  bool get _isPhoneOptional => FeatureFlags.useEmailOtpBypass;

  bool get isBasicInfoComplete =>
      isEmailValid &&
      (_isPhoneOptional || isPhoneValid) &&
      isPasswordValid &&
      isPasswordConfirmed &&
      _isValidName(firstName.value) &&
      _isValidName(lastName.value);

  bool get isAdult {
    final dob = dateOfBirth.value;
    if (dob == null) return false;
    final now = DateTime.now();
    final age =
        now.year -
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
      case SignupStep.completeName:
        return _isValidName(firstName.value) && _isValidName(lastName.value);
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
        // SIRET is optional at this gate for every category: an empty value
        // never blocks Continue. When filled, it must be a valid 14-digit Luhn
        // SIRET. Sauve Ton Panier's "required" rule is enforced at submit (see
        // [_putSellerBusiness]) so the message only appears on submit — never
        // for Traiteur / fait-maison.
        final base =
            businessName.value.trim().length >= 2 &&
            (siret.value.trim().isEmpty || isSiretValid);
        if (sellerCategory.value == SellerCategory.restaurant) {
          return base &&
              restaurantFacadeUrl.value.isNotEmpty &&
              openingHours.values.any((range) => range.start != range.end);
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
        return driverPunctualityCommitment.value && driverCareCommitment.value;
      case SignupStep.payoutSetup:
        // Optional — payout onboarding can always be skipped (the
        // dashboard banner re-prompts later), so Continue is enabled.
        return true;
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
    logInfo(
      '[NAV] nextPage ENTER step=${currentStep.name} '
      'currentPage=${currentPage.value} steps=${steps.map((s) => s.name).toList()} '
      'len=${steps.length} isLastPage=$isLastPage '
      'pageCtrl.hasClients=${pageController.hasClients} '
      'pageCtrl.page=${pageController.hasClients ? pageController.page : null}',
    );
    if (!canGoNext()) {
      logInfo('[NAV] nextPage BLOCKED canGoNext=false');
      return;
    }
    if (isLoading.value) {
      logError('[NAV] nextPage BLOCKED isLoading=true');
      return;
    }

    // Step-gated network calls. Each gate has to succeed before the page
    // advances; on failure, `submitError` is set and the bottom bar
    // re-enables for retry.
    submitError.value = '';
    final gateOk = await _runGateForCurrentStep();
    logInfo('[NAV] gateOk=$gateOk');
    if (!gateOk) return;

    // The page is going to change — drop focus so a keyboard left open on a
    // text step (e.g. phone/password on basic info) doesn't carry over into
    // the next step. Only do this once the gate has passed, so a failed gate
    // keeps the field focused for retry.
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLastPage) {
      logInfo('[NAV] -> _finishSignup (isLastPage)');
      _finishSignup();
      return;
    }
    final next = currentPage.value + 1;
    currentPage.value = next;
    logInfo(
      '[NAV] advancing to page=$next '
      'hasClients=${pageController.hasClients}',
    );
    if (pageController.hasClients) {
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Reset per-page transient state.
    charterScrolledToBottom.value = false;
    logSuccess(
      '[NAV] nextPage DONE currentPage=${currentPage.value} '
      'pageCtrl.page=${pageController.hasClients ? pageController.page : null}',
    );
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
      case SignupStep.completeName:
        // Names are sent as part of Gate 2's body on roleSelection —
        // this step just collects/confirms them.
        return true;
      case SignupStep.roleSelection:
        return _submitCompleteProfile();

      // Buyer
      case SignupStep.buyerAddress:
        if (!await _putAddress(AddressKind.buyerDelivery)) return false;
        return _persistAvatarIfAny();
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
        if (!await _putAddress(AddressKind.driverHome)) return false;
        return _persistAvatarIfAny();
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

      // Payout onboarding is launched from the page button (Stripe Connect),
      // not a gate; nothing to commit here.
      case SignupStep.payoutSetup:
        return true;
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

  /// Persists the optional buyer/driver profile avatar to the User row
  /// via PATCH /v1/users/me. No-op when the user didn't pick a photo, so
  /// the avatar stays optional and never blocks the gate. Refreshes the
  /// global user cache so the role home shows it immediately.
  Future<bool> _persistAvatarIfAny() async {
    if (avatarPath.value.isEmpty) return true;
    return _runApiCall(() async {
      final updated = await _usersRepository.updateMe(
        avatarPath: avatarPath.value,
      );
      if (Get.isRegistered<UserController>()) {
        UserController.instance.setUser(updated);
      }
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
    // Resume path: when the wizard jumps straight to sellerDobAddress
    // (OnboardingState.next == 'addresses'), the profile step is already
    // `complete` server-side but the local form was never rehydrated, so
    // [displayName] / [profilePhotoUrl] are blank. Re-PUTting them as empty
    // strings trips the backend's @MinLength(1) on /sellers/me/profile (400).
    // A fresh flow can't reach this step with blanks — the sellerProfile gate
    // requires both before advancing — so blank here unambiguously means the
    // profile is already persisted; skip the re-PUT and let the address gate
    // run.
    if (displayName.value.trim().isEmpty || profilePhotoUrl.value.isEmpty) {
      return true;
    }
    final dob = dateOfBirth.value;
    if (dob == null) {
      submitError.value = 'Champs requis manquants';
      return false;
    }
    // Category is chosen on the seller-profile page (the 3-way subtype
    // picker). Untouched defaults to FAIT_MAISON. TRAITEUR / RESTAURANT
    // activate the business-info + KYC steps in [steps] so the onboarding
    // endpoint's `business` / `kyc` gates get satisfied.
    final category = sellerCategory.value ?? SellerCategory.faitMaison;
    return _runApiCall(() async {
      await _sellersRepository.setProfile(
        SellerProfileRequest(
          category: category,
          displayName: displayName.value,
          bio: bio.value.isEmpty ? null : bio.value,
          profilePhotoUrl: profilePhotoUrl.value,
          dateOfBirth: _formatDob(dob),
          // Fixed €2.50 (250 cents) platform delivery fee for all categories
          // per the client spec — not seller-editable for now. Sending it
          // here is what lets the seller pass OrdersService's
          // `deliveryFeeCents !== null` gate. The backend also defaults it.
          deliveryFeeCents: 250,
          hygieneCommitment: hygieneCommitmentChecked.value,
          faitMaisonCommitment: faitMaisonCommitmentChecked.value,
        ),
      );
    });
  }

  Future<bool> _putSellerBusiness() async {
    final cleanedSiret = siret.value.replaceAll(RegExp(r'\s'), '').trim();
    // Sauve Ton Panier (restaurant) is the only category that requires a SIRET.
    // Surface the message ONLY here (at submit) and ONLY when empty — Traiteur /
    // fait-maison are never blocked by an empty SIRET.
    if (sellerCategory.value == SellerCategory.restaurant &&
        cleanedSiret.isEmpty) {
      submitError.value = AppTexts.signupSellerSiretRequiredSubmit;
      return false;
    }
    return _runApiCall(() async {
      await _sellersRepository.setBusiness(
        SellerBusinessRequest(
          businessName: businessName.value,
          // Send null (not '') when empty — the backend treats absent SIRET as
          // optional for Traiteur; an empty string would fail format validation.
          siret: cleanedSiret.isEmpty ? null : cleanedSiret,
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
      await _usersRepository.acceptCharter(
        AcceptCharterRequest(
          charter: Charter.hygiene,
          version: versions.versionFor(Charter.hygiene) ?? 'v1.0',
        ),
      );
      if (sellerCategory.value == SellerCategory.faitMaison ||
          faitMaisonCommitmentChecked.value) {
        await _usersRepository.acceptCharter(
          AcceptCharterRequest(
            charter: Charter.faitMaison,
            version: versions.versionFor(Charter.faitMaison) ?? 'v1.0',
          ),
        );
      }
    });
  }

  Future<bool> _acceptDriverCharters() async {
    return _runApiCall(() async {
      final versions = await _ensureActiveCharters();
      await _usersRepository.acceptCharter(
        AcceptCharterRequest(
          charter: Charter.punctuality,
          version: versions.versionFor(Charter.punctuality) ?? 'v1.0',
        ),
      );
      await _usersRepository.acceptCharter(
        AcceptCharterRequest(
          charter: Charter.care,
          version: versions.versionFor(Charter.care) ?? 'v1.0',
        ),
      );
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
        .map(
          (e) => OpeningHoursRow(
            dayOfWeek: e.key,
            startTime: _formatTime(e.value.start),
            endTime: _formatTime(e.value.end),
          ),
        )
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
      final created = await _usersRepository.completeProfile(
        CompleteProfileRequest(
          firstName: firstName.value,
          lastName: lastName.value,
          role: selectedRole,
          acceptedCgu: acceptedCgu.value,
          acceptedCgv: acceptedCgv.value,
          // Phone collected on basicInfo, saved unverified (SMS OTP skipped).
          // Null for paths that never collected one (e.g. OAuth no-profile).
          phone: phone.value.trim().isEmpty ? null : _phoneE164,
        ),
      );
      // Warm the global user cache so the wizard's exit-to-home doesn't
      // briefly render placeholder name/email on the settings card.
      if (Get.isRegistered<UserController>()) {
        UserController.instance.setUser(created);
      }
      // Lock back-navigation: the User row now exists (forward-only).
      profileCommitted.value = true;
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

  /// Marks the wizard as "already has a session, but no User row yet" —
  /// the [PostAuthNoProfile] case from the post-auth router. Drops
  /// basicInfo from [steps] so the user lands on phoneVerification and
  /// advances through the rest of the preamble before Gate 2 commits.
  ///
  /// Also pre-fills name fields from the OAuth provider's JWT claims
  /// (populated in [UserController.authFirstName] / `authLastName` by
  /// `AuthRepository._persistSession`). Without this, a first-time
  /// Google user reaches role selection with empty first/last name
  /// and POST `/v1/users` returns 400 from the length-≥2 validators.
  void seedAsSignedIn() {
    isSignedUp.value = true;
    startedSignedUp.value = true;
    if (Get.isRegistered<UserController>()) {
      final uc = UserController.instance;
      final first = uc.authFirstName.value;
      final last = uc.authLastName.value;
      if (first != null && first.isNotEmpty) firstName.value = first;
      if (last != null && last.isNotEmpty) lastName.value = last;
    }
  }

  /// Seeds the wizard with a known role + jumps to a specific step,
  /// hiding the universal preamble. Called by the bootstrap splash when
  /// a stored session points at a half-completed signup.
  ///
  /// [startAt] is the [SignupStep] mapped from `OnboardingState.next`
  /// via [signupStepFromOnboardingKey]. If the key is unknown (e.g.
  /// server added a new step the client doesn't recognize yet), pass
  /// `null` — the wizard will land on the first role-specific step and
  /// the user can navigate from there.
  ///
  /// [sellerCategory] / [vehicleType] feed the [steps] getter's
  /// branching so business-info (sellers) and vehicle-docs (drivers)
  /// only appear when they actually apply.
  void seedForResume({
    required UserRole role,
    SignupStep? startAt,
    SellerCategory? sellerCategory,
    DriverVehicleType? vehicleType,
  }) {
    this.role.value = role;
    this.sellerCategory.value = sellerCategory;
    this.vehicleType.value = vehicleType;
    isSignedUp.value = true;
    startedSignedUp.value = true;
    // The universal preamble was committed in the previous session.
    // Mirror those flags so the gates in this controller don't re-fire.
    acceptedCgu.value = true;
    acceptedCgv.value = true;
    phoneVerified.value = true;
    isResumeMode.value = true;

    final filtered = steps;
    if (filtered.isEmpty) return;
    var idx = 0;
    if (startAt != null) {
      final found = filtered.indexOf(startAt);
      if (found >= 0) idx = found;
    }
    currentPage.value = idx;
    // PageController isn't attached until the PageView renders, so jump
    // on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(idx);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // OTP — backed by /v1/auth/phone/{request-otp,verify} (§3.8, §3.9).
  // ---------------------------------------------------------------------------

  /// Normalises the typed phone to E.164. A leading `+` is treated as a full
  /// international number typed verbatim; otherwise the selected [dialCode] is
  /// prepended to the national number, dropping a single national trunk `0`
  /// (FR/DZ and most of Europe) when present.
  String get _phoneE164 {
    final raw = phone.value.trim();
    if (raw.startsWith('+')) {
      return '+${raw.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }
    var national = raw.replaceAll(RegExp(r'\D'), '');
    if (national.startsWith('0')) national = national.substring(1);
    return '${dialCode.value}$national';
  }

  /// Updates the active country for the phone field (from the country picker).
  void setCountry({
    required String dialCode,
    required String flagEmoji,
    required String isoCode,
  }) {
    this.dialCode.value = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    countryFlag.value = flagEmoji;
    countryIso.value = isoCode;
  }

  /// Whether a code can be sent yet: the email bypass needs no number, but the
  /// SMS path requires a valid phone. The phone-verification page uses this to
  /// decide whether to auto-send on open or first collect the number inline.
  bool get canRequestOtp => FeatureFlags.useEmailOtpBypass || isPhoneValid;

  /// Requests (or resends) the verification code. Returns `true` only when the
  /// backend confirmed the send — callers use this to gate the "Code renvoyé"
  /// success message so it never appears before the API actually succeeds.
  ///
  /// Send and resend share this one path so error handling can't diverge (a
  /// resend used to always claim success). A phone already linked to another
  /// account (`INCACOOK_PHONE_ALREADY_USED` / 409) flips [phoneAlreadyUsed]
  /// and keeps the red error instead of pretending the code was sent.
  Future<bool> requestOtp() async {
    otpError.value = '';
    // Guard the SMS path against firing with no/blank number (the Google
    // NoProfile path lands here without one — would POST `{phone: +33}`).
    if (!canRequestOtp) {
      otpError.value = AppTexts.signupPhoneError;
      return false;
    }
    try {
      if (FeatureFlags.useEmailOtpBypass) {
        // §3.9 *Temporary email-OTP bypass* — destination is the
        // caller's own email (resolved from the JWT), no body needed.
        await _authRepository.requestEmailOtp();
      } else {
        await _authRepository.requestPhoneOtp(
          RequestOtpRequest(phone: _phoneE164),
        );
      }
      phoneAlreadyUsed.value = false;
      otpRequested.value = true;
      _startResendCountdown();
      logError('[PhoneOtp] resend success');
      return true;
    } on ApiFailure catch (e) {
      if (_isPhoneAlreadyUsed(e)) {
        phoneAlreadyUsed.value = true;
        otpError.value = AppTexts.signupOtpPhoneAlreadyUsed;
        logError('[PhoneOtp] resend blocked: phone already used');
      } else {
        otpError.value = e.message;
      }
      return false;
    }
  }

  /// Whether [e] is the backend's "phone already linked to another account"
  /// rejection — matched by the machine code (preferred) or the 409 status.
  bool _isPhoneAlreadyUsed(ApiFailure e) =>
      e.code == 'INCACOOK_PHONE_ALREADY_USED' || e.statusCode == 409;

  /// Returns the phone-verification page to its number-entry phase so the user
  /// can correct the number before a code is (re)sent. Drives the "Modifier le
  /// numéro" action on the OTP page for the Google/NoProfile path, where the
  /// number is entered inline rather than on a previous step.
  void editPhoneNumber() {
    _otpTimer?.cancel();
    otpResendSecondsLeft.value = 0;
    otpError.value = '';
    otpRequested.value = false;
    phoneAlreadyUsed.value = false;
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
      // §3.9: both the phone-verify and email-verify variants return a
      // fresh session with `phoneVerified` flipped server-side.
      // AuthRepository swaps the tokens in flutter_secure_storage before
      // returning, so subsequent requests carry the new bearer.
      if (FeatureFlags.useEmailOtpBypass) {
        await _authRepository.verifyEmailOtp(code: code);
      } else {
        await _authRepository.verifyPhoneOtp(
          VerifyOtpRequest(phone: _phoneE164, code: code),
        );
      }
      phoneVerified.value = true;
      nextPage();
    } on ApiFailure catch (e) {
      phoneVerified.value = false;
      // 401 = wrong / expired code; show the wizard's localized copy.
      // Anything else: surface the backend message verbatim.
      otpError.value = e.statusCode == 401
          ? AppTexts.signupOtpInvalid
          : e.message;
    } finally {
      otpVerifying.value = false;
    }
  }
}
