/// Compile-time feature flags.
///
/// Flip a flag here, rebuild, behaviour changes. Each entry should also
/// link the doc that explains why it exists, so future-you knows when
/// it's safe to remove.
class FeatureFlags {
  FeatureFlags._();

  /// While the SMS provider is unavailable, the wizard's phone-verification
  /// step uses an email OTP instead. See
  /// [`docs/signup-flow.md` §3.9 — Temporary email-OTP bypass](../../docs/signup-flow.md).
  ///
  /// When `true`:
  /// - basic-info screen treats the phone field as optional (still shown
  ///   so the user can type it; just not required to advance);
  /// - the OTP step calls `POST /v1/auth/email/{request-otp,verify}`
  ///   instead of the phone variants — destination is the caller's email;
  /// - phone copy on the OTP page is swapped for email copy.
  ///
  /// Flip back to `false` once SMS is restored. The phone-OTP code paths
  /// in [AuthRepository] and [SignupFlowController] are intentionally kept
  /// intact so the revert is one line.
  ///
  /// `false` — SMS phone OTP is live via Prelude Verify (server-side). The
  /// phone field is required and the OTP step calls
  /// `POST /v1/auth/phone/{request-otp,verify}`.
  static const bool useEmailOtpBypass = false;

  /// Skip phone verification entirely: no SMS, no 6-digit code. The number is
  /// still collected on the basic-info screen (required + format-validated)
  /// and saved on the User row **unverified** (`phoneVerified = false`) via
  /// Gate 2's body — Prelude is never called.
  ///
  /// When `true`:
  /// - the wizard's `phoneVerification` step is dropped from the flow;
  /// - `POST /v1/users` (Gate 2) carries the typed `phone`, which the backend
  ///   stores unverified when Supabase auth has no confirmed phone.
  ///
  /// The phone-OTP code paths (Prelude, `requestOtp`/`verifyOtp`, the OTP
  /// page) are intentionally left intact so flipping this back to `false`
  /// restores SMS verification in one line. Mutually independent from
  /// [useEmailOtpBypass] (don't enable both).
  static const bool skipPhoneVerification = true;

  /// Hide Facebook sign-in button while Meta/Facebook app configuration is
  /// being resolved or if access to the Meta account is unavailable.
  ///
  /// When `true`:
  /// - Facebook social pill is hidden on Welcome/Login screens
  /// - Only Google and email sign-in remain available
  ///
  /// Set back to `false` once Facebook App is in Live mode with correct
  /// redirect URLs configured.
  static const bool hideFacebookSignIn = true;
}
