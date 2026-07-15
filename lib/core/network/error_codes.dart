/// Stable error codes returned by the IncaCook backend.
///
/// Branch on [ApiFailure.code] using these constants — never on the
/// human-readable `message`, which may change. Keep in sync with
/// `docs/error-codes.md` on the backend.
class IncaCookErrorCodes {
  IncaCookErrorCodes._();

  // Generic.
  static const String unknown = 'INCACOOK_UNKNOWN';
  static const String transport = 'INCACOOK_TRANSPORT';
  static const String validation = 'INCACOOK_VALIDATION';
  static const String conflict = 'INCACOOK_CONFLICT';
  static const String notFound = 'INCACOOK_NOT_FOUND';
  static const String forbidden = 'INCACOOK_FORBIDDEN';
  static const String unauthorized = 'INCACOOK_UNAUTHORIZED';
  static const String rateLimited = 'INCACOOK_RATE_LIMITED';
  static const String server = 'INCACOOK_SERVER_ERROR';

  // Auth.
  static const String authInvalidCredentials = 'INCACOOK_AUTH_INVALID_CREDENTIALS';
  static const String authEmailTaken = 'INCACOOK_AUTH_EMAIL_TAKEN';
  static const String authWeakPassword = 'INCACOOK_AUTH_WEAK_PASSWORD';
  static const String authRefreshFailed = 'INCACOOK_AUTH_REFRESH_FAILED';

  // Users / profile.
  static const String userProfileAlreadyComplete = 'INCACOOK_USER_PROFILE_ALREADY_COMPLETE';

  // Drivers.
  /// No driver holds the order's delivery yet. Returned when a driver-directed
  /// action (opening the seller↔driver or buyer↔driver chat) runs before the
  /// claim — an order sits READY with no driver until dispatch finds one.
  static const String noDriverAvailable = 'INCACOOK_NO_DRIVER_AVAILABLE';
}
