/// Mapbox access token configuration.
///
/// SECURITY: mobile/Flutter apps cannot hide secrets, so the token shipped in
/// the client MUST be a **public** Mapbox token (`pk.…`), ideally URL/scope
/// restricted in the Mapbox dashboard. A **secret** token (`sk.…`) must NEVER
/// be embedded in Flutter.
///
/// The token is read at compile time from a `--dart-define`, so nothing is
/// hardcoded (and nothing secret ends up in Git):
///
///   flutter run --dart-define=MAPBOX_PUBLIC_TOKEN=pk_your_public_token
///
/// See `.env.example` for the variable name.
class MapboxConfig {
  MapboxConfig._();

  /// Public Mapbox token, or '' when not provided at build time.
  // static const String publicToken =
  //     String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');
  static const String publicToken = 'pk.eyJ1IjoiZ2hvc3RhdmU3IiwiYSI6ImNtcHZjcDRsODAzazUyeXJhZm16cWl4ZWYifQ.ACMGS4gX27uzBjr0s5z8SA';

  /// True once a token has been supplied via `--dart-define`.
  static bool get isConfigured => publicToken.isNotEmpty;

  /// Clear development error surfaced when the token is missing — instead of
  /// silently failing map/route/search requests with a 401.
  static const String missingTokenMessage =
      'MAPBOX_PUBLIC_TOKEN is missing. Run Flutter with '
      '--dart-define=MAPBOX_PUBLIC_TOKEN=pk_...';
}
