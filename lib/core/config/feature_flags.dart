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
}
