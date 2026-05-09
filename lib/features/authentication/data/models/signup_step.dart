/// Stable identifier for each step in the signup flow. The page-list order
/// is dynamic (depends on role / sub-type / vehicle), but a step's identity
/// does not — so validation can switch on the step rather than the index.
enum SignupStep {
  // Universal
  basicInfo,
  phoneVerification,
  biometricSetup,
  legalAcceptance,
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
}
