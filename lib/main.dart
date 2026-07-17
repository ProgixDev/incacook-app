import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incacook/app.dart';
import 'package:incacook/core/config/google_maps_config.dart';
import 'package:incacook/core/config/stripe_config.dart';
import 'package:incacook/core/config/supabase_config.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/services/notifications/device_tokens_repository.dart';
import 'package:incacook/core/services/notifications/order_notifications_service.dart';
import 'package:incacook/core/services/notifications/push_notification_service.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/core/services/map/google_maps_native_config.dart';
import 'package:incacook/core/services/native_google_auth_service.dart';
import 'package:incacook/core/services/revenuecat_service.dart';
import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/charters_repository.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/kyc_repository.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';
import 'package:incacook/core/utils/log.dart';
import 'package:incacook/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //* add widgets bindings
  WidgetsFlutterBinding.ensureInitialized();

  // TEMP boot profiling — logs ms spent in each pre-runApp step so we can see
  // what's keeping the native (white) launch screen up before the splash.
  final boot = Stopwatch()..start();
  void mark(String step) =>
      logInfo('[BOOT] $step @ ${boot.elapsedMilliseconds}ms');
  mark('start');

  //* init local storage
  await GetStorage.init();
  mark('GetStorage.init');

  //* init French locale data for intl DateFormat (used in seller / order UI)
  await initializeDateFormatting('fr_FR');
  mark('initializeDateFormatting');

  //* Supabase — needed for hosted Facebook OAuth and native Google's
  //  signInWithIdToken exchange. Email / phone / refresh stay
  //  backend-mediated. `autoRefreshToken`
  //  is OFF on purpose: once the Facebook handshake hands us a session we
  //  copy it into TokenStorage and the backend's /auth/refresh owns the
  //  lifecycle (same as email). Leaving Supabase's own refresh on
  //  would rotate the refresh token out from under TokenStorage and log the
  //  user out on the next 401. PKCE is the secure mobile OAuth flow.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // The project's public anon key doubles as the publishable key.
      publishableKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: false,
      ),
    );
  }
  mark('Supabase.initialize');

  //* OAuth deep-link diagnostic — logs whether the `incacook://auth/callback`
  //  redirect actually reaches the app. If a social login times out and you
  //  see NO `[DeepLink] received` line, the redirect never came back (Supabase
  //  Redirect-URL allow-list / provider redirect URI not configured). If you DO
  //  see it but the session still doesn't land, it's an app/native issue.
  //  Never logs token/code values.
  _initDeepLinkDiagnostic();

  //* Permanent guard so a Supabase OAuth callback error (e.g. Facebook
  //  returning no email) can NEVER become an unhandled async exception, even
  //  if the per-sign-in listener was already cancelled. The user-facing
  //  message + spinner reset are handled by the sign-in flow; this only
  //  absorbs/logs. Never logs tokens/codes.
  _initSupabaseAuthErrorGuard();

  //* Google Maps Platform public key from --dart-define=GOOGLE_MAPS_API_KEY=...
  if (!GoogleMapsConfig.isConfigured) {
    logWarning(GoogleMapsConfig.missingKeyMessage);
  } else {
    await GoogleMapsNativeConfig.configure();
  }

  //* Stripe — only initialise when a publishable key is configured. Until
  //* then checkout falls back to the dev bypass, so the app still boots
  //* and orders still complete without a real card charge.
  if (StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }
  mark('Stripe');

  //* RevenueCat — seller monthly subscription (App Store / Google Play) ONLY.
  //  Configured with the PUBLIC SDK key; guarded no-op when unconfigured.
  //  Stripe stays the source of truth for order payments / wallet / payouts /
  //  IBAN — RevenueCat never touches those.
  final revenueCat = RevenueCatService();
  await revenueCat.init();
  Get.put<RevenueCatService>(revenueCat, permanent: true);
  mark('RevenueCat');

  Get.put(ThemeController());

  //* network layer — register before any repository that depends on it.
  //  Order matters: TokenStorage feeds AuthInterceptor inside ApiClient.
  // Safe startup diagnostic: log the resolved backend URL ONLY. Never log
  // tokens or secrets. Lets you confirm a real phone picked up LAN_API_BASE_URL.
  logInfo('[ApiConfig] Using API base URL: ${ApiConstants.baseUrl}');
  Get.put<TokenStorage>(TokenStorage(), permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  Get.put<UsersRepository>(UsersRepository(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);
  Get.put<ChartersRepository>(ChartersRepository(), permanent: true);
  Get.put<UploadsRepository>(UploadsRepository(), permanent: true);
  Get.put<KycRepository>(KycRepository(), permanent: true);
  Get.put<BuyersRepository>(BuyersRepository(), permanent: true);
  Get.put<SellersRepository>(SellersRepository(), permanent: true);
  Get.put<DriversRepository>(DriversRepository(), permanent: true);
  Get.put<SupabaseOAuthService>(SupabaseOAuthService(), permanent: true);
  Get.put<NativeGoogleAuthService>(
    NativeGoogleAuthService(),
    permanent: true,
  );
  Get.put<PostAuthRouter>(PostAuthRouter(), permanent: true);
  // Always available (even if Firebase/push init later fails or is off on
  // iOS) so order screens can subscribe unconditionally. The push service is
  // the only publisher; no events simply means no notification-driven refresh.
  Get.put<OrderNotificationsService>(
    OrderNotificationsService(),
    permanent: true,
  );
  mark('Get.put services');

  mark('runApp');
  runApp(const App());
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => mark('first frame painted'),
  );

  //* Firebase + push are NOT on the boot critical path — initialising them
  //  before runApp() blocked the splash for ~3.4s (and it just fails on iOS,
  //  which has no GoogleService-Info.plist). Do it after the first frame so
  //  the splash appears immediately; push stays fully guarded and Android-only.
  unawaited(_initFirebaseAndPush());
}

