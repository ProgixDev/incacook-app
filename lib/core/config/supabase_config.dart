/// Supabase client configuration — used **only** for provider OAuth that
/// can't go through a native SDK (currently "Continuer avec Facebook").
///
/// The rest of auth (email/password, Google, phone OTP, refresh) still goes
/// backend-to-backend: the Flutter app POSTs to `/v1/auth/*` and never sees
/// Supabase. Facebook is the deliberate exception — Supabase runs the hosted
/// OAuth dance so the Facebook App ID / Secret stay in the Supabase dashboard
/// and never ship in the app. After the handshake the resulting Supabase
/// session is copied into [TokenStorage] and the backend owns refresh from
/// then on, exactly like a Google / email session.
///
/// SECURITY: both values below are **public** client credentials. The anon key
/// is designed to be embedded in clients — it carries the `anon` role and is
/// gated by row-level security, identical to how it ships in any Supabase
/// web/mobile app. No secret (service-role key, JWT secret, Facebook App
/// Secret) is ever placed here.
///
/// Values are read at build time from `--dart-define` (consistent with
/// `GOOGLE_MAPS_API_KEY` / `API_BASE_URL`), falling back to the IncaCook
/// production project so a plain `flutter run` works out of the box.
class SupabaseConfig {
  SupabaseConfig._();

  /// IncaCook Supabase project URL (ref `eoxrrofpdtrwjbhywcvz`, eu-west-3).
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://eoxrrofpdtrwjbhywcvz.supabase.co',
  );

  /// Public `anon` key for the IncaCook project. Safe to embed (see above).
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVveHJyb2ZwZHRyd2piaHl3Y3Z6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNTY4NTUsImV4cCI6MjA5NjgzMjg1NX0.xfXVcIVqGuV-DzMjCQ45xyO-FYEAZOnjk3Hz909dDP4',
  );

  /// The deep link Supabase redirects back to after the Facebook OAuth
  /// dance. Must be registered in **both** native projects (Android
  /// intent-filter + iOS `CFBundleURLTypes`) **and** in the Supabase
  /// dashboard's Authentication → URL Configuration → Redirect URLs.
  static const String oauthRedirectUrl = 'incacook://auth/callback';

  /// Deep link the Supabase **magic link** redirects back to when a Facebook
  /// no-email user verifies an added email (see CompleteEmailScreen). The
  /// `flow=complete_email` marker lets the app recognise this callback. Must
  /// also be allow-listed in Supabase → Authentication → URL Configuration →
  /// Redirect URLs.
  static const String completeEmailRedirectUrl =
      'incacook://auth/callback?flow=complete_email';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
