/// Backend API configuration.
///
/// `baseUrl` is read at build time from `--dart-define=API_BASE_URL=...`.
/// Defaults:
///   - iOS simulator         : http://127.0.0.1:3000
///   - Android emulator      : http://10.0.2.2:3000 (override via --dart-define)
///   - Physical device on Wi-Fi: `http://<your-LAN-IP>:3000` (override)
///   - Staging / Prod        : inject via --dart-define
///
/// All routes are prefixed with `/v1/`.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static const String apiPrefix = '/v1';
}