/// Logs each incoming app link's scheme/host/path and whether it carried an
/// OAuth `code` / `error` — **never** the values. Lets us tell "the OAuth
/// redirect never reached the app" (a dashboard redirect-URL misconfig) apart
/// from "it reached the app but the session didn't land" (an app/native
/// issue), which the `[Auth][OAuth] … timeout` logs alone can't distinguish.
///
/// Also the only app-wide listener that survives a killed
/// `PayoutOnboardingService.openOnboarding` call: if the app process died
/// while the Stripe hosted-onboarding tab was open (iOS jetsam / Android
/// task kill), `_awaitReturn`'s own listener died with it, so the incoming
/// `incacook://stripe/...` return would otherwise be silently dropped. Must
/// stay the single early `AppLinks().uriLinkStream` subscription — it's a
/// broadcast stream, so a second, later subscription would miss any link
/// delivered in between and can't "catch up".
void _initDeepLinkDiagnostic() {
  try {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      final hasCode = uri.queryParameters.containsKey('code');
      final error = uri.queryParameters['error'];
      logError(
        '[DeepLink] received: ${uri.scheme}://${uri.host}${uri.path} '
        '(code: $hasCode${error != null ? ', error: $error' : ''})',
      );
      if (uri.scheme == 'incacook' && uri.host == 'stripe') {
        _handleColdStartStripeLink(uri);
      }
    }, onError: (Object e) => logError('[DeepLink] stream error: $e'));
  } catch (e) {
    logError('[DeepLink] diagnostic setup failed: $e');
  }
}

/// Routes a `incacook://stripe/...` deep link to
/// [PayoutOnboardingService.reconcileFromDeepLink] once services are ready.
/// Guards against the (practically unreachable — `runApp`'s
/// `GeneralBindings` registers the service well before any deep-link
/// platform-channel event could plausibly arrive) race where this fires
/// before `PayoutOnboardingService` is registered; dropping it then is a
/// strict improvement over today's unconditional silent drop, not a
/// regression. `openOnboarding`'s own in-flight listener (the warm path)
/// handles the same event independently, so a duplicate reconcile here when
/// both are alive is harmless (the backend status read is idempotent).
void _handleColdStartStripeLink(Uri uri) {
  if (!Get.isRegistered<PayoutOnboardingService>()) {
    logWarning(
      '[Payout] stripe deep link before services ready — dropped: $uri',
    );
    return;
  }
  unawaited(PayoutOnboardingService.instance.reconcileFromDeepLink(uri));
}

/// Permanent listener whose only job is to keep Supabase auth errors from
/// going unhandled. supabase_flutter routes OAuth callback failures
/// (`getSessionFromUrl` → `notifyException` → `addError`) onto the
/// `onAuthStateChange` stream's error channel; if our short-lived per-sign-in
/// listener has already been cancelled, that error would have no handler and
/// surface as an "Unhandled Exception: AuthException(...)". This always-on
/// listener absorbs it (logging the message only — never tokens/codes). The
/// sign-in flow still owns the user-facing message + spinner reset.
void _initSupabaseAuthErrorGuard() {
  try {
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) {},
      onError: (Object e) {
        final message =
            e is AuthException ? e.message : e.runtimeType.toString();
        logError('[Auth][OAuth] supabase auth error: $message');
      },
    );
  } catch (e) {
    logError('[Auth][OAuth] auth error guard setup failed: $e');
  }
}

/// Background (post-first-frame) Firebase + FCM setup. Guarded end-to-end so a
/// missing/misconfigured config can never affect startup — push just stays off.
Future<void> _initFirebaseAndPush() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    logError('[FCM] Firebase init failed: $e');
    return;
  }
  // The PushNotificationService constructor eagerly reads
  // FirebaseMessaging.instance, so only register it once Firebase is up.
  Get.put<DeviceTokensRepository>(DeviceTokensRepository(), permanent: true);
  Get.put<PushNotificationService>(PushNotificationService(), permanent: true);
  unawaited(PushNotificationService.instance.init());
}
