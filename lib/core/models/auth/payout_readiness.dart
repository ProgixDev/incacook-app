import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/models/auth/seller_account.dart';

/// Where an earner (seller / driver) stands in Stripe Connect payout
/// onboarding. Derived from the split Stripe facts on `/users/me`
/// (`detailsSubmitted` + `payoutsEnabled`), with the legacy collapsed
/// boolean (`stripeOnboardingCompleted`) as a fallback for older servers.
enum PayoutSetupState {
  /// The earner never submitted their details to Stripe — show the
  /// "set up payments" CTA.
  notStarted,

  /// Details were submitted but Stripe hasn't enabled payouts (yet, or
  /// anymore — this also covers Stripe revoking payouts after a review).
  /// Show "verification in progress" copy, not the initial setup CTA.
  pendingVerification,

  /// Payouts are enabled — the earner can withdraw.
  ready,
}

/// Single derivation shared by [SellerAccount] and [DriverAccount] (freezed
/// models can't share an interface, so both extensions delegate here).
///
/// Readiness is `payoutsEnabled && detailsSubmitted`. `chargesEnabled` is
/// deliberately NOT part of the rule — it gates charging buyers, not paying
/// the earner out. When the split facts are absent (old server: both null),
/// fall back to the collapsed `stripeOnboardingCompleted` boolean, which the
/// backend keeps equal to `payoutsEnabled && detailsSubmitted`.
PayoutSetupState payoutSetupStateFrom({
  required bool? detailsSubmitted,
  required bool? payoutsEnabled,
  required bool stripeOnboardingCompleted,
}) {
  if (detailsSubmitted == null && payoutsEnabled == null) {
    // Old server: only the collapsed boolean exists. It can't distinguish
    // "never started" from "submitted, awaiting verification", so map its
    // false onto notStarted (the pre-DEC-4 behavior).
    return stripeOnboardingCompleted
        ? PayoutSetupState.ready
        : PayoutSetupState.notStarted;
  }
  if (detailsSubmitted != true) return PayoutSetupState.notStarted;
  return payoutsEnabled == true
      ? PayoutSetupState.ready
      : PayoutSetupState.pendingVerification;
}

extension SellerPayoutReadiness on SellerAccount {
  /// Three-state payout onboarding progress. See [payoutSetupStateFrom].
  PayoutSetupState get payoutSetupState => payoutSetupStateFrom(
    detailsSubmitted: detailsSubmitted,
    payoutsEnabled: payoutsEnabled,
    stripeOnboardingCompleted: stripeOnboardingCompleted,
  );

  /// True when the seller can receive payouts (withdrawals unlocked).
  bool get isPayoutReady => payoutSetupState == PayoutSetupState.ready;
}

extension DriverPayoutReadiness on DriverAccount {
  /// Three-state payout onboarding progress. See [payoutSetupStateFrom].
  PayoutSetupState get payoutSetupState => payoutSetupStateFrom(
    detailsSubmitted: detailsSubmitted,
    payoutsEnabled: payoutsEnabled,
    stripeOnboardingCompleted: stripeOnboardingCompleted,
  );

  /// True when the driver can receive payouts (withdrawals unlocked).
  bool get isPayoutReady => payoutSetupState == PayoutSetupState.ready;
}
