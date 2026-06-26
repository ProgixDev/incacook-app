import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around OS-level biometric authentication (Face ID / Touch ID /
/// fingerprint) via `local_auth`.
///
/// This is the ONLY biometric/login mechanism: it never opens the camera and
/// never compares face images. The signup camera "Vérification du visage"
/// (KYC selfie) is a completely separate identity check and is never used to
/// log a user in.
///
/// SECURITY: never logs biometric data, the platform error message, or the
/// authentication result details.
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// True only when the device has biometrics enrolled AND the OS can run a
  /// biometric check. Swallows platform errors (returns false).
  Future<bool> isSupported() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the OS biometric sheet. Returns true only on a successful match.
  /// `biometricOnly` blocks the device-PIN fallback so this stays a genuine
  /// biometric gate. Any failure/cancellation returns false — never throws and
  /// never logs the platform reason (which can carry device biometric details).
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
