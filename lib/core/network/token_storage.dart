import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Secure storage for the auth tokens.
///
/// Tokens MUST never live in `SharedPreferences` / `GetStorage` — those
/// are world-readable on rooted / jailbroken devices. `FlutterSecureStorage`
/// maps to Keychain on iOS and EncryptedSharedPreferences on Android.
class TokenStorage extends GetxService {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

  static TokenStorage get instance => Get.find();

  static const _kAccessToken = 'incacook.access_token';
  static const _kRefreshToken = 'incacook.refresh_token';
  static const _kExpiresAt = 'incacook.expires_at';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<int?> readExpiresAt() async {
    final raw = await _storage.read(key: _kExpiresAt);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kExpiresAt, value: expiresAt.toString()),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kExpiresAt),
    ]);
  }

  Future<bool> hasSession() async {
    final access = await readAccessToken();
    return access != null && access.isNotEmpty;
  }
}
