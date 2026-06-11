/// Client-side Stripe configuration.
///
/// Only the **publishable** key lives in the app (it is safe to ship).
/// The **secret** key must never be in the app — it stays on the backend
/// (`IncaCook-Server` → `.env` → `STRIPE_SECRET_KEY`).
///
/// IMPORTANT: this publishable key and the backend's secret key MUST be
/// from the **same** Stripe account, otherwise charges fail. Both are
/// currently the `51TdvHC…` test account (STRIPE_SECRET_KEY +
/// STRIPE_PUBLISHABLE_KEY in IncaCook-Server/.env match this default).
///
/// You can override at build time without editing this file:
///   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx
class StripeConfig {
  const StripeConfig._();

  /// Stripe publishable key ("Clé publique", pk_test_… / pk_live_…).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
      'pk_test_51TdvHCBSdl9ByXxumU62Vjl06xKGV1b4wsMQ0gO0wjGpWJyM88h0sg4QxukJjiOEhbBa38ObVN8IVrYdKtYqREL000HesTtbcX'
        //'pk_test_51SaFR61kCiAVzFAvgrT1IE5iN5oIYYABm1UESulyTbZgOwm6hJ5CbGnvaVtwwjOfdsd9ejCUlXVetk1HfRKHIqce00YXS5pFHy',
  );

  /// Name shown at the top of the Stripe Payment Sheet.
  static const String merchantDisplayName = 'IncaCook';

  /// True once a publishable key is present. When false the checkout skips
  /// the Payment Sheet (dev bypass) so the flow still works pre-keys.
  static bool get isConfigured => publishableKey.isNotEmpty;
}
