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
    // Local default for development. Production/staging inject the real URL
    // via --dart-define=API_BASE_URL=... (e.g. .vscode/dart_defines.json or CI).
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String apiPrefix = '/v1';

  /// Supabase storage base for **public-bucket** object URLs. The stored
  /// `imageUrls` on a listing are `<bucket>/<path>`, so the public URL is
  /// `${supabaseStorageBaseUrl}/${storagePath}`.
  ///
  /// Defaults to the Android-emulator-friendly local Supabase address
  /// (port 54331 mirrors the backend's `SUPABASE_URL`). Override via
  /// `--dart-define=SUPABASE_STORAGE_BASE_URL=...` for staging / prod,
  /// and for the iOS simulator use `http://127.0.0.1:54331/...`.
  static const String supabaseStorageBaseUrl = String.fromEnvironment(
    'SUPABASE_STORAGE_BASE_URL',
    defaultValue: 'http://10.0.2.2:54331/storage/v1/object/public',
  );

  /// Resolves a stored listing image path (`<bucket>/<path>`) to a
  /// fetchable HTTPS URL via [supabaseStorageBaseUrl]. Returns null for an
  /// empty path so callers can fall through to a placeholder.
  static String? publicImageUrl(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    return '$supabaseStorageBaseUrl/$storagePath';
  }
}
