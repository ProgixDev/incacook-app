import 'package:incacook/features/authentication/data/models/user_role.dart';

/// Stable identifier for each step in the signup flow. The page-list order
/// is dynamic (depends on role / sub-type / vehicle), but a step's identity
/// does not — so validation can switch on the step rather than the index.
enum SignupStep {
  // Universal
  basicInfo,
  phoneVerification,
  biometricSetup,
  legalAcceptance,
  // NoProfile-only — collects (or confirms) the user's name when
  // basicInfo was skipped because we entered the wizard with a
  // pre-existing auth identity (e.g. first-time Google sign-in).
  // Pre-filled from the JWT's name claims when present.
  completeName,
  // Role
  roleSelection,
  // Buyer
  buyerAddress,
  buyerDietary,
  buyerDone,
  // Seller
  sellerProfile,
  sellerDobAddress,
  sellerBusinessInfo,
  sellerCuisine,
  sellerKycId,
  sellerKycSelfie,
  sellerCharter,
  // Driver
  driverDobAddress,
  driverVehicle,
  driverKycId,
  driverKycSelfie,
  driverDocuments,
  driverZone,
  driverCharter,
  // Driver-only — optional Stripe Connect payout setup so they can receive
  // their earnings. Last step in that flow; skippable (a dashboard banner
  // re-prompts later). Not a backend onboarding step. The seller
  // equivalent isn't a signup step at all — the seller subscription
  // (RevenueCat) is taken later via the SubscriptionGate paywall, and
  // payout setup is reached post-signup from Profil → Wallet.
  payoutSetup,
}

/// Maps `OnboardingState.next` (a backend step key like `kyc_id` or
/// `addresses`) to the local [SignupStep] enum that drives the wizard's
/// PageView. Used by the bootstrap splash when resuming a mid-signup
/// user. Returns `null` for keys this client doesn't recognize so the
/// caller can fall back to the first role-specific step.
///
/// Keys come from `docs/signup-flow.md` §4.3.
SignupStep? signupStepFromOnboardingKey(String key, UserRole role) {
  switch (role) {
    case UserRole.buyer:
      switch (key) {
        case 'addresses':
          return SignupStep.buyerAddress;
        case 'preferences':
          return SignupStep.buyerDietary;
      }
    case UserRole.seller:
      switch (key) {
        // The seller wizard pairs profile + DOB across two consecutive
        // screens. Server-side `profile` requires displayName + photo +
        // dob + category, so resuming at `profile` puts the user on the
        // first of the two; `addresses` puts them on the second since
        // it's where the pickup address PUT fires.
        case 'profile':
          return SignupStep.sellerProfile;
        case 'addresses':
          return SignupStep.sellerDobAddress;
        case 'business':
          return SignupStep.sellerBusinessInfo;
        case 'cuisines':
          return SignupStep.sellerCuisine;
        case 'kyc_id':
          return SignupStep.sellerKycId;
        case 'kyc_selfie':
          return SignupStep.sellerKycSelfie;
        case 'charter':
          return SignupStep.sellerCharter;
      }
    case UserRole.driver:
      switch (key) {
        case 'addresses':
          return SignupStep.driverDobAddress;
        case 'vehicle':
          return SignupStep.driverVehicle;
        case 'kyc_id':
          return SignupStep.driverKycId;
        case 'kyc_selfie':
          return SignupStep.driverKycSelfie;
        case 'documents':
          return SignupStep.driverDocuments;
        case 'zones':
          return SignupStep.driverZone;
        case 'charter':
          return SignupStep.driverCharter;
      }
  }
  return null;
}
