import 'package:get_storage/get_storage.dart';

/// Local, non-sensitive UX flag: did the user opt into biometric unlock during
/// signup (or settings)? The actual secret — the session token — stays in
/// `TokenStorage` (Keychain / EncryptedSharedPreferences). This flag only gates
/// whether the "Connexion biométrique" button is OFFERED; it never grants
/// access on its own.
class BiometricPreference {
  BiometricPreference._();

  static const String _key = 'biometric_enabled';

  static GetStorage get _box => GetStorage();

  static bool get isEnabled => _box.read<bool>(_key) ?? false;

  static Future<void> setEnabled(bool value) => _box.write(_key, value);
}
